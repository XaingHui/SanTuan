"""对话管理器 — Gemini API 封装"""

import logging

logger = logging.getLogger(__name__)


class Conversation:
    """对话管理器

    V2.0 接入 Gemini 时实现。当前为接口骨架。

    职责：
    1. 管理对话上下文窗口
    2. 注入情绪状态作为系统提示
    3. 结合性格模板生成回复
    4. 与 MemoryManager 协作实现长记忆
    """

    def __init__(self, api_key: str | None = None, personality_id: str = "default"):
        self.api_key = api_key
        self.personality_id = personality_id
        self._history: list[dict] = []

    async def chat(
        self,
        user_message: str,
        emotion_context: dict[str, float] | None = None,
    ) -> str:
        """发送消息并获取回复

        Args:
            user_message: 用户消息
            emotion_context: 当前情绪上下文（注入到 system prompt）

        Returns:
            宠物的回复文本
        """
        # TODO V2.0: 接入 Gemini API
        # model = genai.GenerativeModel("gemini-pro")
        # response = await model.generate_content_async(prompt)
        logger.info(f"Conversation placeholder: {user_message[:50]}")
        return "喵~ (V2.0 才会真的说话哦)"

    def get_history(self, limit: int = 20) -> list[dict]:
        """获取最近的对话历史"""
        return self._history[-limit:]

    def clear_history(self):
        self._history.clear()
