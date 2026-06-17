#!/bin/bash

set -e

APP=/opt/hax-bot-6.4

echo "🚀 HAX BOT ONE-CLICK INSTALL"

# 1. 基础环境
apt update -y
apt install -y python3 python3-pip python3-venv git curl

# 2. 清理旧版本
rm -rf $APP

# 3. clone（不会要用户名）
git clone https://github.com/mingyueqianli/hax-bot-6.4.git $APP

cd $APP

# 4. python环境
python3 -m venv venv
source venv/bin/activate

pip install -r requirements.txt

mkdir -p data logs

# 5. 自动配置（不交互）
TOKEN=${TOKEN:-"test_token"}
INTERVAL=${INTERVAL:-30}

echo $TOKEN > token.txt
echo $INTERVAL > interval.txt

# 6. 启动
nohup python -m app.collector.runner > logs/collector.log 2>&1 &
nohup python -m app.bot.main > logs/bot.log 2>&1 &

echo "================================"
echo "✅ INSTALL DONE"
echo "TOKEN: $TOKEN"
echo "INTERVAL: $INTERVAL"
echo "================================"
