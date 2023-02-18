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
  yum install build-essential libreadline-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev -y
else
  apt update
  apt install build-essential libreadline-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev -y
fi
#安装主体
echo -e "\e[1;33m请输入你要下载的python版本\e[0m:
例如：
\e[1;31m3.11.2  3.10.3  3.9.13  3.8.13  3.7.10\e[0m"
read -e -p "请输入：" version
wget https://www.python.org/ftp/python/$version/Python-$version.tgz
[ ! $? -eq 0 ] && echo -e "\e[1;31m请输入正确的python版本!!!\e[0m" && exit 1
tar -zxf Python-$version.tgz && rm -rf Python-$version.tgz
cd Python-$version
./configure --prefix=/usr/local/python$version
make
make install
if [ $? -eq 0 ];then
  clear
  echo -e "\e[1;32m安装成功！\e[0m"
  ln -s /usr/local/python$version /usr/local/bin/python3
  echo "python 版本为："
  python3 -V
else
  clear
  echo -e "\e[1;31m安装失败！\e[0m" && exit 1
fi
