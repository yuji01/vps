#! /bin/bash
#缝合怪在此
RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
BLUE="\e[1;34m"
PINK="\e[1;35m"
QING="\e[1;36m"
OTHER="\e[1;$[RANDOM%7+31]m"
END="\e[0m"
[ ! $UID -eq 0 ] && echo -e "$RED请以root用户运行！$END" && exit 1 
route_check(){
#线路检测
curl https://raw.githubusercontent.com/zhanghanyun/backtrace/main/install.sh -sSf | sh
}

system_test(){
#系统测试
bash <(wget -qO- --no-check-certificate https://gitlab.com/spiritysdx/za/-/raw/main/ecs.sh)
}

bbr(){
#开启bbr
#[ ! -e `pwd`/tcp.sh ] && wget -N --no-check-certificate "https://raw.githubusercontent.com/chiakge/Linux-NetSpeed/master/tcp.sh"
#chmod +x tcp.sh && ./tcp.sh

# 新脚本
[ ! -e `pwd`/tcpx.sh ] && wget --no-check-certificate -O tcpx.sh https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcpx.sh
chmod +x tcpx.sh && ./tcpx.sh
}
check_unlock(){
#解锁检测
bash <(curl https://raw.githubusercontent.com/yuji01/vps/main/check_unlock.sh)
}

warp-go(){
#warp-go
[ ! -e `pwd`/warp-go.sh ] && wget -N https://gitlab.com/fscarmen/warp/-/raw/main/warp-go.sh
bash warp-go.sh [option] [lisence]
}
warp(){
#warp
[ ! -e `pwd`/menu.sh ] && wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh
bash menu.sh [option] [lisence]
}
ipv4_or_ipv6(){
#测试ipv4还是ipv6优先
curl ip.sb
echo "请自行判断"
}

acme(){
#证书申请
#新版本
bash <(curl https://raw.githubusercontent.com/yuji01/vps/main/acme-yuji01.sh)
}
xui(){
#原本xui
bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
}
xui_mod(){
#魔改版本xui
bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/x-ui/master/install.sh)
}
hysteria(){
#hysteria协议
# bash <(curl -fsSL https://git.io/hysteria.sh)
bash <(curl -Ls https://raw.githubusercontent.com/emptysuns/Hi_Hysteria/main/server/install.sh)
}
docker_install(){
#安装官方docker
bash <(curl https://raw.githubusercontent.com/yuji01/vps/refs/heads/main/install_docker/install_docker.sh)
}
xrayr(){
#下载xrayr
git clone https://github.com/XrayR-project/XrayR-release ./xrayr
}
install_python(){
#安装python
bash <(curl https://raw.githubusercontent.com/yuji01/vps/main/install_python.sh)
}
set_swap(){
#虚拟内存
bash <(curl https://raw.githubusercontent.com/yuji01/vps/main/swap.sh)
}
change_timezone(){
# 修改时区为上海
rm -rf /etc/localtime &&
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime &&
echo "Asia/Shanghai" > /etc/timezone &&
echo -e "$GREEN修改时区成功$END"
date
}
ufw_docker(){
bash <(curl https://raw.githubusercontent.com/yuji01/vps/main/ufw_docker.sh)
}

log_size(){
bash <(curl https://raw.githubusercontent.com/yuji01/vps/main/journalctl_size.sh)
}


while :;do
echo -e "欢迎使用 ${OTHER}ナルト${END} 编写的tools脚本
${OTHER}菜单：
  ${RED}0  ---  退出脚本${END}
--------------------------------
  ${YELLOW}1  ---  三网回程
  2  ---  系统测试
  3  ---  bbr脚本
  4  ---  解锁检测${END}
--------------------------------
  ${PINK}5  ---  warp
  6  ---  warp-go
  7  ---  检测网络优先级${END}
--------------------------------
  ${GREEN}8  ---  Acme 脚本
  9  ---  安装x-ui
 10  ---  安装魔改版x-ui
 11  ---  安装hysteria${END}
--------------------------------
 ${QING}12  ---  安装docker
 13  ---  下载xrayr
 14  ---  编译安装Python
 15  ---  设置虚拟内存
 16  ---  修改时区为上海
 17  ---  设置日志大小
 18  ---  修复ufw_docker的漏洞${END}"
read -e -p "请输入：" INPUT
  case $INPUT in
    0)
      break;;
    1)
      route_check;;
    2)
      system_test;;
    3)
      bbr;;
    4)
      check_unlock;;
    5)
      warp;;
    6)
      warp-go;;
    7)
      ipv4_or_ipv6;;
    8)
      acme;;
    9)
      xui;;
    10)
      xui_mod;;
    11)
      hysteria;;
    12)
      docker_install;;
    13)
      xrayr;;
    14)
      install_python;;
    15)
      set_swap;; 
    16)
      change_timezone;;
    17)
      log_size;;
    18)
      ufw_docker;;
     *)
      echo -e "${RED}请重新输入${END}"
  esac
done
