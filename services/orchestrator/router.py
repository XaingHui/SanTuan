"""消息路由器 — 根据消息类型分发到对应服务"""

import logging
from typing import Any, Callable, Coroutine

logger = logging.getLogger(__name__)

# 服务处理函数类型
HandlerFunc = Callable[[dict], Coroutine[Any, Any, dict | None]]


class MessageRouter:
    """消息路由器

    注册模式：
        router.register("client_event", handle_event)
        router.register("command_request", handle_command)
    """

    def __init__(self):
        self._handlers: dict[str, HandlerFunc] = {}
        self._register_defaults()

    def register(self, msg_type: str, handler: HandlerFunc):
        """注册消息处理器"""
        self._handlers[msg_type] = handler
        logger.info(f"Registered handler for '{msg_type}'")

    async def route(self, msg_type: str, data: dict) -> dict | None:
        """路由消息到对应处理器"""
        handler = self._handlers.get(msg_type)
        if handler is None:
            logger.warning(f"No handler for message type: {msg_type}")
            return {"type": "error", "message": f"Unknown message type: {msg_type}"}
        return await handler(data)

    def _register_defaults(self):
        """注册默认处理器"""

        async def handle_ping(data: dict) -> dict:
            return {"type": "pong", "timestamp": data.get("timestamp")}

        async def handle_client_event(data: dict) -> dict | None:
            event = data.get("event", "unknown")
            logger.info(f"Client event: {event}")
            # TODO: 转发给 RL DataCollector
            return None  # 事件不需要响应

        self.register("ping", handle_ping)
        self.register("client_event", handle_client_event)
