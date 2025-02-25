#!/bin/bash

# --- 配置部分 ---
DOMAIN="1m1ng.top"  # 你要检测的域名，请替换为你的域名
SERVICE_NAME="phantun-client"     # phantun 服务的 systemd 服务名称，请替换为你的实际服务名
IP_FILE="/opt/phantun/current_ip.txt" # 存储当前IP的文件路径

get_current_ip() {
  # 使用 dig 命令获取域名的 A 记录 IP 地址
  CURRENT_IP=$(dig +short A "$DOMAIN" 2>/dev/null)

  if [ -z "$CURRENT_IP" ]; then
    echo "ERROR: Failed to resolve domain '$DOMAIN'."
    return 1 # 返回非零状态码表示失败
  fi

  echo "$CURRENT_IP"
  return 0 # 返回零状态码表示成功
}

# --- 主逻辑 ---
echo "Starting IP check for domain '$DOMAIN'."

CURRENT_IP=$(get_current_ip)
if [ $? -ne 0 ]; then
  echo "Aborting IP check due to domain resolution failure."
  exit 1
fi

if [ ! -f "$IP_FILE" ]; then
  # 首次运行，记录当前 IP 并退出
  echo "$CURRENT_IP" > "$IP_FILE"
  echo "首次运行，记录当前 IP: $CURRENT_IP"
  exit 0
fi

PREVIOUS_IP=$(cat "$IP_FILE")

if [ "$CURRENT_IP" != "$PREVIOUS_IP" ]; then
  echo "IP 地址发生变化："
  echo "旧 IP: $PREVIOUS_IP"
  echo "新 IP: $CURRENT_IP"

  # 重启 phantun 服务
  echo "正在重启服务 '$SERVICE_NAME'..."
  systemctl restart "$SERVICE_NAME"
  if [ $? -eq 0 ]; then
    echo "服务 '$SERVICE_NAME' 重启成功。"
    # 更新 IP 文件
    echo "$CURRENT_IP" > "$IP_FILE"
    echo "IP 文件已更新为: $CURRENT_IP"
  else
    echo "ERROR: 服务 '$SERVICE_NAME' 重启失败，请检查服务状态。"
  fi
else
  echo "IP 地址未发生变化，当前 IP: $CURRENT_IP"
fi

echo "IP check finished."

exit 0