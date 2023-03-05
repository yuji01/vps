#! /bin/bash
#设置虚拟内存
if [ -d /usr/swap ];then
  # 取消挂载
  swapoff /usr/swap/swapfile
  # 删除文件
  rm -rf /usr/swap/swapfile
else
  mkdir /usr/swap
fi

read -e -p "输入虚拟内存大小（M）：" size
dd if=/dev/zero of=/usr/swap/swapfile bs=1M count=$size &&
du -sh /usr/swap/swapfile &&
# 设置权限
chmod 0600 /usr/swap/swapfile &&
# 格式化为swap
mkswap /usr/swap/swapfile &&
# 挂载swap
swapon /usr/swap/swapfile &&
# 查看内存
free -m
# 设置开机自启 新建的才写入
[ -z "`cat /etc/fstab|grep '/usr/swap/swapfile'`" ] && echo '/usr/swap/swapfile swap swap defaults 0 0' >> /etc/fstab
echo -e "\e[1;32m设置完成，虚拟内存为 $size M\e[0m"
