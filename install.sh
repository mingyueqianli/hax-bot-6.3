#!/bin/bash

set -e

REPO="https://github.com/mingyueqianli/hax-bot-3.0.git"
APP="/opt/hax-bot-3.0"

echo "🚀 HAX BOT 4.0 安装启动..."

# ======================
# 1. 环境检查
# ======================
echo "🔍 检查网络..."
if ! curl -s https://github.com > /dev/null; then
  echo "❌ 网络异常，无法访问 GitHub"
  exit 1
fi

# ======================
# 2. 安装依赖
# ======================
apt update -y
apt install -y python3 python3-pip python3-venv git curl

# ======================
# 3. 克隆仓库（防错）
# ======================
rm -rf $APP

echo "📦 拉取最新代码..."
git clone $REPO $APP || {
  echo "❌ Git clone失败，请检查网络或SSH"
  exit 1
}

cd $APP

# ======================
# 4. Python环境
# ======================
python3 -m venv venv
source venv/bin/activate

pip install -r requirements.txt || {
  echo "⚠️ 依赖安装失败，尝试修复..."
  pip install --upgrade pip
  pip install -r requirements.txt
}

# ======================
# 5. 初始化目录
# ======================
mkdir -p data logs

# ======================
# 6. Token检测
# ======================
if [ ! -f token.txt ]; then
  echo "🔑 请输入 Bot Token:"
  read TOKEN
  echo $TOKEN > token.txt
fi

# ======================
# 7. 启动系统（防错）
# ======================
echo "🚀 启动服务..."

nohup python -m app.collector.runner > logs/collector.log 2>&1 &
nohup python -m app.bot.main > logs/bot.log 2>&1 &

echo "✅ HAX BOT 4.0 安装完成"
echo "📊 查看日志: tail -f logs/bot.log"
