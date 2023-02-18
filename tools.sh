#! /bin/bash
#缝合怪在此
RED="\e[1;31m"
GREEN="\e[1;32m"
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
bash <(curl https://raw.githubusercontent.com/yuji01/vps/main/acme_yuji01.sh)
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
  check_os(){
  #系统检测
    if [[ ! -z "`cat /etc/issue | grep -iE "debian"`" ]]; then
      os='debian'
    elif [[ ! -z "`cat /etc/issue | grep -iE "ubuntu"`" ]]; then
      os='ubuntu'
    elif [[ ! -z "`cat /etc/redhat-release | grep -iE "CentOS"`" ]]; then
      os='centos'
    else
      echo -e "${RED}很抱歉，你的系统不受支持!${END}" && exit 1
    fi
  }
  install_docker(){
  case $os in
    debian)
      apt-get remove docker docker-engine docker.io containerd runc;
      apt-get update &&
      apt-get install -y ca-certificates curl gnupg lsb-release &&
      mkdir -p /etc/apt/keyrings &&
      curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg &&
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null &&
      apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
      ;;
    ubuntu)
      apt-get remove docker docker-engine docker.io containerd runc;
      apt-get update &&
      apt-get install -y ca-certificates curl gnupg lsb-release &&
      mkdir -p /etc/apt/keyrings &&
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg &&
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null &&
      apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
      ;;
    centos)
      yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine;
      yum install -y yum-utils &&
      yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo &&
      yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin    
  esac
  }
  check_os
  install_docker && echo "docker 安装完成" || echo "docker 安装失败"
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

while :;do
echo -e "${OTHER}
菜单：
  ${RED}q  ---  退出脚本${END}
--------------------------------
--------------------------------
  ${OTHER}1  ---  三网回程
  2  ---  系统测试
  3  ---  bbr脚本
--------------------------------
  4  ---  奈飞检测
  5  ---  流媒体检测
--------------------------------
  6  ---  warp
  7  ---  warp-go
  8  ---  检测网络优先级
--------------------------------
  9  ---  Acme 脚本
  10 ---  安装x-ui
  11 ---  安装魔改版x-ui
  12 ---  安装hysteria
--------------------------------
  13 ---  安装docker
  14 ---  下载xrayr
  15 ---  Openai服务检测
  16 ---  安装python 3.11.2
${END}
"
read -e -p "请输入：" INPUT
  case $INPUT in
    q|Q)
      break;;
    1)
      clear
      route_check;;
    2)
      clear
      system_test;;
    3)
      clear
      bbr;;
    4)
      clear
      nf_check;;
    5)
      clear
      media_check;;
    6)
      clear
      warp;;
    7)
      clear
      warp-go;;
    8)
      clear
      ipv4_or_ipv6;;
    9)
      clear
      acme;;
    10)
      clear
      xui;;
    11)
      clear
      xui_mod;;
    12)
      clear
      hysteria;;
    13)
      clear
      docker_install;;
    14)
      clear
      xrayr;;
    15)
      clear
      openai_check;;
    16)
      clear
      install_python;;
    *)
      echo -e "${RED}请重新输入${END}"
  esac
done
