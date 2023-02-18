#安装python

apt update && apt install -y wget make build-essential

wget https://www.python.org/ftp/python/3.11.2/Python-3.11.2.tgz
tar -zxf Python-3.11.2.tgz && rm -rf Python-3.11.2.tgz
cd Python-3.11.2
./configure --prefix=/usr/local/python311
make
if [ $? -eq 0 ];then
  clear
  echo "编译成功"
else
  clear
  echo "编译失败" && exit 1
fi
make install
if [ $? -eq 0 ];then
  clear
  echo "安装成功"
else
  clear
  echo "安装失败" && exit 1
fi
ln -s /usr/local/python311 /usr/local/bin/python3
echo "python 版本为："
python3 -V
