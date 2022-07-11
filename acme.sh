#!/bin/bash
RED="\e[1;31m"
GREEN="\e[1;32m"
OTHER="\e[1;$[RANDOM%7+31]m"
END="\e[0m"
DIR=`pwd ~`
SSL='/ssl'
install_acme(){
  echo -e "${RED}Acme脚本将安装在用户家目录$END"
  cd $DIR
  curl https://get.acme.sh | sh
  [ -d $DIR/.acme.sh ] && echo -e "${GREEN}安装成功$END" || echo -e "${RED}安装失败$END"
}
change_ca(){
  echo -e "CA提供商如下：
  1  ---  Let's Encrypt
  2  ---  ZeroSSL"
  read -n 1 -p "请输入数字：" input
  case $input in
    1)
      $DIR/.acme.sh/acme.sh --set-default-ca --server letsencrypt &&
      echo -e "CA已经切换为：${RED}letsencrypt$END" || echo -e "${RED}CA切换失败$END"
    ;;
    2)
      $DIR/.acme.sh/acme.sh --set-default-ca --server zerossl &&
      echo -e "CA已经切换为：${RED}zerossl$END" || echo -e "${RED}CA切换失败$END"
    ;;
    *)
      echo -e "${RED}请重新输入$END"
  esac
}
register_acme(){
  read -p "请输入你的Email地址：" input
  $DIR/.acme.sh/acme.sh --register-account -m $input &&
  echo -e "${GREEN}注册成功$END" || echo -e "${RED}注册失败$END"
}
80_acme(){
  echo -e "${RED}请确保80端口没有被占用$END"
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
cf_api(){
  echo -e "${RED}请确保cloudflare的API是生效的$END"
  read -p "请输入cloudflare的API：" api
  export CF_Key="$api"
  read -p "请输入cloudflare的邮箱：" email
  export CF_Email="$email"
  read -p "请输入你要申请的域名：" domain
  $DIR/.acme.sh/acme.sh --issue --dns dns_cf -d $domain -d *.$domain -k ec-256
  if [ $? -eq 0 ];then
    echo -e "${GREEN}域名：$domain 的证书申请成功$END" 
    [ -d $SSL/$domain ] || mkdir -p $SSL/$domain
    $DIR/.acme.sh/acme.sh --installcert -d $domain -d *.${domain} --fullchainpath $SSL/$domain/$domain.crt --keypath $SSL/$domain/$domain.key –ecc &&
  echo -e "证书安装路径：
  证书公钥路径：${GREEN}$SSL/$domain/$domain.crt$END
  证书私钥路径：${RED}$SSL/$domain/$domain.key$END"
  else
    echo -e "${RED}域名：$domain 的证书申请失败$END"
  fi 
}
update_acme(){
  $DIR/.acme.sh/acme.sh  --upgrade  --auto-upgrade && echo -e "${GREEN}自动更新设置完成$END"
}

while :;do
  echo -e "$OTHER功能如下：
  0 -- 退出脚本
  1 -- 安装 Acme 脚本
  2 -- 改变 CA 提供商
  3 -- 注册 Acme 账号
  4 -- 使用 80 端口申请证书
  5 -- 使用cloudflare API 申请泛域名证书
  6 -- 设置 Acme 自动更新$END"
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
      80_acme
    ;;
    5)
      echo
      cf_api
    ;;
    6)
      echo
      update_acme
    ;;
    *)
      echo
      echo -e "${RED}请重新输入$END"
  esac
done
