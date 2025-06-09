#!/bin/bash

# 测试构建脚本
echo "🧪 测试 Docker 构建过程"
echo "======================"

# 检查 Docker 是否运行
if ! docker info >/dev/null 2>&1; then
    echo "❌ 错误: Docker 未运行，请先启动 Docker"
    exit 1
fi

echo ""
echo "📋 构建信息:"
echo "------------"
echo "Node.js 版本: $(node --version 2>/dev/null || echo '未安装')"
echo "npm 版本: $(npm --version 2>/dev/null || echo '未安装')"
echo "Docker 版本: $(docker --version)"

echo ""
echo "🔍 检查项目文件..."

# 检查必要文件
files=("package.json" "vite.config.js" "Dockerfile" "nginx.conf")
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file 存在"
    else
        echo "❌ $file 缺失"
        exit 1
    fi
done

echo ""
echo "📦 检查依赖配置..."

# 检查 vite 是否在 devDependencies 中
if grep -q '"vite"' package.json; then
    echo "✅ vite 依赖已配置"
else
    echo "❌ vite 依赖缺失"
    exit 1
fi

echo ""
echo "🔨 开始构建前端镜像..."
echo "------------------------"

# 构建前端镜像
if docker build -t stock-platform-frontend-test .; then
    echo "✅ 前端镜像构建成功"
else
    echo "❌ 前端镜像构建失败"
    echo ""
    echo "🔍 故障排除建议:"
    echo "1. 检查网络连接"
    echo "2. 清理 Docker 缓存: docker system prune -f"
    echo "3. 检查 package.json 中的依赖"
    echo "4. 手动测试构建: npm install && npm run build"
    exit 1
fi

echo ""
echo "🔨 开始构建后端镜像..."
echo "------------------------"

# 构建后端镜像
if docker build -t stock-platform-backend-test ./api; then
    echo "✅ 后端镜像构建成功"
else
    echo "❌ 后端镜像构建失败"
    exit 1
fi

echo ""
echo "🧹 清理测试镜像..."
docker rmi stock-platform-frontend-test stock-platform-backend-test >/dev/null 2>&1

echo ""
echo "🎉 构建测试完成！"
echo "================"
echo "✅ 所有镜像构建成功"
echo "💡 现在可以运行: ./local-deploy.sh"

echo ""
echo "📝 如果仍有问题，请尝试:"
echo "1. 清理 Docker 缓存: docker system prune -a"
echo "2. 重新安装依赖: rm -rf node_modules && npm install"
echo "3. 检查网络连接和防火墙设置"
