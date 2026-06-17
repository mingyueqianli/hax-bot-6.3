#!/bin/bash

set -e

APP=/opt/hax-bot-7.2

echo "🚀 HAX BOT 7.2 终极防错安装"

# =========================
# 0. 修复 CRLF（你刚刚那个报错的根）
# =========================
echo "🧹 检测脚本格式..."
sed -i 's/\r$//' "$0" || true

# =========================
# 1. 基础环境
# =========================
apt update -y
apt install -y python3 python3-pip python3-venv git curl dos2unix

# =========================
# 2. 清理旧环境
# =========================
rm -rf $APP

# =========================
# 3. clone（强制稳定）
# =========================
echo "📦 拉取代码..."
git clone https://github.com/mingyueqianli/hax-bot-6.6.git $APP

cd $APP

# =========================
# 4. 再次防CRLF
# =========================
dos2unix install.sh 2>/dev/null || true

# =========================
# 5. Python环境
# =========================
python3 -m venv venv
source venv/bin/activate

pip install -r requirements.txt

mkdir -p data logs

# =========================
# 6. 强制交互恢复（关键）
# =========================
exec < /dev/tty

echo "===================="
echo "请选择模式:"
echo "1) 一键模式"
echo "2) 交互模式"
echo "===================="

read -p "输入: " MODE

if [ "$MODE" = "2" ]; then

    read -p "🔑 TOKEN: " TOKEN
    read -p "⏱ INTERVAL: " INTERVAL

else
    TOKEN="test_token"
    INTERVAL=30
fi

# =========================
# 7. 写入配置
# =========================
echo $TOKEN > token.txt
echo $INTERVAL > interval.txt

# =========================
# 8. 启动保护（防重复）
# =========================
pkill -f app.bot.main || true
pkill -f app.collector.runner || true

echo "🚀 启动系统..."

nohup python -m app.collector.runner > logs/collector.log 2>&1 &
nohup python -m app.bot.main > logs/bot.log 2>&1 &

# =========================
# 9. 完成
# =========================
echo "================================"
echo "✅ HAX BOT 7.2 安装完成"
echo "📂 路径: $APP"
echo "🔑 TOKEN: $TOKEN"
echo "⏱ INTERVAL: $INTERVAL"
echo "🚀 已稳定运行"
echo "================================"
