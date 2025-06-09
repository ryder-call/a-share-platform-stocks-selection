#!/bin/bash

# 快速测试脚本
echo "🚀 快速测试 Docker 构建"
echo "======================"

# 清理之前的构建
echo "🧹 清理环境..."
docker-compose down 2>/dev/null
docker system prune -f >/dev/null 2>&1

echo ""
echo "🔨 测试前端构建..."
if docker build -t test-frontend .; then
    echo "✅ 前端构建成功"
    docker rmi test-frontend >/dev/null 2>&1
else
    echo "❌ 前端构建失败"
    exit 1
fi

echo ""
echo "🔨 测试后端构建..."
if docker build -t test-backend ./api; then
    echo "✅ 后端构建成功"
    docker rmi test-backend >/dev/null 2>&1
else
    echo "❌ 后端构建失败"
    exit 1
fi

echo ""
echo "🎉 所有测试通过！"
echo "现在可以运行: ./local-deploy.sh"
