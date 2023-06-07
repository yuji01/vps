# !/bin/bash
check_os(){
  if [[ ! -z "`cat /etc/redhat-release | grep -iE "CentOS"`" ]]; then
    echo "Sorry, your system is not supported!" && exit 1
  elif [ `ufw --version &> /dev/null` -ne 0 ];then
    echo "ufw is not installed, this script cannot be used" && exit 1
  fi
}
change_ufw(){
  echo "Please go to https://github.com/chaifeng/ufw-docker for details"
  echo "The file will be written to /etc/ufw/after.rules"
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
  [ $? -eq 0 ] && echo "Write configuration complete"
  [ $? -eq 0 ] && systemctl restart ufw && echo "Restart ufw is complete, please enjoy it :)"
}

enable_port(){
  read -e -p "tcp/udp? " protocol
  read -e -p "port: " port
  ufw route allow proto $protocol from any to any port $port
}

delete_port(){
  ufw status numbered
  read -e -p "num: " num
  ufw delete $num
}

menu(){
echo "Menu：
0.exit
1.ufw_docker
2.enable port
3.delete enable port"
read -e -p "choose: " INPUT
case $INPUT in
  0)
    break;;
  1)
    change_ufw;;
  2)
    enable_port;;
  3)
    delete_port;;
  *)
    echo "please enter again"
esac
}
check_os
menu
