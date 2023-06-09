# !/bin/bash
check_os(){
  if [[ ! -z "`cat /etc/redhat-release | grep -iE "CentOS"`" ]]; then
    echo "抱歉，不支持您的系统！" && exit 1
  fi
  ufw --version
  if [ $? -ne 0 ];then
    echo "ufw 未安装，无法使用此脚本！" && exit 1
  fi
}

write_ufw(){
  echo "详情请前往 https://github.com/chaifeng/ufw-docker"
  echo "该文件将写入 /etc/ufw/after.rules"
if grep -q -F "# BEGIN UFW AND DOCKER" /etc/ufw/after.rules && grep -q -F "# END UFW AND DOCKER" /etc/ufw/after.rules; then
    echo "/etc/ufw/after.rules 存在 ufw_docker 的规则，程序退出" && exit 0
else
    echo "/etc/ufw/after.rules 不存在 ufw_docker 的规则，将写入规则…"
cat >> /etc/ufw/after.rules <<\EOF
# BEGIN UFW AND DOCKER
*filter
:ufw-user-forward - [0:0]
:ufw-docker-logging-deny - [0:0]
:DOCKER-USER - [0:0]
-A DOCKER-USER -j ufw-user-forward

-A DOCKER-USER -j RETURN -s 10.0.0.0/8
-A DOCKER-USER -j RETURN -s 172.16.0.0/12
-A DOCKER-USER -j RETURN -s 192.168.0.0/16

-A DOCKER-USER -p udp -m udp --sport 53 --dport 1024:65535 -j RETURN

-A DOCKER-USER -j ufw-docker-logging-deny -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -d 192.168.0.0/16
-A DOCKER-USER -j ufw-docker-logging-deny -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -d 10.0.0.0/8
-A DOCKER-USER -j ufw-docker-logging-deny -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -d 172.16.0.0/12
-A DOCKER-USER -j ufw-docker-logging-deny -p udp -m udp --dport 0:32767 -d 192.168.0.0/16
-A DOCKER-USER -j ufw-docker-logging-deny -p udp -m udp --dport 0:32767 -d 10.0.0.0/8
-A DOCKER-USER -j ufw-docker-logging-deny -p udp -m udp --dport 0:32767 -d 172.16.0.0/12

-A DOCKER-USER -j RETURN

-A ufw-docker-logging-deny -m limit --limit 3/min --limit-burst 10 -j LOG --log-prefix "[UFW DOCKER BLOCK] "
-A ufw-docker-logging-deny -j DROP

COMMIT
# END UFW AND DOCKER
EOF
fi

  [ $? -eq 0 ] && echo "写入配置完成"
  [ $? -eq 0 ] && systemctl restart ufw && echo "重启ufw完成，请尽情享受吧:)"
}

open_port(){
  read -e -p "请选择协议：tcp/udp/other？" protocol
  read -e -p "请输入要开放的端口：" port
  ufw route allow proto $protocol from any to any port $port && echo "开放 $protocol 协议的 $port 完成"
}

close_port(){
  read -e -p "请选择协议：tcp/udp/other？" protocol
  read -e -p "请输入要关闭的端口：" port
  ufw delete allow proto $protocol from any to any port $port && echo "关闭 $protocol 协议的 $port 完成"
}

menu(){
echo "菜单：
 0 -- 退出脚本
 1 -- 修复ufw_docker
 2 -- 开放docker容器端口
 3 -- 关闭docker容器端口"
read -e -p "请输入：" INPUT
case $INPUT in
  0)
    break;;
  1)
    write_ufw;;
  2)
    open_port;;
  3)
    close_port;;
  *)
    echo "输入错误，请重新输入"
esac
}
check_os
menu
