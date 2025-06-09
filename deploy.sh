#!/bin/bash

# 股票平台期扫描工具部署脚本
echo "🚀 开始部署股票平台期扫描工具..."

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装，请先安装 Docker"
    exit 1
fi

# 检查 Docker Compose 是否安装
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose 未安装，请先安装 Docker Compose"
    exit 1
fi

# 停止并删除现有容器
echo "🛑 停止现有容器..."
docker-compose down

# 清理旧镜像（可选）
read -p "是否清理旧镜像？(y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🧹 清理旧镜像..."
    docker system prune -f
fi

# 构建并启动服务
echo "🔨 构建并启动服务..."
docker-compose up --build -d

# 检查服务状态
echo "📊 检查服务状态..."
sleep 10
docker-compose ps

# 显示访问信息
echo ""
echo "✅ 部署完成！"
echo "🌐 前端访问地址: http://localhost:3000"
echo "🔧 后端 API 地址: http://localhost:8001"
echo "📝 查看日志: docker-compose logs -f"
echo "🛑 停止服务: docker-compose down"
echo ""
echo "💡 如果端口仍有冲突，请修改 docker-compose.yml 中的端口映射"
