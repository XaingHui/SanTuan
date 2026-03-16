"""长期记忆管理器"""


class MemoryManager:
    """长期记忆管理器

    V2.0 实现。存储用户偏好、重要对话、情感记忆。

    存储方案（待定）：
    - 本地 SQLite + 向量检索
    - 或 JSON 文件（MVP 简化版）
    """

    def __init__(self, storage_path: str = "./data/memory"):
        self.storage_path = storage_path
        self._memories: list[dict] = []

    async def remember(self, content: str, tags: list[str] | None = None, importance: float = 0.5):
        """存储一条记忆"""
        # TODO V2.0
        pass

    async def recall(self, query: str, limit: int = 5) -> list[dict]:
        """根据查询召回相关记忆"""
        # TODO V2.0: 向量相似度检索
        return []

    async def forget(self, memory_id: str):
        """遗忘一条记忆（GDPR 合规）"""
        # TODO V2.0
        pass
