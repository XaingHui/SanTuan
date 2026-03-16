"""情绪处理管线 — 串联 RingBuffer → EMA → ChangeDetector → CloudSyncer"""

import asyncio
import logging
from typing import Any, Callable

from .ring_buffer import RingBuffer
from .ema_filter import EMAFilter
from .change_detector import ChangeDetector
from .cloud_syncer import CloudSyncer

logger = logging.getLogger(__name__)


class EmotionPipeline:
    """情绪数据处理管线

    完整数据流：
    30fps 原始帧 → RingBuffer(缓存) → EMA(平滑) → ChangeDetector(偏移检测)
                                                          ↓
                    Animation(10fps) ←── Local State     CloudSyncer(增量同步)

    用法：
        pipeline = EmotionPipeline()
        pipeline.on_emotion_update = callback  # 每帧平滑结果
        pipeline.on_significant_change = callback  # 仅显著变化
        await pipeline.process(raw_frame)
    """

    def __init__(
        self,
        buffer_capacity: int = 60,
        ema_alpha: float = 0.3,
        change_threshold: float = 0.15,
        change_cooldown: float = 0.5,
        sync_interval: float = 2.0,
    ):
        self.buffer = RingBuffer(capacity=buffer_capacity)
        self.ema = EMAFilter(alpha=ema_alpha)
        self.detector = ChangeDetector(threshold=change_threshold, cooldown_sec=change_cooldown)
        self.syncer = CloudSyncer(min_interval_sec=sync_interval)

        # 回调函数
        self.on_emotion_update: Callable[[dict[str, float]], Any] | None = None
        self.on_significant_change: Callable[[dict[str, float], dict[str, float]], Any] | None = (
            None
        )

        self._frame_count = 0

    async def process(self, raw_frame: dict[str, Any]):
        """处理一帧原始情绪数据

        Args:
            raw_frame: 原始情绪帧 (符合 emotion.schema.json)
        """
        emotions = raw_frame.get("emotions", {})
        self._frame_count += 1

        # 1. 存入环形缓冲区
        self.buffer.push(raw_frame)

        # 2. EMA 平滑
        smoothed = self.ema.update(emotions)

        # 3. 回调：每帧平滑结果 (用于驱动动画)
        if self.on_emotion_update:
            self.on_emotion_update(smoothed)

        # 4. 检测显著偏移
        if self.detector.check(smoothed):
            delta = self.detector.get_delta(smoothed)
            logger.info(f"Significant emotion change detected: {delta}")

            # 加入云端同步队列
            self.syncer.enqueue(delta, raw_frame.get("timestamp"))

            # 回调：显著变化
            if self.on_significant_change:
                self.on_significant_change(smoothed, delta)

        # 5. 尝试 flush 云端同步
        await self.syncer.flush()

    @property
    def current_emotion(self) -> dict[str, float] | None:
        """当前平滑后的情绪状态"""
        return self.ema.current

    @property
    def frames_processed(self) -> int:
        return self._frame_count
