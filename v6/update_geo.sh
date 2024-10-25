# !/bin/bash
# 星辰使用

# 更新dns为nat64
cat > /etc/resolv.conf <<EOF
nameserver 2001:67c:2b0::4
nameserver 2001:67c:2b0::6
EOF


apt update
apt install wget -y

# 更新geoip文件
wget https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat -O /etc/XrayR/geoip.dat
wget https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat -O /etc/XrayR/geosite.dat
echo "任务完成"
