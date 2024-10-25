# !/bin/bash
# 星辰使用

# 更新dns为nat64
cat > /etc/resolv.conf <<EOF
nameserver 2001:67c:2b0::4
nameserver 2001:67c:2b0::6
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF

apt update > /dev/null 2>&1
apt install wget -y > /dev/null 2>&1

# 更新geoip文件
wget -q https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat -O /etc/V2bX/geoip.dat
wget -q https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat -O /etc/V2bX/geosite.dat
echo "任务完成"
