"""RL 数据采集器 — 隐私合规的用户交互数据收集"""

import hashlib
import logging
import time

logger = logging.getLogger(__name__)


class DataCollector:
    """RL 数据采集器

    采集 5 维数据（均匿名化）：
    1. 情绪状态 — 7维向量 + arousal + valence (已脱敏，非原始视频)
    2. 交互事件 — 点击/拖拽/对话 (事件驱动)
    3. 宠物状态 — 当前动画/心情/性格向量 (系统数据)
    4. 上下文特征 — 时间段/会话时长/交互密度 (低敏感)
    5. 反馈信号 — 显式点赞踩 + 隐式停留时长 (用户 opt-in)

    隐私合规：
    - 不采集原始视频/图像
    - 不采集生物特征
    - 用户 ID 使用不可逆哈希
    - 用户必须显式 opt-in
    """

    def __init__(self, user_id: str, opt_in: bool = False):
        self.user_id_hash = self._hash_user_id(user_id)
        self.opt_in = opt_in
        self._current_episode: list[dict] = []
        self._step_counter = 0
        self._session_start = time.time()

    def record_step(
        self,
        emotion_state: dict[str, float],
        pet_state: dict,
        action_taken: dict,
        feedback: dict | None = None,
    ):
        """记录一个 RL 步骤"""
        if not self.opt_in:
            return

        self._step_counter += 1
        step = {
            "t": self._step_counter,
            "state": {
                "emotion_vector": [emotion_state.get(k, 0.0) for k in
                    ["happy", "sad", "angry", "surprise", "fear", "disgust", "neutral"]],
                "arousal": emotion_state.get("arousal", 0.0),
                "valence": emotion_state.get("valence", 0.0),
                "pet_mood": pet_state.get("mood", "neutral"),
                "pet_personality": pet_state.get("personality", [0.7, 0.6, 0.5]),
                "time_of_day": self._get_time_of_day(),
                "session_minute": (time.time() - self._session_start) / 60,
                "interaction_density": pet_state.get("interaction_density", 0.0),
            },
            "action": action_taken,
            "reward": self._calc_reward(feedback) if feedback else {},
        }
        self._current_episode.append(step)

    def end_episode(self) -> dict | None:
        """结束当前回合，返回完整 episode 数据"""
        if not self.opt_in or not self._current_episode:
            return None

        episode = {
            "type": "rl_episode",
            "episode_id": f"ep_{int(self._session_start)}_{self.user_id_hash[:8]}",
            "user_id_hash": self.user_id_hash,
            "session_start": self._session_start,
            "session_end": time.time(),
            "steps": self._current_episode,
        }

        self._current_episode = []
        self._step_counter = 0
        self._session_start = time.time()

        return episode

    @staticmethod
    def _hash_user_id(user_id: str) -> str:
        return hashlib.sha256(user_id.encode()).hexdigest()

    @staticmethod
    def _get_time_of_day() -> str:
        hour = time.localtime().tm_hour
        if 6 <= hour < 12:
            return "morning"
        elif 12 <= hour < 18:
            return "afternoon"
        elif 18 <= hour < 22:
            return "evening"
        return "night"

    @staticmethod
    def _calc_reward(feedback: dict) -> dict:
        return {
            "engagement_delta": feedback.get("engagement_delta", 0.0),
            "emotion_improvement": feedback.get("emotion_improvement", 0.0),
            "explicit_feedback": feedback.get("explicit_feedback"),
            "session_retention": feedback.get("session_retention", 0.0),
            "annoyance_signal": feedback.get("annoyance_signal", 0.0),
        }
