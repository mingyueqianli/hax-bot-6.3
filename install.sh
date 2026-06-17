#!/bin/bash

set -e

APP=/opt/hax-bot-7.3

echo "🚀 HAX BOT 7.3 终极闭环安装"

# =========================
# 1. 环境
# =========================
apt update -y
apt install -y python3 python3-pip python3-venv git curl

# =========================
# 2. 防重复运行（关键）
# =========================
pkill -f app.bot.main || true
pkill -f app.collector.runner || true

# =========================
# 3. 如果不存在才clone（闭环核心）
# =========================
if [ ! -d "$APP" ]; then
    git clone https://github.com/mingyueqianli/hax-bot-7.2.git $APP
fi

cd $APP

# =========================
# 4. Python环境
# =========================
python3 -m venv venv
source venv/bin/activate

pip install -r requirements.txt

mkdir -p data logs

# =========================
# 5. 关键：强制交互（修复curl问题）
# =========================
exec < /dev/tty

echo "===================="
read -p "🔑 TOKEN: " TOKEN

echo "===================="
read -p "⏱ INTERVAL(默认30): " INTERVAL
INTERVAL=${INTERVAL:-30}

# =========================
# 6. 写入配置
# =========================
echo $TOKEN > token.txt
echo $INTERVAL > interval.txt

# =========================
# 7. 启动（闭环关键）
# =========================
echo "🚀 启动系统..."

nohup python -m app.collector.runner > logs/collector.log 2>&1 &
nohup python -m app.bot.main > logs/bot.log 2>&1 &

# =========================
# 8. 输出状态
# =========================
echo "================================"
echo "✅ HAX BOT 7.3 安装完成（闭环版）"
echo "🔑 TOKEN: 已设置"
echo "⏱ INTERVAL: $INTERVAL"
echo "📦 路径: $APP"
echo "================================"
