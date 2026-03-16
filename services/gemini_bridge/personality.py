"""性格模板"""


class Personality:
    """宠物性格模板

    定义宠物的基础性格特征，影响对话风格和行为选择。
    V3.0 阶段由 RL 动态调整。

    性格维度：
    - warmth: 温暖度 [0, 1] — 高=热情关怀 vs 低=高冷
    - energy: 活力值 [0, 1] — 高=蹦蹦跳跳 vs 低=安静
    - humor: 幽默感 [0, 1] — 高=搞怪 vs 低=认真
    """

    PRESETS = {
        "default": {"warmth": 0.7, "energy": 0.6, "humor": 0.5},
        "cheerful": {"warmth": 0.9, "energy": 0.9, "humor": 0.7},
        "calm": {"warmth": 0.6, "energy": 0.2, "humor": 0.3},
        "playful": {"warmth": 0.8, "energy": 0.8, "humor": 0.9},
    }

    def __init__(self, preset: str = "default"):
        self.traits = self.PRESETS.get(preset, self.PRESETS["default"]).copy()

    def shift(self, dimension: str, delta: float):
        """微调性格维度（RL 训练使用）"""
        if dimension in self.traits:
            self.traits[dimension] = max(0.0, min(1.0, self.traits[dimension] + delta))

    def to_prompt_context(self) -> str:
        """生成性格描述，注入到 Gemini system prompt"""
        w, e, h = self.traits["warmth"], self.traits["energy"], self.traits["humor"]
        return (
            f"你是一只性格特征为：温暖度{w:.1f}、活力值{e:.1f}、幽默感{h:.1f}的虚拟宠物。"
            f"{'你很热情关怀主人。' if w > 0.7 else '你比较高冷矜持。'}"
            f"{'你活泼好动。' if e > 0.7 else '你安静沉稳。'}"
            f"{'你喜欢搞怪逗主人开心。' if h > 0.7 else '你比较认真严肃。'}"
        )
