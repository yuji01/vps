#!/bin/bash
RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
OTHER="\e[1;$[RANDOM%7+31]m"
END="\e[0m"
#安装脚本的路径
DIR=`pwd ~`
#安装证书的路径
SSL='/ssl'
#检查是否是root用户运行
[[ "`id -u`" != "0" ]] && echo -e "${RED} 请以root用户运行" && exit 1
#判断系统并安装相关的包
check_system(){
if [[ ! -z "`cat /etc/issue | grep -iE "debian"`" ]]; then
  apt-get update -y && apt-get install -y socat lsof
elif [[ ! -z "`cat /etc/issue | grep -iE "ubuntu"`" ]]; then
  apt-get update -y && apt-get install -y socat lsof
elif [[ ! -z "`cat /etc/redhat-release | grep -iE "CentOS"`" ]]; then
  yum update -y && yum install -y socat lsof
else
  echo -e "${RED}很抱歉，你的系统不受支持!" && exit 1
fi
}
#检测80端口是否被占用
check_port(){
if [ -z `lsof -i:80` ];then
  echo -e "${GREEN}80端口没被占用，可以继续申请域名${END}
  但是要注意要${YELLOW}打开防火墙的80端口${END}哦"
else
  for i in {1..3};do
    echo -e "${RED}80端口被占用了，请自行关闭占用80端口的程序，或者选择其他方式申请证书${END}"
  done
  echo -e "提示：
  你可以使用${YELLOW} lsof -i:80 ${END}来查看占用80端口的程序"
  exit 1
fi
}
#安装acme脚本
install_acme(){
  echo -e "${RED}Acme脚本默认安装在${DIR}$END"
  check_system &&
  cd $DIR
  curl https://get.acme.sh | sh
  [ -f $DIR/.acme.sh/acme.sh ] && echo -e "${GREEN}安装成功$END" || echo -e "${RED}安装失败$END"
}
#改变ca提供商
change_ca(){
  echo -e "默认使用 ZeroSSL，可切换的CA提供商如下：
  1  ---  Let's Encrypt
  2  ---  Buypass
  3  ---  SSL.com
  4  ---  ZeroSSL"
  read -n 1 -p "请输入数字：" input
  case $input in
    1)
      $DIR/.acme.sh/acme.sh --set-default-ca --server letsencrypt &&
      echo -e "CA已经切换为：${GREEN}Let's Encrypt$END" || echo -e "${RED}CA切换失败$END"
    ;;
    2)
      $DIR/.acme.sh/acme.sh --set-default-ca --server buypass &&
      echo -e "CA已经切换为：${GREEN}Buypass$END" || echo -e "${RED}CA切换失败$END"
    ;;
    3)
      $DIR/.acme.sh/acme.sh --set-default-ca --server ssl.com &&
      echo -e "CA已经切换为：${GREEN}SSL.com$END" || echo -e "${RED}CA切换失败$END"
    ;;
    4)
      $DIR/.acme.sh/acme.sh --set-default-ca --server zerossl &&
      echo -e "CA已经切换为：${GREEN}zerossl$END" || echo -e "${RED}CA切换失败$END"
    ;;
    *)
      echo -e "${RED}请重新输入$END"
  esac
}
#注册acme账户
register_acme(){
  read -e -p "请输入你的Email地址：" input
  $DIR/.acme.sh/acme.sh --register-account -m $input &&
  echo -e "${GREEN}注册成功$END" || echo -e "${RED}注册失败$END"
}
#使用ipv4的80端口申请证书
80_acme_v4(){
  echo -e "${RED}请确保80端口没有被占用$END"
  check_port
  read -e -p "请输入域名：" input
  $DIR/.acme.sh/acme.sh  --issue -d $input --standalone
  if [ $? -eq 0 ];then
    echo -e "${GREEN}域名：$input 的证书申请成功$END" 
    [ -d $SSL/$input ] || mkdir -p $SSL/$input
    $DIR/.acme.sh/acme.sh --installcert -d $input --fullchain-file $SSL/$input/cret.crt --key-file $SSL/$input/private.key &&
  echo -e "证书安装路径：
  证书公钥路径：${GREEN}$SSL/$input/cret.crt$END
  证书私钥路径：${RED}$SSL/$input/private.key$END"
  else
    echo -e "${RED}域名：$input 的证书申请失败$END"
  fi
}
#使用ipv6的80端口申请证书
80_acme_v6(){
  echo -e "${RED}请确保80端口没有被占用$END"
  check_port
  read -e -p "请输入域名：" input
  $DIR/.acme.sh/acme.sh  --issue -d $input --standalone --listen-v6
  if [ $? -eq 0 ];then
    echo -e "${GREEN}域名：$input 的证书申请成功$END" 
    [ -d $SSL/$input ] || mkdir -p $SSL/$input
    $DIR/.acme.sh/acme.sh --installcert -d $input --fullchain-file $SSL/$input/cret.crt --key-file $SSL/$input/private.key &&
  echo -e "证书安装路径：
  证书公钥路径：${GREEN}$SSL/$input/cret.crt$END
  证书私钥路径：${RED}$SSL/$input/private.key$END"
  else
    echo -e "${RED}域名：$input 的证书申请失败$END"
  fi
}
#使用cloudflare的api申请泛域名证书，貌似免费的域名不可用
cf_api(){
  echo -e "${YELLOW}免费的域名不可以用Cloudflare的api申请证书，比如 .cf .tk .ml .ga .gq 结尾的域名$END"
  echo -e "${YELLOW}请确保cloudflare的API是生效的$END"
  read -e -p "请输入你要申请的域名：" domain
  read -p "请输入cloudflare的邮箱：" email
  export CF_Email="$email"
  read -e -p "请输入cloudflare账户的API：" api
  export CF_Key="$api"
  $DIR/.acme.sh/acme.sh --issue -d "$domain" -d "*.$domain" --dns dns_cf --ecc
  if [ $? -eq 0 ];then
    echo -e "${GREEN}域名：$domain 的证书申请成功$END" 
    [ -d $SSL/$domain ] || mkdir -p $SSL/$domain
    $DIR/.acme.sh/acme.sh --installcert -d $domain -d *.$domain --fullchainpath $SSL/$domain/$domain.crt --keypath $SSL/$domain/$domain.key –ecc &&
  echo -e "证书安装路径：
  证书公钥路径：${GREEN}$SSL/$domain/$domain.crt$END
  证书私钥路径：${RED}$SSL/$domain/$domain.key$END"
  else
    echo -e "${RED}域名：$domain 的证书申请失败$END"
  fi 
}
#设置acme脚本自动更新
update_acme(){
  $DIR/.acme.sh/acme.sh  --upgrade  --auto-upgrade && echo -e "${GREEN}自动更新设置完成$END"
}
#花里胡哨的循环菜单
while :;do
  echo "欢迎使用ナルト开发的证书申请脚本"
  echo -e "$OTHER功能如下：
  q -- 退出脚本
------------------------------------------
------------------------------------------
  1 -- 安装 Acme 脚本
  2 -- 改变 CA 提供商
  3 -- 注册 Acme 账号
  4 -- 使用 ipv4的 80 端口申请域名证书
  5 -- 使用 ipv6的 80 端口申请域名证书
  6 -- 使用Cloudflare API 申请域名证书
  7 -- 设置 Acme 自动更新$END"
  read -n 1 -p "请选择：" menu
  case $menu in
    q|Q)
      echo
      break;;
    1)
      echo
      install_acme;;
    2)
      echo
      change_ca;;
    3)
      echo
      register_acme;;
    4)
      echo
      80_acme_v4;;
    5)
      echo
      80_acme_v6;;
    6)
      echo
      cf_api;;
    7)
      echo
      update_acme;;
    *)
      echo
      echo -e "${RED}请重新输入$END"
  esac
done
