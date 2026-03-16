"""环形缓冲区 — 存储最近 N 帧情绪数据"""

from collections import deque
from typing import Any


class RingBuffer:
    """固定容量的环形缓冲区

    用于保存最近 N 帧原始情绪数据。
    满了自动淘汰最旧的帧 (FIFO)。

    用法：
        buf = RingBuffer(capacity=60)  # 2秒 @30fps
        buf.push(emotion_frame)
        recent = buf.last(10)  # 最近10帧
    """

    def __init__(self, capacity: int = 60):
        self._capacity = capacity
        self._buffer: deque[dict[str, Any]] = deque(maxlen=capacity)

    def push(self, frame: dict[str, Any]):
        """推入一帧数据"""
        self._buffer.append(frame)

    def last(self, n: int = 1) -> list[dict[str, Any]]:
        """获取最近 n 帧"""
        return list(self._buffer)[-n:]

    @property
    def is_full(self) -> bool:
        return len(self._buffer) >= self._capacity

    @property
    def size(self) -> int:
        return len(self._buffer)

    def clear(self):
        self._buffer.clear()
