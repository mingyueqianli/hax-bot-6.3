# HAX BOT 7.9

HAX Telegram Bot 一键安装版。支持 Ubuntu / Debian VPS，适配 AMD64 / ARM64。安装后使用 systemd 守护两个进程：

- `hax-bot.service`：Telegram 机器人、机器续期提醒、数据中心变化通知。
- `hax-bot-collector.service`：定时采集 HAX 数据中心状态，写入 `data/data_center.json`、`data/data_center.txt` 和兼容旧版的 `test.txt`。

## 7.9 新增

- Telegram 内直接查看和修改采集间隔：`/interval`、`/interval 60`、`/setinterval 60`。
- TG 修改间隔后自动写入 `interval.txt` 和 `config.env`。
- 自动尝试重启 `hax-bot-collector.service`，新采集间隔立即生效。
- 采集器运行中会动态读取 `interval.txt`，即使 systemctl 重启失败，下一轮也会生效。
- 卸载脚本增强：可停止服务、禁用开机自启、删除 systemd 文件、清理残留进程，可选择保留或删除数据目录。

## 目录结构

```text
hax-bot-7.9/
├── app/
│   ├── bot/main.py
│   ├── collector/hax.py
│   ├── collector/runner.py
│   ├── config.py
│   └── storage.py
├── data/.gitkeep
├── logs/.gitkeep
├── install.sh
├── start.sh
├── stop.sh
├── restart.sh
├── status.sh
├── update.sh
├── uninstall.sh
├── upload_to_github.sh
├── requirements.txt
└── README.md
```

## 一键安装

上传到 GitHub 后执行：

```bash
curl -fsSL https://raw.githubusercontent.com/mingyueqianli/hax-bot-7.7/main/install.sh | bash
```

非交互安装：

```bash
curl -fsSL https://raw.githubusercontent.com/mingyueqianli/hax-bot-7.7/main/install.sh | HAX_TOKEN="你的TelegramBotToken" HAX_INTERVAL=30 bash
```

如果你的仓库不是 `mingyueqianli/hax-bot-7.7`，先改 `install.sh` 顶部的 `REPO_URL`。

## 手动安装

```bash
apt update -y
apt install -y python3 python3-pip python3-venv git curl
cd /opt
git clone https://github.com/mingyueqianli/hax-bot-7.7.git hax-bot
cd /opt/hax-bot
bash install.sh
```

## Telegram 命令

- `/start`：查看帮助。
- `/new`：添加机器续期提醒。
- `/info`：查看机器列表和剩余时间。
- `/rename`：修改备注或续期日期。
- `/delmachine`：删除机器，支持 `1,3` 或 `1-3`。
- `/monitor`：开启/关闭 HAX 数据中心变化提醒。
- `/status`：查看当前采集到的数据中心状态。
- `/interval`：查看当前采集间隔，并显示快捷按钮。
- `/interval 60`：把采集间隔改为 60 秒。
- `/setinterval 120`：把采集间隔改为 120 秒。
- `/cancel`：取消当前操作。

## 修改采集间隔

在 Telegram 里发送：

```text
/interval
```

或者直接设置：

```text
/interval 60
```

系统会同步修改：

```text
/opt/hax-bot/interval.txt
/opt/hax-bot/config.env
```

并自动尝试执行：

```bash
systemctl restart hax-bot-collector.service
```

## 服务管理

```bash
systemctl status hax-bot.service hax-bot-collector.service
systemctl restart hax-bot.service hax-bot-collector.service
journalctl -u hax-bot -f
journalctl -u hax-bot-collector -f
```

也可以使用仓库内脚本：

```bash
./status.sh
./restart.sh
./stop.sh
./start.sh
./update.sh
```

## 重要文件

- `token.txt`：Telegram Bot Token，权限自动设置为 `600`，不会提交到 GitHub。
- `interval.txt`：采集间隔，单位秒，默认 `30`。
- `config.env`：systemd 环境变量文件。
- `data/user_data.json`：用户机器提醒和监控状态。
- `data/data_center.json`：结构化数据中心状态。
- `data/data_center.txt`：文本版数据中心状态。
- `test.txt`：兼容旧版脚本。

## 更新

```bash
cd /opt/hax-bot
./update.sh
```

更新脚本会保留 `token.txt`、`interval.txt`、`config.env`、`data/` 和 `logs/`。

## 卸载

交互卸载：

```bash
cd /opt/hax-bot
./uninstall.sh
```

直接彻底删除：

```bash
cd /opt/hax-bot
./uninstall.sh --purge
```

或者：

```bash
HAX_PURGE=1 bash /opt/hax-bot/uninstall.sh
```

卸载会执行：

```text
1. 停止 hax-bot.service 和 hax-bot-collector.service
2. 禁用开机自启
3. 删除 /etc/systemd/system/ 里的服务文件
4. systemctl daemon-reload 和 reset-failed
5. 清理残留 Python 进程
6. 根据选择保留或删除 /opt/hax-bot
```
