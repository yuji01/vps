#!/bin/bash
RED="\e[1;31m"
GREEN="\e[1;32m"
END="\e[0m"
DIR=`pwd ~`
SSL='/ssl'
install_acme(){
  echo -e "${RED}acme will be installed in the user's home directory$END"
  cd $DIR
  curl https://get.acme.sh | sh -s email=my@example.com &&
  echo -e "${GREEN}安装成功$END" || echo -e "${RED}安装失败$END"
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
  $DIR/.acme.sh/acme.sh  --issue -d $input --standalone &&
  echo -e "${GREEN}域名：$input的证书申请成功$END" ||
  echo -e "${RED}域名：$input的证书申请失败$END"
  [ -e $SSL/$input ] || mkdir -p $SSL/$input
  ~/.acme.sh/acme.sh --installcert -d $input --fullchain-file $SSL/$input/cret.crt --key-file $SSL/$input/private.key
}
update_acme(){
  $DIR/.acme.sh/acme.sh  --upgrade  --auto-upgrade && echo "自动更新设置完成"
}

while :;do
  echo -e "功能如下：
  0 -- 退出脚本
  1 -- 安装 Acme 脚本
  2 -- 改变 CA 提供商
  3 -- 注册 Acme 账号
  4 -- 使用 80 端口申请证书
  5 -- 设置 Acme 自动更新"
  read -n 1 -p "请选择：" menu
  case $menu in
    0)
      break
    ;;
    1)
      install_acme
    ;;
    2)
      change_ca
    ;;
    3)
      register_acme
    ;;
    4)
      80_acme
    ;;
    5)
      update_acme
    ;;
    *)
      echo -e "${RED}请重新输入$END"
  esac
done
