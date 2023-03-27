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
[ ! -e `pwd`/tcp.sh ] && wget -N --no-check-certificate "https://raw.githubusercontent.com/chiakge/Linux-NetSpeed/master/tcp.sh"
chmod +x tcp.sh && ./tcp.sh
}
nf_check(){
#奈飞解锁
[ ! -e `pwd`/nf ] && wget -O nf https://github.com/sjlleo/netflix-verify/releases/download/v3.1.0-1/nf_linux_amd64
chmod +x nf && ./nf
}
media_check(){
#流媒体检测
bash <(curl -L -s check.unlock.media)
}
warp-go(){
#warp-go
[ ! -e `pwd`/warp-go.sh ] && wget -N https://raw.githubusercontent.com/fscarmen/warp/main/warp-go.sh
bash warp-go.sh [option] [lisence]
}
warp(){
#warp
[ ! -e `pwd`/menu.sh ] && wget -N https://raw.githubusercontent.com/fscarmen/warp/main/menu.sh
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
bash <(curl -fsSL https://git.io/hysteria.sh)
}
docker_install(){
#安装官方docker
bash <(curl https://raw.githubusercontent.com/yuji01/vps/main/install_docker.sh)
}
xrayr(){
#下载xrayr
git clone https://github.com/XrayR-project/XrayR-release ./xrayr
}
openai_check(){
#检测vps是否支持使用openai的服务
bash <(curl -Ls https://cpp.li/openai)
}
install_python(){
#安装python
bash <(curl https://raw.githubusercontent.com/yuji01/vps/main/install_python.sh)
}
change_timezone(){
# 修改时区为上海
rm -rf /etc/localtime &&
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime &&
echo "Asia/Shanghai" > /etc/timezone &&
echo -e "$GREEN修改时区成功$END"
date
}


while :;do
echo -e "欢迎使用 ${OTHER}ナルト${END} 开发的tools脚本
${OTHER}菜单：
  ${RED}0  ---  退出脚本${END}
--------------------------------
  ${YELLOW}1  ---  三网回程
  2  ---  系统测试
  3  ---  bbr脚本${END}
--------------------------------
  ${BLUE}4  ---  奈飞检测
  5  ---  流媒体检测${END}
--------------------------------
  ${PINK}6  ---  warp
  7  ---  warp-go
  8  ---  检测网络优先级${END}
--------------------------------
  ${GREEN}9  ---  Acme 脚本
  10 ---  安装x-ui
  11 ---  安装魔改版x-ui
  12 ---  安装hysteria${END}
--------------------------------
  ${QING}13 ---  安装docker
  14 ---  下载xrayr
  15 ---  Openai服务检测
  16 ---  编译安装Python
  17 ---  设置虚拟内存
  18 --- 修改时区为上海${END}"
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
      nf_check;;
    5)
      media_check;;
    6)
      warp;;
    7)
      warp-go;;
    8)
      ipv4_or_ipv6;;
    9)
      acme;;
    10)
      xui;;
    11)
      xui_mod;;
    12)
      hysteria;;
    13)
      docker_install;;
    14)
      xrayr;;
    15)
      openai_check;;
    16)
      install_python;;
    17)
      bash <(curl https://raw.githubusercontent.com/yuji01/vps/main/swap.sh);; 
    18)
      change_timezone;;
     *)
      echo -e "${RED}请重新输入${END}"
  esac
done
