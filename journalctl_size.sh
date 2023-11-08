#! /bin/bash
read -e -p "请输入日志的大小 M" SIZE
cat > /etc/systemd/journald.conf <<EOF
SystemMaxUse=${SIZE}M
EOF
systemctl kill --kill-who=main --signal=SIGUSR2 systemd-journald.service
