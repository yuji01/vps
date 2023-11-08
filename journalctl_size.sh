#! /bin/bash
read -e -p "请输入日志的大小 单位M：" SIZE
cat > /etc/systemd/journald.conf <<EOF
SystemMaxUse=${SIZE}M
RuntimeMaxUse=${SIZE}M
EOF
journalctl --vacuum-size=${SIZE}M
echo "设置完成，journal日志大小为 ${SIZE}M"
systemctl kill --kill-who=main --signal=SIGUSR2 systemd-journald.service
