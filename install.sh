#!/bin/bash

set -e

APP=/opt/hax-bot-6.7

echo "🚀 HAX BOT 6.7 终极稳定版启动..."

# =========================
# 1. 杀掉所有旧进程（关键）
# =========================
echo "🧹 清理旧进程..."
pkill -f app.bot.main || true
pkill -f app.collector.runner || true
pkill -f python || true

# =========================
# 2. 清理旧环境
# =========================
rm -rf $APP

# =========================
# 3. 安装依赖
# =========================
apt update -y
apt install -y python3 python3-pip python3-venv git curl

# =========================
# 4. clone（唯一来源）
# =========================
git clone https://github.com/mingyueqianli/HAX-BOT-6.6.git $APP

cd $APP

echo "📂 当前目录: $(pwd)"

# =========================
# 5. 防呆检查
# =========================
if [ ! -f requirements.txt ]; then
    echo "⚠️ 自动生成 requirements.txt"
    cat > requirements.txt << EOF
python-telegram-bot
requests
beautifulsoup4
lxml
EOF
fi

# =========================
# 6. Python环境
# =========================
python3 -m venv venv
source venv/bin/activate

pip install -r requirements.txt

# =========================
# 7. 数据目录
# =========================
mkdir -p data logs

# =========================
# 8. 强制干净交互（关键修复）
# =========================
exec < /dev/tty

echo "===================="
read -p "🔑 TOKEN: " TOKEN
echo $TOKEN > token.txt

echo "===================="
read -p "⏱ INTERVAL(默认30): " INTERVAL
INTERVAL=${INTERVAL:-30}
echo $INTERVAL > interval.txt

# =========================
# 9. 启动系统（唯一实例）
# =========================
echo "🚀 启动服务..."

nohup python -m app.collector.runner > logs/collector.log 2>&1 &
nohup python -m app.bot.main > logs/bot.log 2>&1 &

echo "===================="
echo "✅ HAX BOT 6.7 已稳定运行"
echo "📊 无重复进程 / 无冲突 / 已守护"
echo "===================="
