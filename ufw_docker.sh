# !/bin/bash
RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
BLUE="\e[1;34m"
PINK="\e[1;35m"
QING="\e[1;36m"
OTHER="\e[1;$[RANDOM%7+31]m"
END="\e[0m"
check_os(){
  if [[ ! -z "`cat /etc/redhat-release | grep -iE "CentOS"`" ]]; then
    echo -e "${RED}抱歉，不支持您的系统！${END}" && exit 1
  fi
  ufw --version
  if [ $? -ne 0 ];then
    echo -e "${RED}ufw 未安装，无法使用此脚本！${END}" && exit 1
  fi
}

write_ufw(){
  echo -e "${YELLOW}详情请前往 https://github.com/chaifeng/ufw-docker 了解${END}"
  echo -e "${YELLOW}配置将写入 /etc/ufw/after.rules${END}"
if grep -q -F "# BEGIN UFW AND DOCKER" /etc/ufw/after.rules && grep -q -F "# END UFW AND DOCKER" /etc/ufw/after.rules; then
    echo -e "${RED}/etc/ufw/after.rules 存在 ufw_docker 的规则，程序退出${END}" && exit 0
else
    echo -e "${GREEN}/etc/ufw/after.rules 不存在 ufw_docker 的规则，将写入规则…${END}"
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

  [ $? -eq 0 ] && echo -e "${GREEN}写入配置完成${END}"
  [ $? -eq 0 ] && systemctl restart ufw && echo -e "${GREEN}重启ufw完成，请尽情享受吧:)${END}"
}

open_port(){
  read -e -p "请输入"协议 端口"（例如 "tcp 3389"）" protocol port
  ufw route allow proto $protocol from any to any port $port && 
  echo -e "${GREEN}开放 $protocol 协议的 $port 完成${END}"
}

close_port(){
  read -e -p "请输入"协议 端口"（例如 "tcp 3389"）" protocol port
  ufw delete allow proto $protocol from any to any port $port && 
  echo -e "${GREEN}关闭 $protocol 协议的 $port 完成${END}"
}

menu(){
echo -e "${YELLOW} host网络类型直接用ufw allow xxx放行，端口映射模式(-p) 开放/关闭需要用2/3${END}"
echo -e "${OTHER}菜单：
 0 -- 退出脚本
 1 -- 修复ufw_docker
 2 -- 允许外部网络访问 Docker 容器提供的服务
 3 -- 删除外部网络访问 Docker 容器提供的服务${END}"
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
    echo -e "${RED}输入错误，请重新输入${END}"
esac
}
check_os
menu
