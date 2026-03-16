"""Santuan Orchestrator — WebSocket 服务编排器

所有 AI 服务的中心枢纽。
Flutter 客户端通过 WebSocket 连接到此服务器，
服务器负责：
1. 接收客户端事件
2. 路由到对应的 AI 服务模块
3. 将 AI 服务输出推送给客户端
"""

import asyncio
import json
import logging
from typing import Set

import websockets
from websockets.asyncio.server import ServerConnection

from .router import MessageRouter

logger = logging.getLogger(__name__)


class Orchestrator:
    """WebSocket 服务编排器"""

    def __init__(self, host: str = "localhost", port: int = 8765):
        self.host = host
        self.port = port
        self.clients: Set[ServerConnection] = set()
        self.router = MessageRouter()

    async def start(self):
        """启动 WebSocket 服务器"""
        async with websockets.serve(self._handler, self.host, self.port):
            logger.info(f"Santuan Orchestrator running on ws://{self.host}:{self.port}")
            await asyncio.Future()  # 永不结束

    async def _handler(self, websocket: ServerConnection):
        """处理单个客户端连接"""
        self.clients.add(websocket)
        client_id = id(websocket)
        logger.info(f"Client connected: {client_id}")

        try:
            async for message in websocket:
                await self._handle_message(websocket, message)
        except websockets.exceptions.ConnectionClosed:
            logger.info(f"Client disconnected: {client_id}")
        finally:
            self.clients.discard(websocket)

    async def _handle_message(self, websocket: ServerConnection, raw: str):
        """处理收到的消息"""
        try:
            data = json.loads(raw)
            msg_type = data.get("type", "unknown")
            response = await self.router.route(msg_type, data)

            if response:
                await websocket.send(json.dumps(response))
        except json.JSONDecodeError:
            logger.warning(f"Invalid JSON received: {raw[:100]}")
        except Exception as e:
            logger.error(f"Error handling message: {e}", exc_info=True)

    async def broadcast(self, data: dict):
        """广播消息给所有连接的客户端"""
        if not self.clients:
            return
        message = json.dumps(data)
        await asyncio.gather(
            *[client.send(message) for client in self.clients],
            return_exceptions=True,
        )


def main():
    logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(name)s] %(message)s")
    orchestrator = Orchestrator()
    asyncio.run(orchestrator.start())


if __name__ == "__main__":
    main()
