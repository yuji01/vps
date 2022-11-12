#!/bin/bash
RED="\e[1;31m"
GREEN="\e[1;32m"
OTHER="\e[1;$[RANDOM%7+31]m"
END="\e[0m"
#安装脚本的路径
DIR=`pwd ~`
#安装证书的路径
SSL='/ssl'
#系统判断及安装相关的依赖
os_check(){
apt &> /dev/null && OS='debian' || OS='centos'
case $OS in
  debian)
    apt update && apt install socat
  ;;
  centos)
    yum update && yum install socat
esac
}
#安装acme脚本
install_acme(){
  echo -e "${RED}Acme脚本默认安装在${DIR}$END"
  os_check &&
  cd $DIR
  curl https://get.acme.sh | sh
  [ -d $DIR/.acme.sh ] && echo -e "${GREEN}安装成功$END" || echo -e "${RED}安装失败$END"
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
  read -p "请输入你的Email地址：" input
  $DIR/.acme.sh/acme.sh --register-account -m $input &&
  echo -e "${GREEN}注册成功$END" || echo -e "${RED}注册失败$END"
}
#使用ipv4的80端口申请证书
80_acme_v4(){
  echo -e "${RED}请确保80端口没有被占用$END"
#干掉占用80端口的程序
kill `netstat -lnpt |grep 80|grep -oE '[0-9]+/'|grep -oE '[0-9]+'`
  read -p "请输入域名：" input
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
#干掉占用80端口的程序
kill `netstat -lnpt |grep 80|grep -oE '[0-9]+/'|grep -oE '[0-9]+'`
  read -p "请输入域名：" input
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
  echo -e "${RED}请确保cloudflare的API是生效的$END"
  read -p "请输入cloudflare的API：" api
  export CF_Key="$api"
  read -p "请输入cloudflare的邮箱：" email
  export CF_Email="$email"
  read -p "请输入你要申请的域名：" domain
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
  echo -e "$OTHER功能如下：
  0 -- 退出脚本
  1 -- 安装 Acme 脚本
  2 -- 改变 CA 提供商
  3 -- 注册 Acme 账号
  4 -- 使用 ipv4的 80 端口申请证书
  5 -- 使用 ipv6的 80 端口申请证书
  6 -- 使用cloudflare API 申请泛域名证书
  7 -- 设置 Acme 自动更新$END"
  read -n 1 -p "请选择：" menu
  case $menu in
    0)
      echo
      break
    ;;
    1)
      echo
      install_acme
    ;;
    2)
      echo
      change_ca
    ;;
    3)
      echo
      register_acme
    ;;
    4)
      echo
      80_acme_v4
    ;;
    5)
      echo
      80_acme_v6
    ;;
    6)
      echo
      cf_api
    ;;
    7)
      echo
      update_acme
    ;;
    *)
      echo
      echo -e "${RED}请重新输入$END"
  esac
done
