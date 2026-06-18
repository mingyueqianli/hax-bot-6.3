#!/bin/bash
set -Eeuo pipefail

APP_DIR="${APP_DIR:-/opt/hax-bot}"
SERVICE_NAME="${SERVICE_NAME:-hax-bot}"
PURGE="${HAX_PURGE:-0}"

if [ "${1:-}" = "--purge" ] || [ "${1:-}" = "-y" ]; then
  PURGE="1"
fi

if [ "${EUID}" -ne 0 ]; then
  echo "请使用 root 用户运行：sudo bash uninstall.sh"
  exit 1
fi

echo "🧹 正在卸载 HAX BOT..."

for svc in "${SERVICE_NAME}.service" "${SERVICE_NAME}-collector.service"; do
  echo "停止服务：$svc"
  systemctl stop "$svc" 2>/dev/null || true
  systemctl disable "$svc" 2>/dev/null || true
done

# 清理残留进程，避免旧进程继续运行。
pkill -f "python.*app.bot.main" 2>/dev/null || true
pkill -f "python.*app.collector.runner" 2>/dev/null || true

rm -f "/etc/systemd/system/${SERVICE_NAME}.service" "/etc/systemd/system/${SERVICE_NAME}-collector.service"
systemctl daemon-reload 2>/dev/null || true
systemctl reset-failed 2>/dev/null || true

if [ -d "$APP_DIR" ]; then
  if [ "$PURGE" = "1" ]; then
    rm -rf "$APP_DIR"
    echo "✅ 已删除应用目录：$APP_DIR"
  else
    read -r -p "是否删除 $APP_DIR 目录和数据？[y/N]: " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
      rm -rf "$APP_DIR"
      echo "✅ 已删除应用目录：$APP_DIR"
    else
      echo "ℹ️ 已保留应用目录：$APP_DIR"
      echo "   如需彻底删除，可执行：rm -rf $APP_DIR"
    fi
  fi
else
  echo "ℹ️ 应用目录不存在：$APP_DIR"
fi

echo "✅ 卸载完成。"
