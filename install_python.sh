#! /bin/bash
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
#安装相关依赖
if [ $os -eq "centos" ];then
  yum update
  yum install -y wget make
  yum groupinstall "Development Tools"
else
  apt update
  apt install -y wget make build-essential
fi
#安装主体
wget https://www.python.org/ftp/python/3.11.2/Python-3.11.2.tgz
tar -zxf Python-3.11.2.tgz && rm -rf Python-3.11.2.tgz
cd Python-3.11.2
./configure --prefix=/usr/local/python311
make
make install
if [ $? -eq 0 ];then
  clear
  echo -e "\e[1;32m安装成功！\e[0m"
  ln -s /usr/local/python311 /usr/local/bin/python3
  echo "python 版本为："
  python3 -V
else
  clear
  echo -e "\e[1;31m安装失败！\e[0m" && exit 1
fi
