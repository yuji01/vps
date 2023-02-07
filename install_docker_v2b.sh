check_os(){
  if [[ ! -z "`cat /etc/issue | grep -iE "debian"`" ]]; then
    os='debian'
  elif [[ ! -z "`cat /etc/issue | grep -iE "ubuntu"`" ]]; then
    os='ubuntu'
  elif [[ ! -z "`cat /etc/redhat-release | grep -iE "CentOS"`" ]]; then
    os='centos'
  else
    echo -e "${RED}很抱歉，你的系统不受支持!" && exit 1
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
    apt-get update && apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ;;
  ubuntu)
    apt-get remove docker docker-engine docker.io containerd runc;
    apt-get update &&
    apt-get install -y ca-certificates curl gnupg lsb-release &&
    mkdir -p /etc/apt/keyrings &&
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg &&
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null &&
    apt-get update && apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ;;
  centos)
    yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine;
    yum install -y yum-utils &&
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo &&
    yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin    
esac
}
clone_v2b(){
  git clone https://github.com/XrayR-project/XrayR-release /root/xrayr
}
check_os
install_docker
clone_v2b
