#! /bin/bash
# 系统检测
if [[ ! -z "`cat /etc/issue | grep -iE "debian"`" ]]; then
    os="debian"
elif [[ ! -z "`cat /etc/issue | grep -iE "ubuntu"`" ]]; then
    os="ubuntu"
elif [[ ! -z "`cat /etc/redhat-release | grep -iE "CentOS"`" ]]; then
    os="centos"
else
    echo -e "很抱歉，你的系统不受支持!" && exit 1
fi
# 安装相关依赖
if [[ $os == "centos" ]];then
    yum update -y
    rpm -qa|grep python3|xargs rpm -ev --allmatches --nodeps
    whereis python3 |xargs rm -frv
    yum install -y wget yum-utils make
    yum-builddep python3 -y
else
    apt update
    # apt-get --purge remove python3 python3-pip -y
    apt install wget build-essential libreadline-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev -y
fi
#安装主体
echo -e "\e[1;33m请输入你要下载的python版本\e[0m:
例如：
\e[1;31m3.11.2  3.10.3  3.9.13  3.8.13  3.7.10\e[0m"
read -e -p "请输入：" python_version

# 下载文件
wget https://www.python.org/ftp/python/${python_version}/Python-${python_version}.tgz -O /tmp/Python-${python_version}.tgz

[ ! $? -eq 0 ] && echo -e "\e[1;31m请输入正确的python版本!!!\e[0m" && exit 1
# 解压文件
tar -xf /tmp/Python-${python_version}.tgz -C /tmp

# 删除压缩文件
rm -rf /tmp/Python-${python_version}.tgz

cd /tmp/Python-${python_version} 

# 配置文件
./configure --enable-optimizations
#./configure --prefix=/usr/local/python3 --enable-optimizations

make -j $(nproc) && echo "编译成功" || echo "编译失败"
make altinstall

if [ $? -eq 0 ];then
    py_version=$(echo $python_version | cut -d . -f1,2)

    # 创建链接
    ln -s /usr/local/bin/python${py_version} /usr/bin/python3
    ln -s /usr/local/bin/python${py_version} /usr/bin/python

    # 安装pip
    wget https://bootstrap.pypa.io/get-pip.py
    python3 get-pip.py
    pip --version && echo "pip 安装成功" || echo "安装失败"
    echo -e "python 版本： $(python3 -V)，pip版本: $(pip3 -V)"
else
    clear
    echo -e "\e[1;31m安装失败！\e[0m" && exit 1
fi
