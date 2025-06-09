#!/bin/bash

# 快速端口检查脚本
echo "🔍 检查端口占用情况"
echo "=================="

# 要检查的端口列表
PORTS=(80 3000 8001 8080 8090)

echo ""
echo "端口状态检查:"
echo "------------"

for port in "${PORTS[@]}"; do
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo "❌ 端口 $port: 已占用"
        # 显示占用进程的详细信息
        echo "   占用进程: $(lsof -Pi :$port -sTCP:LISTEN -t | head -1 | xargs ps -p | tail -1 | awk '{print $4}')"
    else
        echo "✅ 端口 $port: 可用"
    fi
done

echo ""
echo "💡 建议的端口配置:"
echo "------------------"

# 推荐可用端口
if ! lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "前端: 3000 (推荐)"
else
    # 寻找替代端口
    for port in {3001..3010}; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            echo "前端: $port (替代)"
            break
        fi
    done
fi

if ! lsof -Pi :8001 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "后端: 8001 (推荐)"
else
    # 寻找替代端口
    for port in {8002..8010}; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            echo "后端: $port (替代)"
            break
        fi
    done
fi

echo ""
echo "🚀 下一步操作:"
echo "-------------"
echo "1. 如果推荐端口可用，直接运行: ./deploy.sh"
echo "2. 如果有端口冲突，运行: ./configure-ports.sh"
echo "3. 查看详细部署说明: cat DEPLOYMENT.md"
