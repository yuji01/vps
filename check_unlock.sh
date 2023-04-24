#! /bin/bash
#解锁检测
RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
BLUE="\e[1;34m"
PINK="\e[1;35m"
QING="\e[1;36m"
OTHER="\e[1;$[RANDOM%7+31]m"
END="\e[0m"

nf_check(){
#奈飞检测
[ ! -e `pwd`/nf ] && wget -O nf https://github.com/sjlleo/netflix-verify/releases/download/v3.1.0-1/nf_linux_amd64
chmod +x nf && ./nf
}
media_check(){
#流媒体检测
bash <(curl -L -s check.unlock.media)
}
openai_check(){
#openai检测
bash <(curl -Ls https://cdn.jsdelivr.net/gh/missuo/OpenAI-Checker/openai.sh)
}
while :;do
echo -e "
${OTHER}菜单：
  ${RED}0  ---  退出脚本${END}
--------------------------------
  ${YELLOW}1  ---  奈飞检测
  2  ---  流媒体检测
  3  ---  Openai服务检测${END}"
read -e -p "请输入：" INPUT
  case $INPUT in
    0)
      break;;
    1)
      nf_check;;
    2)
      media_check;;
    3)
      openai_check;;
    *)
      echo -e "${RED}请重新输入${END}"
  esac
done
