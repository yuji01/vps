#! /bin/bash
#系统检测
if [[ ! -z "`cat /etc/issue | grep -iE "debian"`" ]]; then
  os="debian"
elif [[ ! -z "`cat /etc/issue | grep -iE "ubuntu"`" ]]; then
  os="ubuntu"
elif [[ ! -z "`cat /etc/redhat-release | grep -iE "CentOS"`" ]]; then
  os="centos"
else
  echo -e "${RED}很抱歉，你的系统不受支持!" && exit 1
fi
#安装相关依赖
if [[ $os == "centos" ]];then
  yum update -y
  rpm -qa|grep python3|xargs rpm -ev --allmatches --nodeps
  whereis python3 |xargs rm -frv
  yum install -y wget yum-utils make
  yum-builddep python3 -y
else
  apt update
  apt-get --purge remove python3 python3-pip -y
  apt install wget build-essential libreadline-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev -y
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
./configure --prefix=/usr/local/python3 --enable-optimizations
make
make install
if [ $? -eq 0 ];then
  clear
  echo -e "\e[1;32m安装成功！\e[0m"
  rm -f /usr/bin/python3
  rm -f /usr/bin/pip3
  ln -s /usr/local/python3/bin/python3 /usr/local/bin/python3
  ln -s /usr/local/python3/bin/pip3 /usr/local/bin/pip3
  echo "python 版本为："
  python3 -V && pip3 -V
else
  clear
  echo -e "\e[1;31m安装失败！\e[0m" && exit 1
fi
