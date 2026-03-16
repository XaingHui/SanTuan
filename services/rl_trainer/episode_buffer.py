"""回合缓冲区 — 存储 RL 训练回合数据"""

import json
import logging
import os

logger = logging.getLogger(__name__)


class EpisodeBuffer:
    """RL 回合缓冲区

    在内存中积累 episode，达到阈值后批量写入磁盘。
    V3.0 阶段接入训练管线时使用。
    """

    def __init__(self, storage_dir: str = "./data/rl_episodes", flush_threshold: int = 10):
        self.storage_dir = storage_dir
        self.flush_threshold = flush_threshold
        self._buffer: list[dict] = []

    def add(self, episode: dict):
        """添加一个完整的 episode"""
        self._buffer.append(episode)
        logger.info(
            f"Episode buffered: {episode.get('episode_id', 'unknown')} "
            f"({len(self._buffer)}/{self.flush_threshold})"
        )

        if len(self._buffer) >= self.flush_threshold:
            self.flush()

    def flush(self):
        """将缓冲区的 episodes 写入磁盘"""
        if not self._buffer:
            return

        os.makedirs(self.storage_dir, exist_ok=True)

        for episode in self._buffer:
            ep_id = episode.get("episode_id", "unknown")
            path = os.path.join(self.storage_dir, f"{ep_id}.json")
            with open(path, "w", encoding="utf-8") as f:
                json.dump(episode, f, ensure_ascii=False, indent=2)
            logger.info(f"Episode saved: {path}")

        self._buffer.clear()

    @property
    def size(self) -> int:
        return len(self._buffer)
