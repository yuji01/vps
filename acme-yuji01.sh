#!/bin/bash
RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
PINK="\e[1;35m"
QING="\e[1;36m"
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
install_acme(){
#安装acme脚本
  echo -e "${RED}Acme脚本默认安装在${DIR}$END"
  check_system &&
  cd $DIR
  curl https://get.acme.sh | sh
  [ -f $DIR/.acme.sh/acme.sh ] && echo -e "${GREEN}安装成功$END" || echo -e "${RED}安装失败$END"
}
change_ca(){
#改变ca提供商
  echo -e "默认使用 ZeroSSL，可切换的CA提供商如下：
  1  ---  Let's Encrypt
  2  ---  Buypass
  3  ---  SSL.com
  4  ---  ZeroSSL"
  read -n 1 -p "请输入数字：" input
  case $input in
    1)
      $DIR/.acme.sh/acme.sh --set-default-ca --server letsencrypt && register_acme &&
      echo -e "CA已经切换为：${GREEN}Let's Encrypt$END" || echo -e "${RED}CA切换失败$END";;
    2)
      $DIR/.acme.sh/acme.sh --set-default-ca --server buypass && register_acme &&
      echo -e "CA已经切换为：${GREEN}Buypass$END" || echo -e "${RED}CA切换失败$END";;
    3)
      $DIR/.acme.sh/acme.sh --set-default-ca --server ssl.com && register_acme &&
      echo -e "CA已经切换为：${GREEN}SSL.com$END" || echo -e "${RED}CA切换失败$END";;
    4)
      $DIR/.acme.sh/acme.sh --set-default-ca --server zerossl && register_acme &&
      echo -e "CA已经切换为：${GREEN}zerossl$END" || echo -e "${RED}CA切换失败$END";;
    *)
      echo -e "${RED}请重新输入$END"
  esac
}
register_acme(){
#设置域名提醒账户
  read -e -p "请输入你的Email地址：" email
  $DIR/.acme.sh/acme.sh --register-account -m $email &&
  echo -e "${GREEN}账户设置成功$END" || echo -e "${RED}账户设置成功$END"
}
install_cert(){
#安装申请好的证书
  if [ $? -eq 0 ];then
    echo -e "${GREEN}域名：$domain 的证书申请成功$END"
    #文件夹不存在就创建它
    [ -d $SSL/$domain ] || mkdir -p $SSL/$domain
    $DIR/.acme.sh/acme.sh --installcert -d $domain --fullchain-file $SSL/$domain/cret.crt --key-file $SSL/$domain/private.key &&
    #给申请的证书赋予可读权限
    chmod +r $SSL/$domain/cret.crt && chmod +r $SSL/$domain/private.key &&
  echo -e "证书安装路径：
  证书公钥路径：${GREEN}$SSL/$domain/cret.crt$END
  证书私钥路径：${RED}$SSL/$domain/private.key$END"
  else
    echo -e "${RED}域名：$domain 的证书申请失败$END"
  fi
}
install_cert_manual(){
#手动安装证书
 read -e -p "请输入域名：" domain
 #文件夹不存在就创建它
  [ -d $SSL/$domain ] || mkdir -p $SSL/$domain
  $DIR/.acme.sh/acme.sh --installcert -d $domain --fullchain-file $SSL/$domain/cret.crt --key-file $SSL/$domain/private.key &&
  #给申请的证书赋予可读权限
  chmod +r $SSL/$domain/cret.crt && chmod +r $SSL/$domain/private.key &&
  if [ $? -eq 0 ];then
  echo -e "证书安装路径：
  证书公钥路径：${GREEN}$SSL/$domain/cret.crt$END
  证书私钥路径：${RED}$SSL/$domain/private.key$END"
  else
    echo -e "${RED}域名：$domain 的证书安装失败$END"
  fi
}
check_port(){
#检测80端口是否被占用
if [ -z `lsof -i:80` ];then
  echo -e "${GREEN}80端口没被占用，可以继续申请域名${END}
  但是要注意要${YELLOW}打开防火墙的80端口${END}哦"
else
  for i in {1..3};do
    echo -e "${RED}80端口疑似被占用，很大可能会申请失败，可选择其他方式申请证书${END}"
  done
  echo -e "提示：
  可使用${YELLOW} lsof -i:80 ${END}查看占用80端口的程序"
fi
}
acme_v4_80(){
#使用ipv4的80端口申请证书
  echo -e "${YELLOW}请确保80端口没有被占用$END"
  check_port
  read -e -p "请输入域名：" domain
  $DIR/.acme.sh/acme.sh  --issue -d $domain --standalone
  install_cert
}
acme_v6_80(){
#使用ipv6的80端口申请证书
  echo -e "${YELLOW}请确保80端口没有被占用$END"
  check_port
  read -e -p "请输入域名：" domain
  $DIR/.acme.sh/acme.sh  --issue -d $domain --standalone --listen-v6
  install_cert
}
acme_nginx(){
#使用nginx模式申请证书
  echo -e "${YELLOW}这种方法需要运行Nginx$END"
  read -e -p "请输入你要申请的域名：" domain
  $DIR/.acme.sh/acme.sh --issue --nginx -d $domain
  install_cert
}
acme_apache(){
#使用apache申请证书
  echo -e "${YELLOW}这种方法需要运行Apache$END"
  read -e -p "请输入你要申请的域名：" domain
  $DIR/.acme.sh/acme.sh --issue --apache -d $domain
  install_cert
}
acme_webroot(){
#使用webroot申请证书
  echo -e "${YELLOW}这种方式需要配置web服务器$END"
  echo -e "${YELLOW}验证的默认html站点为：${END} ${RED}/var/www/html${END}"
  echo -e "是否修改站点？请输入${RED}y/n${END}"
  read -e -p "请输入：" input
  case $input in
    Y|y)
      read -e -p "请输入你的html站点：" web_html;;
    *)
      web_html="/var/www/html"
  esac
  echo -e "${YELLOW}验证的默认站点为：$END ${RED}${web_html}$END"
  read -e -p "请输入你要申请的域名：" domain
  $DIR/.acme.sh/acme.sh --issue -d $domain -w $web_html
  install_cert
}
acme_cf_api(){
#使用cloudflare的api申请泛域名证书
  echo -e "${YELLOW}提示：
  1. 默认是申请泛域名证书
  2. 以 .cf .tk .ml .ga .gq 结尾的域名不可申请
  3. 输入的域名不用加*，例如：\"narutos.eu.org\"
  4. 请确保cloudflare的API是生效的
  5. 建议用\"Global API Key\" $END"
  read -e -p "请输入你要申请的域名：" domain
  read -p "请输入cloudflare的邮箱：" cloudflare_email
  export CF_Email="$cloudflare_email"
  read -e -p "请输入cloudflare账户的API：" cloudflare_api
  export CF_Key="$cloudflare_api"
  $DIR/.acme.sh/acme.sh --dns dns_cf --issue -d "*.$domain" -d $domain
# 安装泛域名证书
  [ -d $SSL/$domain ] || mkdir -p $SSL/$domain
  $DIR/.acme.sh/acme.sh --installcert -d *.$domain --fullchain-file $SSL/$domain/cret.crt --key-file $SSL/$domain/private.key &&
  #给申请的证书赋予可读权限
  chmod +r $SSL/$domain/cret.crt && chmod +r $SSL/$domain/private.key &&
  if [ $? -eq 0 ];then
  echo -e "证书安装路径：
  泛域名证书公钥路径：${GREEN}$SSL/$domain/cret.crt$END
  泛域名证书私钥路径：${RED}$SSL/$domain/private.key$END"
  else
    echo -e "${RED}泛域名：$domain 的证书安装失败$END"
  fi
}
acme_dns_manual_mode(){
#使用dns手动验证方式申请证书
  echo -e "${YELLOW}这种方式需要手动去添加txt记录进行验证$END"
  read -e -p "请输入你要申请的域名：" domain
  $DIR/.acme.sh/acme.sh --issue --dns -d $domain --yes-I-know-dns-manual-mode-enough-go-ahead-please
  echo -e "${RED}请手动添加txt记录进行验证!!!$END"
  echo -e "${YELLOW}验证结束请输入$END ${RED}y${END}"
  echo -e "${YELLOW}是否正确添加txt记录？${END}"
  read -e -p "请输入：" input
  case $input in
    Y|y)
      $DIR/.acme.sh/acme.sh --renew -d $domain --yes-I-know-dns-manual-mode-enough-go-ahead-please;;
    *)
      echo -e "${RED}输入错误，请重新输入$END"
  esac
  install_cert
}
remove_cert(){
# 删除证书
  echo -e "$YELLOW请输入你要移除证书的域名$END"
  read -e -p "请输入域名：" domain
  $DIR/.acme.sh/acme.sh --revoke -d *.$domain
  $DIR/.acme.sh/acme.sh --remove -d *.$domain
  $DIR/.acme.sh/acme.sh --revoke -d $domain &&
  $DIR/.acme.sh/acme.sh --remove -d $domain &&
  rm -rf $SSL/$domain
  rm -rf $DIR/.acme.sh/$domain*
  [ $? -eq 0 ] && echo -e "$GREEN移除证书成功！$END" || echo -e "$RED移除失败！$END"
}
acme_update(){
#设置acme脚本自动更新
  $DIR/.acme.sh/acme.sh --upgrade --auto-upgrade && echo -e "${GREEN}自动更新设置完成$END"
}
#花里胡哨的循环菜单
while :;do
  echo -e "欢迎使用 ${OTHER}ナルト${END} 开发的证书申请脚本"
  echo -e "功能如下：
  ${RED}0 -- 退出脚本${END}
------------------------------------------
准备部分：
  ${YELLOW}1 -- 安装 Acme 脚本
  2 -- 改变 CA 提供商
  3 -- 注册账号${END}
------------------------------------------
申请证书部分：
  4 -- 使用 ${PINK}ipv4 80 端口${END} 申请域名证书
  5 -- 使用 ${PINK}ipv6 80 端口${END} 申请域名证书
- - - - - - - - - - - - - - - - - - - - - 
  6 -- 使用 ${QING}Webroot${END} 申请域名证书
  7 -- 使用 ${QING}Nginx验证${END} 申请域名证书
  8 -- 使用 ${QING}Apache验证${END} 申请域名证书
- - - - - - - - - - - - - - - - - - - - - 
  9 -- 使用 ${PINK}Cloudflare API${END} 申请泛域名证书
 10 -- 使用 ${PINK}手动验证dns记录${END} 申请域名证书
------------------------------------------
其他设置部分：
 ${GREEN}11 -- 手动安装证书
 12 -- 移除证书
 13 -- 设置 Acme 自动更新$END"
  read -e -p "请选择：" menu
  case $menu in
    0)
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
      acme_v4_80;;
    5)
      echo
      acme_v6_80;;
    6)
      echo
      acme_webroot;;
    7)
      echo
      acme_nginx;;
    8)
      echo
      acme_apache;;
    9)
      echo
      acme_cf_api;;
    10)
      echo
      acme_dns_manual_mode;;
    11)
      echo
      install_cert_manual;;
    12)
      echo
      remove_cert;;
    13)
      echo
      acme_update;;
    *)
      echo
      echo -e "${RED}请重新输入$END"
  esac
done
