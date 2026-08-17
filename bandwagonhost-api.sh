#!/bin/bash
# apt-get install -y curl jq bc
# ================= 配置区域 =================
# https://kiwivm.64clouds.com/auth-login
VEID=""
API_KEY=""

# Apprise 服务地址（例如：http://localhost:8000/notify/your-config-id）
APPRISE_URL=""
# ===========================================

# 1. 请求 API
JSON=$(curl -s "https://api.64clouds.com/v1/getServiceInfo?veid=${VEID}&api_key=${API_KEY}")

ERR=$(echo "$JSON" | jq -r '.error // -1')
if [ "$ERR" != "0" ]; then
    echo "API 请求失败"
    exit 1
fi

# 2. 解析基础字段
HOSTNAME=$(echo "$JSON" | jq -r '.hostname')
IP=$(echo "$JSON" | jq -r '.ip_addresses[0]')
DATACENTER=$(echo "$JSON" | jq -r '.node_datacenter')
TOTAL_BYTES=$(echo "$JSON" | jq -r '(.plan_monthly_data * (.monthly_data_multiplier // 1))')
USED_BYTES=$(echo "$JSON" | jq -r '.data_counter')
RESET_TS=$(echo "$JSON" | jq -r '.data_next_reset')

# 3. 流量计算 (单位: GB / 保留两位小数)
GIGA=1073741824
USED_GB=$(echo "scale=2; $USED_BYTES / $GIGA" | bc)
TOTAL_GB=$(echo "scale=2; $TOTAL_BYTES / $GIGA" | bc)
REMAINING_GB=$(echo "scale=2; $TOTAL_GB - $USED_GB" | bc)

USED_PERCENT=$(echo "scale=2; ($USED_BYTES / $TOTAL_BYTES) * 100" | bc)
REMAINING_PERCENT=$(echo "scale=2; 100 - $USED_PERCENT" | bc)

# 4. 时间格式化与剩余天数计算
NOW_TS=$(date +%s)
CURRENT_TIME=$(date "+%Y年%m月%d日 %H时%M分%S秒")
RESET_TIME=$(date -d "@${RESET_TS}" "+%Y年%m月%d日 %H时%M分%S秒")

DIFF_SEC=$(( RESET_TS - NOW_TS ))
if [ $DIFF_SEC -le 0 ]; then
    REMAINING_TIME_STR="0天0小时0分"
    DAILY_GB="0.00"
else
    DAYS=$(( DIFF_SEC / 86400 ))
    HOURS=$(( (DIFF_SEC % 86400) / 3600 ))
    MINS=$(( (DIFF_SEC % 3600) / 60 ))
    SECS=$(( DIFF_SEC % 60 ))
    REMAINING_TIME_STR="${DAYS}天${HOURS}小时${MINS}分${SECS}秒"

    DAILY_GB=$(echo "scale=2; $REMAINING_GB / ($DIFF_SEC / 86400)" | bc)
fi

# 5. 拼接纯文本 INFO
INFO="${HOSTNAME}流量使用情况

IP: ${IP}
机房: ${DATACENTER}

已用：${USED_GB} GB (${USED_PERCENT}%)
剩余：${REMAINING_GB} GB (${REMAINING_PERCENT}%)
平均：${DAILY_GB} GB/天

总流量：${TOTAL_GB} GB
重置倒计时：${REMAINING_TIME_STR}

重置时间：${RESET_TIME}
当前时间：${CURRENT_TIME}
"

# 本地终端直接输出测试
echo "$INFO"

# 6. 推送到 Apprise (支持 JSON 格式提交)
curl -X POST \
  --data-urlencode "tag=all" \
  --data-urlencode "title=搬瓦工服务器流量推送" \
  --data-urlencode "body=$INFO" \
  "$APPRISE_URL"
