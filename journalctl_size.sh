#! /bin/bash

RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
BLUE="\e[1;34m"
PINK="\e[1;35m"
QING="\e[1;36m"
OTHER="\e[1;$[RANDOM%7+31]m"
END="\e[0m"

echo "运行时间： $(date "+%Y-%m-%d %H:%M:%S")"
echo -e "当前日志使用情况： 
${YELLOW}$(journalctl --disk-usage)${END}"

read -e -p "请输入 系统日志可以使用的最大磁盘空间 单位M：" SystemMaxUse
read -e -p "请输入 单个日志文件的最大大小 单位M：" SystemMaxFileSize
read -e -p "请输入 在内存中存储的临时日志的最大空间 单位M：" RuntimeMaxUse
read -e -p "请输入 单个临时日志文件的最大大小 单位M：" RuntimeMaxFileSize
read -e -p "是否清除所有日志？ Y/n：" user_input
cat > /etc/systemd/journald.conf <<EOF
[Journal]
# 设置系统日志可以使用的最大磁盘空间
SystemMaxUse=${SystemMaxUse}M
# 设置单个日志文件的最大大小
SystemMaxFileSize=${SystemMaxFileSize}
# 在内存中存储的临时日志的最大空间
RuntimeMaxUse=${RuntimeMaxUse}M
# 单个临时日志文件的最大大小
RuntimeMaxFileSize=${RuntimeMaxFileSize}

EOF
# journalctl --vacuum-size=${SIZE}M
systemctl restart systemd-journald

if [[ "$user_input" == "y" || "$user_input" == "Y" ]]; then
    # 删除所有超过 1 秒的日志
    journalctl --vacuum-time=1s
    # 强制删除日志文件
    rm -rf /var/log/journal/*
fi

echo -e "设置完成，当前日志使用情况： 
${GREEN}$(journalctl --disk-usage)${END}"

#systemctl kill --kill-who=main --signal=SIGUSR2 systemd-journald.service
