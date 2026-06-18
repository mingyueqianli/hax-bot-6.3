#!/bin/bash
set -e
APP_DIR="${APP_DIR:-/opt/hax-bot}"

echo "===== config ====="
if [ -f "$APP_DIR/interval.txt" ]; then
  echo "Interval: $(cat "$APP_DIR/interval.txt") 秒"
else
  echo "Interval: 未找到 $APP_DIR/interval.txt"
fi

echo ""
echo "===== systemd ====="
systemctl status hax-bot.service hax-bot-collector.service --no-pager || true

echo ""
echo "===== logs ====="
echo "Bot log:       $APP_DIR/logs/bot.log"
echo "Collector log: $APP_DIR/logs/collector.log"
echo ""
echo "最近 collector 日志："
tail -n 30 "$APP_DIR/logs/collector.log" 2>/dev/null || true
