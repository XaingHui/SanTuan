"""服务注册/发现 — 管理所有 AI 服务模块的生命周期"""

import logging
from typing import Protocol

logger = logging.getLogger(__name__)


class ServiceInterface(Protocol):
    """所有 AI 服务必须实现的协议"""

    @property
    def name(self) -> str: ...
    async def start(self) -> None: ...
    async def stop(self) -> None: ...
    @property
    def is_running(self) -> bool: ...


class ServiceRegistry:
    """服务注册表

    用法：
        registry = ServiceRegistry()
        registry.register(perception_service)
        registry.register(gemini_service)
        await registry.start_all()
    """

    def __init__(self):
        self._services: dict[str, ServiceInterface] = {}

    def register(self, service: ServiceInterface):
        self._services[service.name] = service
        logger.info(f"Service registered: {service.name}")

    def get(self, name: str) -> ServiceInterface | None:
        return self._services.get(name)

    async def start_all(self):
        for name, service in self._services.items():
            logger.info(f"Starting service: {name}")
            await service.start()

    async def stop_all(self):
        for name, service in reversed(list(self._services.items())):
            logger.info(f"Stopping service: {name}")
            await service.stop()

    @property
    def running_services(self) -> list[str]:
        return [name for name, svc in self._services.items() if svc.is_running]
