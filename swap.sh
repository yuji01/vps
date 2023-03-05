#! /bin/bash
# 设置虚拟内存
[ -d /usr/swap ] || mkdir /usr/swap
read -e -p "输入虚拟内存大小（M）：" size
dd if=/dev/zero of=/usr/swap/swapfile bs=1M count=$size &&
du -sh /usr/swap/swapfile &&
# 格式化为swap
mkswap /usr/swap/swapfile &&
# 设置权限
chmod 0600 /usr/swap/swapfile &&
# 挂载swap
swapon /usr/swap/swapfile &&
# 查看内存
free -m
# 设置开机自启
echo '/usr/swap/swapfile swap swap defaults 0 0' >> /etc/fstab
echo -e "\e[1;32m设置完成\e[0m"
