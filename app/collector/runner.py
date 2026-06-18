from __future__ import annotations

import logging
import signal
import sys
import time
from threading import Event

from app import config
from app.collector.hax import fetch_snapshot, save_snapshot


def setup_logging() -> None:
    config.ensure_runtime_dirs()
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
        handlers=[logging.StreamHandler(sys.stdout)],
    )


def main() -> None:
    setup_logging()
    logger = logging.getLogger("hax.collector")
    stop_event = Event()

    def _stop(signum, frame):  # noqa: ANN001
        logger.info("收到退出信号 %s，准备停止采集...", signum)
        stop_event.set()

    signal.signal(signal.SIGTERM, _stop)
    signal.signal(signal.SIGINT, _stop)

    interval = config.get_interval_seconds()
    logger.info("HAX Collector 启动，采集间隔：%s 秒", interval)
    while not stop_event.is_set():
        interval = config.get_interval_seconds()
        try:
            snapshot = fetch_snapshot()
            if snapshot:
                save_snapshot(snapshot)
                logger.info(
                    "采集成功：总数=%s，数据中心=%s 个，当前间隔=%s 秒",
                    snapshot.get("total"),
                    len(snapshot.get("centers") or {}),
                    interval,
                )
            else:
                logger.warning("本次采集无有效数据，保留旧文件，当前间隔=%s 秒", interval)
        except Exception as exc:  # noqa: BLE001
            logger.exception("采集失败：%s", exc)

        # 每秒检查一次配置文件，Telegram 修改 interval.txt 后无需重装。
        slept = 0
        while slept < interval and not stop_event.is_set():
            time.sleep(1)
            slept += 1
            new_interval = config.get_interval_seconds()
            if new_interval != interval:
                logger.info("采集间隔已变更：%s 秒 -> %s 秒", interval, new_interval)
                interval = new_interval
                break

    logger.info("HAX Collector 已停止")


if __name__ == "__main__":
    main()
