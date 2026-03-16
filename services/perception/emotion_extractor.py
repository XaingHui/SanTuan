"""情绪提取器 — 将 FaceAnalyzer 的 AU 输出转换为标准情绪帧"""

import time


class EmotionExtractor:
    """情绪提取器

    将 LibreFace 的 Action Units 输出转换为
    protocol/schemas/emotion.schema.json 格式的标准情绪帧。
    """

    EMOTION_KEYS = ["happy", "sad", "angry", "surprise", "fear", "disgust", "neutral"]

    def __init__(self):
        self._frame_counter = 0

    def extract(self, analysis_result: dict) -> dict:
        """从分析结果中提取标准情绪帧"""
        self._frame_counter += 1

        emotions = analysis_result.get("emotions", {})

        # 找主导情绪
        dominant = "neutral"
        max_val = 0.0
        for key in self.EMOTION_KEYS:
            val = emotions.get(key, 0.0)
            if val > max_val:
                max_val = val
                dominant = key

        # 计算 arousal 和 valence
        arousal = self._calc_arousal(emotions)
        valence = self._calc_valence(emotions)

        return {
            "type": "emotion_frame",
            "timestamp": analysis_result.get("timestamp", time.time()),
            "frame_id": self._frame_counter,
            "emotions": {k: round(emotions.get(k, 0.0), 4) for k in self.EMOTION_KEYS},
            "dominant": dominant,
            "confidence": analysis_result.get("confidence", 0.9),
            "face_detected": analysis_result.get("face_detected", False),
            "arousal": round(arousal, 4),
            "valence": round(valence, 4),
        }

    @staticmethod
    def _calc_arousal(emotions: dict[str, float]) -> float:
        """计算唤醒度: 高唤醒情绪(惊讶/愤怒/恐惧/开心) vs 低唤醒(悲伤/中性)"""
        high = emotions.get("surprise", 0) + emotions.get("angry", 0) + emotions.get("fear", 0) + emotions.get("happy", 0) * 0.5
        low = emotions.get("sad", 0) + emotions.get("neutral", 0)
        return (high - low) / max(high + low, 0.001)

    @staticmethod
    def _calc_valence(emotions: dict[str, float]) -> float:
        """计算效价: 正面情绪 vs 负面情绪"""
        positive = emotions.get("happy", 0) + emotions.get("surprise", 0) * 0.3
        negative = emotions.get("sad", 0) + emotions.get("angry", 0) + emotions.get("fear", 0) + emotions.get("disgust", 0)
        return (positive - negative) / max(positive + negative, 0.001)
