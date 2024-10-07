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

install_docker(){
# 完整版docker
curl https://raw.githubusercontent.com/yuji01/vps/refs/heads/main/install_docker/install_docker.sh -sSf | sh
}

install_docker_silm(){
# 精简版docker
curl https://raw.githubusercontent.com/yuji01/vps/refs/heads/main/install_docker/install_docker_silm.sh -sSf | sh
}

while :;do
echo -e "欢迎使用 ${OTHER}ナルト${END} 编写的 docker安装脚本
${OTHER}菜单：
  ${RED}0  ---  退出脚本${END}
--------------------------------
  ${YELLOW}1  ---  安装docker 完整版
  2  ---  安装docker 精简版${END}"
read -e -p "请输入：" INPUT
  case $INPUT in
    0)
      break;;
    1)
      install_docker;;
    2)
      install_docker_silm;;
    *)
      echo -e "${RED}请重新输入${END}"
  esac
done
