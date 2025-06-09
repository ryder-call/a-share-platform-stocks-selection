#!/bin/bash

# 本地部署脚本 - 适合个人使用，无需 GitHub Actions
echo "🚀 本地部署股票平台期扫描工具"
echo "================================"

# 检查是否在正确的目录
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ 错误: 请在项目根目录运行此脚本"
    exit 1
fi

# 检查 Docker 是否运行
if ! docker info >/dev/null 2>&1; then
    echo "❌ 错误: Docker 未运行，请先启动 Docker"
    exit 1
fi

# 拉取最新代码（如果是 git 仓库）
if [ -d ".git" ]; then
    echo "📥 拉取最新代码..."
    git pull origin main || git pull origin master
fi

# 检查端口冲突
echo "🔍 检查端口冲突..."
if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "⚠️  端口 3000 被占用，建议运行 ./configure-ports.sh 配置其他端口"
    read -p "是否继续部署？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 停止现有服务
echo "🛑 停止现有服务..."
docker-compose down

# 清理旧镜像（可选）
read -p "是否清理旧的 Docker 镜像？(y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🧹 清理旧镜像..."
    docker system prune -f
fi

# 构建并启动服务
echo "🔨 构建并启动服务..."
if ! docker-compose up --build -d; then
    echo "❌ 构建失败！"
    echo ""
    echo "🔍 快速修复步骤:"
    echo "1. 运行快速测试: ./quick-test.sh"
    echo "2. 运行修复脚本: ./fix-build.sh"
    echo "3. 查看详细错误: docker-compose up --build"
    echo "4. 清理并重试: docker system prune -f && docker-compose up --build -d"
    echo ""
    echo "📋 常见问题:"
    echo "- 网络连接问题: 检查网络连接"
    echo "- 内存不足: 增加 Docker 内存限制"
    echo "- 端口冲突: 运行 ./configure-ports.sh"
    exit 1
fi

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 15

# 检查服务状态
echo "📊 检查服务状态..."
docker-compose ps

# 健康检查
echo "🏥 进行健康检查..."
sleep 5

# 检查前端
if curl -f http://localhost:3000 >/dev/null 2>&1; then
    echo "✅ 前端服务正常"
else
    echo "❌ 前端服务异常"
fi

# 检查后端
if curl -f http://localhost:8001/health >/dev/null 2>&1; then
    echo "✅ 后端服务正常"
else
    echo "❌ 后端服务异常"
fi

# 显示访问信息
echo ""
echo "🎉 部署完成！"
echo "===================="
echo "📱 前端访问地址: http://localhost:3000"
echo "🔧 后端 API 地址: http://localhost:8001"
echo "📋 API 文档地址: http://localhost:8001/docs"
echo ""
echo "📝 常用命令:"
echo "  查看日志: docker-compose logs -f"
echo "  停止服务: docker-compose down"
echo "  重启服务: docker-compose restart"
echo ""
echo "🔍 如果无法访问，请检查:"
echo "  1. 防火墙设置"
echo "  2. 端口是否被占用"
echo "  3. Docker 容器状态: docker-compose ps"

# 询问是否查看日志
echo ""
read -p "是否查看实时日志？(y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "📋 显示实时日志 (按 Ctrl+C 退出)..."
    docker-compose logs -f
fi
