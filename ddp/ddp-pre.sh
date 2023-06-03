# !/bin/bash
# ddp重装系统后的预处理命令
# 重装系统建议用Debian 10、Ubuntu 20.04，Debian 11和Ubuntu的22.04都有点毛病

nezha(){
#安装哪吒的命令
curl -L https://raw.githubusercontent.com/naiba/nezha/master/script/install.sh -o nezha.sh && chmod +x nezha.sh && sudo ./nezha.sh install_agent api.nezha.vps.yuji2022.eu.org 5555 69a7debabbe1114f33
}

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

# 停止apache
systemctl stop apache2
systemctl stop apache
systemctl disable apache2
systemctl disable apache

if [ "$os" != "centos" ]; then
    # 卸载ddp自带的apache
    apt-get --purge remove apache2 \
    apt-get --purge remove apache2.2-common \
    apt-get --purge remove apache2-common \
    apt-get --purge remove apache2-doc \
    apt-get --purge remove apache2-utils \
    apt-get --purge remove apache2-bin \
    apt-get --purge remove apache2-data \
    dpkg -l | grep apache2 \
    apt-get autoremove \
    find /etc -name "*apache*" |xargs  rm -rf \
    rm -rf /var/www \
    rm -rf /etc/libapache2-mod-jk \
    # 安装必要的工具
    apt update && apt install -y curl vim ufw screen wget git
else
    yum update -y && yum install -y curl vim screen wget git
fi

# 主菜单
check_os
nezha
