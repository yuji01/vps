#!/bin/bash
# 作用：检查dns的速度

# DNS地址的数组
ip_addresses=("1.1.1.1" "8.8.8.8" "119.29.29.29" "223.5.5.5" "180.76.76.76" "180.184.1.1" "101.226.4.6" "1.2.4.8")

# 遍历数组
for ip in "${ip_addresses[@]}"
do
	echo -e "\t\t\t\t\t\t\t\t\t\t${ip}\t\t"
	ping -c 8 "$ip"
done
