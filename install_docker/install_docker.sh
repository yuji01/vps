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
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-doc podman-docker containerd runc | cut -f1)
# Add Docker's official GPG key:
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    ;;
  ubuntu)
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)
# Add Docker's official GPG key:
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

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
