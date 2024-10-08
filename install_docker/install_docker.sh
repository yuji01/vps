#! /bin/bash
#安装官方docker
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
install_docker(){
case $os in
  debian)
    apt-get remove docker docker-engine docker.io containerd runc;
    apt-get update &&
    apt-get install -y ca-certificates curl gnupg lsb-release &&
    mkdir -p /etc/apt/keyrings &&
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg &&
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null &&
    apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ;;
  ubuntu)
    apt-get remove docker docker-engine docker.io containerd runc;
    apt-get update &&
    apt-get install -y ca-certificates curl gnupg lsb-release &&
    mkdir -p /etc/apt/keyrings &&
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg &&
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null &&
    apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ;;
  centos)
    yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine;
    yum install -y yum-utils &&
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo &&
    yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
esac
# 安装docker-compose
if [ $? -eq 0 ];then
  curl -L https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose &&
  chmod +x /usr/local/bin/docker-compose
fi
}
change_config(){
#修改docker配置文件
cat > /etc/docker/daemon.json <<\EOF
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "20m",
        "max-file": "3"
    },
    "ipv6": true,
    "fixed-cidr-v6": "fd00:dead:beef:c0::/80",
    "experimental":true,
    "ip6tables":true
}
EOF
}
start_docker(){
# 设置docker重启
systemctl daemon-reload
systemctl enable docker.socket
systemctl enable docker
systemctl restart docker
}
#执行
check_os
install_docker &&
change_config &&
start_docker &&
echo -e "\e[1;32mdocker 安装完成\e[0m" || echo -e "\e[1;31mdocker 安装失败\e[0m"
