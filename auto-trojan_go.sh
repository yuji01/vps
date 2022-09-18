#!/bin/bash
os_check(){
echo "安装相关软件包"
if [ `lsb_release -a|grep -e "[Dd]ebian"` != ''  -o `lsb_release -a|grep -e "[Uu]buntu"` != '' ];then
apt update && apt install socat curl wget libpcre3 libpcre3-dev zlib1g-dev openssl libssl-dev unzip
elif [[ `cat /etc/redhat-release` != '' ]];then
yum update && yum install socat curl wget gcc-c++ zlib zlib-devel pcre pcre-devel openssl openssl-devel unzip
else
echo "不支持的系统"
fi
}
read -p "请输入Web域名：" WEB
read -p "请输入Trojan-go域名：" TROJAN_GO
acme(){
cd
curl https://get.acme.sh | sh
./.acme.sh/acme.sh --set-default-ca --server letsencrypt
./.acme.sh/acme.sh --register-account -m x`date "+%Y%m%d%H%M%S"`x${RANDOM}x@qq.com
./.acme.sh/acme.sh  --issue -d $WEB --standalone &&
mkdir -p /ssl/$WEB
./.acme.sh/acme.sh --installcert -d $WEB --fullchain-file /ssl/$WEB/cret.crt --key-file /ssl/$WEB/private.key
./.acme.sh/acme.sh  --issue -d $TROJAN_GO --standalone &&
mkdir -p /ssl/$TROJAN_GO
./.acme.sh/acme.sh --installcert -d $TROJAN_GO --fullchain-file /ssl/$TROJAN_GO/cret.crt --key-file /ssl/$TROJAN_GO/private.key
echo  "证书安装路径：
Web证书：
	公钥路径：/ssl/$WEB/cret.crt
	私钥路径：/ssl/$WEB/private.key
---------------------------------------
Trojan-go证书：
	公钥路径：/ssl/$TROJAN_GO/cret.crt
	私钥路径：/ssl/$TROJAN_GO/private.key"
./.acme.sh/acme.sh  --upgrade  --auto-upgrade
}
nginx(){
cd /usr/local/
wget https://nginx.org/download/nginx-1.22.0.tar.gz
tar zxvf nginx-*
cd nginx-1.22.0
./configure --prefix=/usr/local/nginx --pid-path=/var/run/nginx/nginx.pid --lock-path=/var/lock/nginx.lock --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --with-http_gzip_static_module --http-client-body-temp-path=/var/temp/nginx/client --http-proxy-temp-path=/var/temp/nginx/proxy --http-fastcgi-temp-path=/var/temp/nginx/fastcgi --http-uwsgi-temp-path=/var/temp/nginx/uwsgi --http-scgi-temp-path=/var/temp/nginx/scgi --with-http_ssl_module --with-stream --with-stream_ssl_preread_module --with-http_v2_module &&
make && make install && echo "succeed"
#修改nginx主配置
(
cat << EOF
#user  nobody;
worker_processes  auto;
events {
    worker_connections  1024;
}
stream {
    # 这里就是 SNI 识别，将域名映射成一个配置名
    map $ssl_preread_server_name $backend_name {
        www.yuji2022.com web;
        trojan.yuji2022.com trojan;
        # 域名都不匹配情况下的默认值
        default web;
    }
    # web，配置转发详情
    upstream web {
        server 127.0.0.1:4431;
    }
    # trojan，配置转发详情
    upstream trojan {
        server 127.0.0.1:4432;
    }
    # 监听 443 并开启 ssl_preread
    server {
        listen 443 reuseport;
        listen [::]:443 reuseport;
        proxy_pass  $backend_name;
        ssl_preread on;
    }
}
http {
    include       web.conf;
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
}
EOF
) > /usr/local/nginx/conf/nginx.conf
sed -i "9s/www.yuji2022.com/$WEB/g" /usr/local/nginx/conf/nginx.conf
sed -i "10s/trojan.yuji2022.com/$TROJAN_GO/g" /usr/local/nginx/conf/nginx.conf
#web配置
(
cat << EOF
server {
	listen	80;
	server_name 	www.yuji2022.com;
	if ($server_port !~ 4431){
        	rewrite ^(/.*)$ https://$host$1 permanent;
    	}
}
server {
	listen	4431 ssl http2;
	server_name	www.yuji2022.com;
	#ssl
	ssl_protocols TLSv1.2 TLSv1.3;
    ssl_certificate      /ssl/www.yuji2022.com/cret.crt;
    ssl_certificate_key  /ssl/www.yuji2022.com/private.key;
    ssl_session_cache    shared:SSL:1m;
    ssl_session_timeout  5m;
    ssl_ciphers  HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers  on;
	
	root		/www;
	index	index.html;
}
EOF
) > /usr/local/nginx/conf/web.conf
sed -i "s/www.yuji2022.com/$WEB/g" /usr/local/nginx/conf/web.conf
sed -i "s@/ssl/www.yuji2022.com/cret.crt@/ssl/$WEB/cret.crt@g" /usr/local/nginx/conf/web.conf
sed -i "s@/ssl/www.yuji2022.com/private.key@/ssl/$WEB/private.key@g" /usr/local/nginx/conf/web.conf
mkdir -p /www && cp /usr/local/nginx/html/* /www
#创建nginx启动脚本
(
cat << EOF
[Unit]
Description=nginx service
After=network.target 
   
[Service] 
Type=forking
# 路径对应安装路径
ExecStartPre=/usr/local/nginx/sbin/nginx -t
ExecStart=/usr/local/nginx/sbin/nginx
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/usr/local/nginx/sbin/nginx -s quit
PrivateTmp=true 
   
[Install] 
WantedBy=multi-user.target
EOF
) > /lib/systemd/system/nginx.service
systemctl daemon-reload && systemctl start nginx.service && systemctl enable nginx.service
}
trojan(){
cd /usr/local/
wget https://github.com/p4gefau1t/trojan-go/releases/download/v0.10.6/trojan-go-linux-amd64.zip &&
unzip -d /usr/local/trojan-go/ trojan-go-linux-amd64.zip &&
#trojan-go配置文件
(
cat << EOF
{
  "run_type": "server",
  "local_addr": "0.0.0.0",
  "local_port": 4432,
  "remote_addr": "127.0.0.1",
  "remote_port": 80,
  "log_level": 1,
  "log_file": "",
  "password": ["yujibuzailai"],
  "disable_http_check": false,
  "udp_timeout": 60,
  "ssl": {
    "verify": true,
    "verify_hostname": true,
    "cert": "/ssl/trojan.yuji2022.com/cret.crt",
    "key": "/ssl/trojan.yuji2022.com/private.key",
    "key_password": "",
    "cipher": "",
    "curves": "",
    "prefer_server_cipher": false,
    "sni": "trojan.yuji2022.com",
    "alpn": [
      "http/1.1"
    ],
    "session_ticket": true,
    "reuse_session": true,
    "plain_http_response": "",
    "fallback_addr": "127.0.0.1",
    "fallback_port": 80,
    "fingerprint": ""
  },
  "tcp": {
    "no_delay": true,
    "keep_alive": true,
    "prefer_ipv4": false
  },
  "mux": {
    "enabled": true,
    "concurrency": 8,
    "idle_timeout": 60
  },
  "router": {
    "enabled": false,
    "bypass": [],
    "proxy": [],
    "block": [],
    "default_policy": "proxy",
    "domain_strategy": "as_is",
    "geoip": "$PROGRAM_DIR$/geoip.dat",
    "geosite": "$PROGRAM_DIR$/geosite.dat"
  },
  "websocket": {
    "enabled": true,
    "path": "/yuji2022path",
    "host": ""
  },
  "shadowsocks": {
    "enabled": false,
    "method": "AES-128-GCM",
    "password": ""
  },
  "transport_plugin": {
    "enabled": false,
    "type": "",
    "command": "",
    "option": "",
    "arg": [],
    "env": []
  },
  "forward_proxy": {
    "enabled": false,
    "proxy_addr": "",
    "proxy_port": 0,
    "username": "",
    "password": ""
  },
  "mysql": {
    "enabled": false,
    "server_addr": "localhost",
    "server_port": 3306,
    "database": "",
    "username": "",
    "password": "",
    "check_rate": 60
  },
  "api": {
    "enabled": false,
    "api_addr": "",
    "api_port": 0,
    "ssl": {
      "enabled": false,
      "key": "",
      "cert": "",
      "verify_client": false,
      "client_cert": []
    }
  }
}
EOF
) > /usr/local/trojan-go/server.json
PASSWORD="`date "+%Y%m%d%H%M%S"`yjbzl$RANDOM"
sed -i "s/yujibuzailai/$PASSWORD/g" /usr/local/trojan-go/server.json
sed -i "s@/ssl/trojan.yuji2022.com/cret.crt@/ssl/$TROJAN_GO/cret.crt@g" /usr/local/trojan-go/server.json
sed -i "s@/ssl/trojan.yuji2022.com/private.key@/ssl/$TROJAN_GO/private.key@g" /usr/local/trojan-go/server.json
PATH_Trojan="`date "+%Y%m%d%H%M%S"`yuji2022$RANDOM"
sed -i "s@yuji2022path@$PATH_Trojan@g" /usr/local/trojan-go/server.json
#创建启动脚本
(
cat << EOF
[Unit]
Description=trojan
Documentation=https://github.com/p4gefau1t/trojan-go
After=network.target

[Service]
Type=simple
PIDFile=/usr/src/trojan/trojan/trojan.pid
#trojan go路径和需要的配置文件
ExecStart=/usr/local/trojan-go/trojan-go -config /usr/local/trojan-go/server.json
ExecReload=kill $(pidof trojan) && /usr/local/trojan-go/trojan-go -config /usr/local/trojan-go/server.json
ExecStop=kill $(pidof trojan)
LimitNOFILE=51200
Restart=on-failure
RestartSec=1s

[Install]
WantedBy=multi-user.target
EOF
) > /lib/systemd/system/trojan.service
systemctl daemon-reload && systemctl start trojan.service && systemctl enable trojan.service
echo "Trojan配置：
`sed -n '/.*sni.*/p' /usr/local/trojan-go/server.json|sed 's/sni/服务器地址/'`
    "端口": "443"
`sed -n '/.*password/p' /usr/local/trojan-go/server.json|head -n1|sed 's/password/连接密码/'`
    "网络": "ws"
ws-opts:
`sed -n '/.*path.*/p' /usr/local/trojan-go/server.json|sed 's/path/路径/'`
"
}
os_check
acme
nginx
trojan
