#缝合怪在此
RED="\e[1;31m"
GREEN="\e[1;32m"
OTHER="\e[1;$[RANDOM%7+31]m"
END="\e[0m"
while :;do
echo -e "${OTHER}
菜单：
  ${RED}q  ---  退出脚本${END}
--------------------------------
--------------------------------
  ${OTHER}1  ---  bbr脚本
  2  ---  使用ACME申请证书
--------------------------------
  3  ---  流媒体检测
  4  ---  warp-go
  5  ---  查看ipv4/ipv6优先
--------------------------------
  6  ---  hysteria
  7  ---  安装原版x-ui
  8  ---  安装魔改版x-ui
--------------------------------
  9  ---  测试三网回程路由
${END}
"
read -e -p "请输入：" INPUT
  case $INPUT in
    q|Q)
      break;;
    1)
      bash <(curl -fsSL https://raw.githubusercontent.com/chiakge/Linux-NetSpeed/master/tcp.sh);;
    2)
      bash <(curl https://raw.githubusercontent.com/yuji01/vps/main/acme_yuji01.sh);;
    3)
      bash <(curl -L -s check.unlock.media);;
    4)
      bash <(curl -fsSL https://raw.githubusercontent.com/fscarmen/warp/main/warp-go.sh);;
    5)
      curl ip.sb;;
    6)
      bash <(curl -fsSL https://git.io/hysteria.sh);;
    7)
      bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh);;
    8)
      bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/x-ui/master/install.sh);;
    9)
      curl https://raw.githubusercontent.com/zhanghanyun/backtrace/main/install.sh -sSf | sh;;
    *)
      echo -e "${RED}请重新输入${END}"
  esac
done
