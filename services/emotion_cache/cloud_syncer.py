"""增量云端同步器 — 只发送变化的情绪数据"""

import asyncio
import json
import logging
import time

logger = logging.getLogger(__name__)


class CloudSyncer:
    """增量云端同步器

    收集待发送的 delta 更新，批量合并后发送。
    最多每 N 秒发送一次，避免高频请求。

    V2.0+ 才真正启用云端同步，MVP/V1.0 阶段仅本地记录。
    """

    def __init__(self, min_interval_sec: float = 2.0, cloud_url: str | None = None):
        """
        Args:
            min_interval_sec: 最小发送间隔 (默认 2 秒)
            cloud_url: 云端 API 地址 (None = 仅本地记录)
        """
        self.min_interval_sec = min_interval_sec
        self.cloud_url = cloud_url
        self._pending_deltas: list[dict] = []
        self._last_sync_time: float = 0.0

    def enqueue(self, delta: dict[str, float], timestamp: float | None = None):
        """将一次增量变化加入发送队列"""
        self._pending_deltas.append({
            "delta": delta,
            "ts": timestamp or time.time(),
        })

    async def flush(self) -> bool:
        """尝试将积压的 delta 发送到云端

        Returns:
            True = 已发送, False = 未达到发送条件或无数据
        """
        now = time.time()

        if not self._pending_deltas:
            return False

        if now - self._last_sync_time < self.min_interval_sec:
            return False

        # 合并多个 delta 为一个批量更新
        batch = self._pending_deltas.copy()
        self._pending_deltas.clear()
        self._last_sync_time = now

        if self.cloud_url:
            # V2.0+: 实际发送到云端
            await self._send_to_cloud(batch)
        else:
            # MVP/V1.0: 仅日志记录
            logger.debug(f"Cloud sync (local only): {len(batch)} deltas")

        return True

    async def _send_to_cloud(self, batch: list[dict]):
        """发送数据到云端 API"""
        # TODO: 实现实际的 HTTP 请求
        payload = {
            "type": "emotion_deltas",
            "batch": batch,
            "count": len(batch),
        }
        logger.info(f"Sending {len(batch)} deltas to {self.cloud_url}")
        logger.debug(json.dumps(payload, ensure_ascii=False))
