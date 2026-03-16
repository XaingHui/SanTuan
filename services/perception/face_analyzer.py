"""人脸分析器 — 封装 LibreFace 推理"""

import logging
import time

logger = logging.getLogger(__name__)


class FaceAnalyzer:
    """人脸分析器

    V1.0 接入 LibreFace 时实现。当前为接口骨架。

    职责：
    1. 接收摄像头帧 (numpy array)
    2. 调用 LibreFace 模型推理
    3. 输出 AU (Action Units) 和情绪分类
    """

    def __init__(self, model_path: str | None = None):
        self.model_path = model_path
        self._model = None
        self._is_loaded = False

    async def load_model(self):
        """加载 LibreFace 模型"""
        # TODO V1.0: 加载 LibreFace 模型
        # from libreface import LibreFace
        # self._model = LibreFace(self.model_path)
        logger.info("FaceAnalyzer: model loading placeholder (V1.0)")
        self._is_loaded = True

    async def analyze(self, frame) -> dict | None:
        """分析一帧图像

        Args:
            frame: numpy array (H, W, 3) BGR 格式

        Returns:
            {"aus": {...}, "emotions": {...}, "face_detected": bool}
        """
        if not self._is_loaded:
            return None

        # TODO V1.0: 实际推理
        # result = self._model.predict(frame)
        # return {
        #     "aus": result.action_units,
        #     "emotions": result.emotions,
        #     "face_detected": result.face_detected,
        # }

        # Placeholder
        return {
            "aus": {},
            "emotions": {
                "happy": 0.5, "sad": 0.1, "angry": 0.05,
                "surprise": 0.05, "fear": 0.02, "disgust": 0.01, "neutral": 0.27,
            },
            "face_detected": True,
            "timestamp": time.time(),
        }

    @property
    def is_loaded(self) -> bool:
        return self._is_loaded
