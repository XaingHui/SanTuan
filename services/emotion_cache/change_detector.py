"""显著偏移检测器 — 只在情绪发生显著变化时触发"""

import time
import numpy as np


class ChangeDetector:
    """情绪变化检测器

    使用欧氏距离检测情绪向量的显著偏移。
    只有当 distance > threshold 且 冷却时间已过 时才触发。

    这是 "只在情绪发生显著偏移时才向云端发送增量更新" 的核心逻辑。
    """

    EMOTION_KEYS = ["happy", "sad", "angry", "surprise", "fear", "disgust", "neutral"]

    def __init__(self, threshold: float = 0.15, cooldown_sec: float = 0.5):
        """
        Args:
            threshold: 触发偏移的欧氏距离阈值 (默认 0.15)
            cooldown_sec: 两次触发的最小间隔 (默认 0.5 秒)
        """
        self.threshold = threshold
        self.cooldown_sec = cooldown_sec
        self._last_triggered: dict[str, float] | None = None
        self._last_trigger_time: float = 0.0

    def check(self, smoothed_emotions: dict[str, float]) -> bool:
        """检查当前情绪是否发生显著偏移

        Returns:
            True = 发生显著偏移，应该触发更新
        """
        now = time.time()

        # 首次调用，设置基线
        if self._last_triggered is None:
            self._last_triggered = smoothed_emotions.copy()
            self._last_trigger_time = now
            return True  # 首帧总是触发

        # 冷却期内不触发
        if now - self._last_trigger_time < self.cooldown_sec:
            return False

        # 计算欧氏距离
        current_vec = np.array([smoothed_emotions.get(k, 0.0) for k in self.EMOTION_KEYS])
        last_vec = np.array([self._last_triggered.get(k, 0.0) for k in self.EMOTION_KEYS])
        distance = float(np.linalg.norm(current_vec - last_vec))

        if distance > self.threshold:
            self._last_triggered = smoothed_emotions.copy()
            self._last_trigger_time = now
            return True

        return False

    def get_delta(self, current: dict[str, float]) -> dict[str, float]:
        """计算当前情绪与上次触发时的增量差"""
        if self._last_triggered is None:
            return current

        delta = {}
        for key in self.EMOTION_KEYS:
            diff = current.get(key, 0.0) - self._last_triggered.get(key, 0.0)
            if abs(diff) > 0.01:  # 只包含有意义的变化
                delta[key] = round(diff, 4)
        return delta

    def reset(self):
        self._last_triggered = None
        self._last_trigger_time = 0.0
