#!/bin/bash
# Santuan 开发环境一键启动
# 用法: ./tools/scripts/dev_start.sh

set -e

echo "=== Santuan Dev Environment ==="

# 1. 启动 Python AI 服务
echo "[1/2] Starting Python AI services..."
cd "$(dirname "$0")/../../services"

if [ ! -d ".venv" ]; then
    echo "  Creating Python virtual environment..."
    python3 -m venv .venv
    source .venv/bin/activate
    pip install -r requirements.txt
else
    source .venv/bin/activate
fi

python -m orchestrator.server &
PYTHON_PID=$!
echo "  Orchestrator started (PID: $PYTHON_PID)"

# 2. 启动 Flutter 客户端
echo "[2/2] Starting Flutter client..."
cd "$(dirname "$0")/../../client/app"
flutter run -d windows &
FLUTTER_PID=$!
echo "  Flutter started (PID: $FLUTTER_PID)"

echo ""
echo "=== All services running ==="
echo "  Python Orchestrator: ws://localhost:8765"
echo "  Flutter Client: running"
echo ""
echo "Press Ctrl+C to stop all services"

# 等待退出信号
trap "kill $PYTHON_PID $FLUTTER_PID 2>/dev/null; exit 0" SIGINT SIGTERM
wait
