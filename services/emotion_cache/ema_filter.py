"""指数移动平均滤波器 — 平滑 30fps 情绪数据"""

import numpy as np


class EMAFilter:
    """指数移动平均 (Exponential Moving Average) 滤波器

    公式: smoothed[t] = α × raw[t] + (1-α) × smoothed[t-1]

    α 越大 → 跟踪越灵敏（噪声也越大）
    α 越小 → 越平滑（延迟也越大）

    推荐值：
    - α=0.3: 适度平滑，适合情绪数据
    - α=0.1: 重度平滑，适合长期趋势
    - α=0.5: 轻度平滑，接近原始数据
    """

    # 7 维情绪标准键名
    EMOTION_KEYS = ["happy", "sad", "angry", "surprise", "fear", "disgust", "neutral"]

    def __init__(self, alpha: float = 0.3):
        if not 0 < alpha <= 1:
            raise ValueError("alpha must be in (0, 1]")
        self.alpha = alpha
        self._smoothed: np.ndarray | None = None

    def update(self, raw_emotions: dict[str, float]) -> dict[str, float]:
        """输入一帧原始情绪数据，返回平滑后的情绪数据"""
        raw_vec = np.array([raw_emotions.get(k, 0.0) for k in self.EMOTION_KEYS])

        if self._smoothed is None:
            self._smoothed = raw_vec.copy()
        else:
            self._smoothed = self.alpha * raw_vec + (1 - self.alpha) * self._smoothed

        return dict(zip(self.EMOTION_KEYS, self._smoothed.tolist()))

    @property
    def current(self) -> dict[str, float] | None:
        """当前平滑值"""
        if self._smoothed is None:
            return None
        return dict(zip(self.EMOTION_KEYS, self._smoothed.tolist()))

    def reset(self):
        self._smoothed = None
