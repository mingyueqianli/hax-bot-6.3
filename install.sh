#!/bin/bash

set -e

APP=/opt/hax-bot-6.6

echo "🚀 HAX BOT 6.6 INSTALL FIXED"

apt update -y
apt install -y python3 python3-pip python3-venv git

rm -rf $APP

# ✔ 强制clone到固定目录
git clone https://github.com/mingyueqianli/HAX-BOT-6.6.git $APP

# ✔ 强制进入目录（关键）
cd $APP || exit 1

echo "📂 当前目录: $(pwd)"
ls -l requirements.txt

python3 -m venv venv
source venv/bin/activate

pip install -r requirements.txt

mkdir -p data logs

# =====================
# 输入区
# =====================
exec < /dev/tty

echo "=================="
read -p "TOKEN: " TOKEN
echo $TOKEN > token.txt

echo "=================="
read -p "INTERVAL(default30): " INTERVAL
INTERVAL=${INTERVAL:-30}
echo $INTERVAL > interval.txt

# =====================
# 启动
# =====================
nohup python -m app.collector.runner > logs/collector.log 2>&1 &
nohup python -m app.bot.main > logs/bot.log 2>&1 &

echo "✅ INSTALL DONE"
