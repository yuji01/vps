#! /bin/bash
# 安装官方docker，精简版
# docker-ce：Docker 守护进程，提供容器管理和运行的核心功能。
# docker-ce-cli：Docker 的命令行工具，允许用户通过命令与 Docker 守护进程交互。
# containerd.io：一个容器运行时，负责实际的容器执行和管理，Docker 使用它作为底层的容器引擎。

# docker-buildx-plugin 和 docker-compose-plugin 是 Docker 的两个插件，分别扩展了 Docker 的构建和编排功能。
# 它们不是 Docker 的核心部分，但为构建多架构镜像和管理多容器应用提供了强大的功能。

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
        apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io
        ;;
      ubuntu)
        apt-get remove docker docker-engine docker.io containerd runc;
        apt-get update &&
        apt-get install -y ca-certificates curl gnupg lsb-release &&
        mkdir -p /etc/apt/keyrings &&
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg &&
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null &&
        apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io
        ;;
      centos)
        yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine;
        yum install -y yum-utils &&
        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo &&
        yum install -y docker-ce docker-ce-cli containerd.io
    esac

    # 安装docker-compose
    if [ $? -eq 0 ];then
      curl -L https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose &&
      chmod +x /usr/local/bin/docker-compose
    fi

}
change_config(){
# 减少 journald 日志驱动
cat > /etc/docker/daemon.json <<\EOF
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "1m",
        "max-file": "2"
    }
}
EOF
# 禁用 docker buildx 插件，避免构建相关的开销
mv /usr/libexec/docker/cli-plugins/docker-buildx /usr/libexec/docker/cli-plugins/docker-buildx.disabled

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
