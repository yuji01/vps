#安装python

apt update && apt install -y wget
wget https://www.python.org/ftp/python/3.11.2/Python-3.11.2.tgz
tar -zxf Python-3.11.2.tgz && rm -rf Python-3.11.2.tgz
cd Python-3.11.2
./configure --prefix=/usr/local/python311 &&
make && echo "编译成功" || {echo "编译失败" , exit 1}
make install && echo "安装成功" || { echo "安装失败" , exit 1 }
ln -s /usr/local/python311 /usr/local/bin/python3
echo "完成"
