"""Perception 感知服务 — LibreFace 情绪识别

V1.0 阶段接入。封装摄像头采集 + LibreFace 推理 + 情绪向量提取。
"""

from .face_analyzer import FaceAnalyzer
from .emotion_extractor import EmotionExtractor

__all__ = ["FaceAnalyzer", "EmotionExtractor"]
