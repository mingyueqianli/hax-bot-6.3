#!/bin/bash
set -e

APP=/opt/hax-bot-6.6

echo HAX BOT 6.6 FULL INSTALL

apt update -y
apt install -y python3 python3-pip python3-venv git

rm -rf $APP
mkdir -p $APP
cp -r . $APP
cd $APP

python3 -m venv venv
source venv/bin/activate

pip install -r requirements.txt

mkdir -p data logs

exec < /dev/tty

read -p "TOKEN: " TOKEN
echo $TOKEN > token.txt

read -p "INTERVAL: " INTERVAL
INTERVAL=${INTERVAL:-30}
echo $INTERVAL > interval.txt

nohup python -m app.collector.runner > logs/collector.log 2>&1 &
nohup python -m app.bot.main > logs/bot.log 2>&1 &

echo DONE
