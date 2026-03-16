"""奖励模型 — 计算 RL 训练的奖励信号"""


class RewardModel:
    """情感反馈奖励模型

    奖励函数：
    R = w1 × engagement_delta
      + w2 × emotion_improvement
      + w3 × explicit_feedback
      + w4 × session_retention
      - w5 × annoyance_signal

    V3.0 阶段实现具体训练逻辑。
    """

    DEFAULT_WEIGHTS = {
        "engagement_delta": 0.25,
        "emotion_improvement": 0.30,
        "explicit_feedback": 0.20,
        "session_retention": 0.15,
        "annoyance_signal": 0.10,
    }

    def __init__(self, weights: dict[str, float] | None = None):
        self.weights = weights or self.DEFAULT_WEIGHTS.copy()

    def compute_reward(self, signals: dict) -> float:
        """计算综合奖励值"""
        reward = 0.0
        reward += self.weights["engagement_delta"] * signals.get("engagement_delta", 0.0)
        reward += self.weights["emotion_improvement"] * signals.get("emotion_improvement", 0.0)
        reward += self.weights["explicit_feedback"] * (signals.get("explicit_feedback") or 0.0)
        reward += self.weights["session_retention"] * signals.get("session_retention", 0.0)
        reward -= self.weights["annoyance_signal"] * signals.get("annoyance_signal", 0.0)
        return reward
