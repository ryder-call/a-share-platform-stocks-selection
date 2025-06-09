#!/bin/bash

# 构建问题修复脚本
echo "🔧 修复 Docker 构建问题"
echo "======================"

echo ""
echo "🧹 第1步: 清理 Docker 环境..."
echo "------------------------------"

# 停止所有相关容器
docker-compose down 2>/dev/null

# 清理 Docker 缓存和未使用的镜像
echo "清理 Docker 缓存..."
docker system prune -f

# 清理项目相关的镜像
echo "清理项目镜像..."
docker images | grep stock-platform | awk '{print $3}' | xargs -r docker rmi -f 2>/dev/null

echo ""
echo "📦 第2步: 清理 Node.js 依赖..."
echo "------------------------------"

# 清理 node_modules
if [ -d "node_modules" ]; then
    echo "删除 node_modules..."
    rm -rf node_modules
fi

# 清理 npm 缓存
echo "清理 npm 缓存..."
npm cache clean --force 2>/dev/null || echo "npm 未安装，跳过缓存清理"

echo ""
echo "🔍 第3步: 验证项目配置..."
echo "-------------------------"

# 检查关键文件
files=("package.json" "vite.config.js" "Dockerfile" "nginx.conf")
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file 缺失"
        exit 1
    fi
done

echo ""
echo "🔨 第4步: 测试本地构建..."
echo "-------------------------"

# 如果本地有 Node.js，先测试本地构建
if command -v npm &> /dev/null; then
    echo "安装依赖..."
    if npm install; then
        echo "✅ 依赖安装成功"
        
        echo "测试构建..."
        if npm run build; then
            echo "✅ 本地构建成功"
            echo "清理构建产物..."
            rm -rf dist
        else
            echo "❌ 本地构建失败"
            echo "请检查 package.json 和 vite.config.js 配置"
            exit 1
        fi
    else
        echo "❌ 依赖安装失败"
        exit 1
    fi
else
    echo "⚠️  本地未安装 Node.js，跳过本地构建测试"
fi

echo ""
echo "🐳 第5步: 测试 Docker 构建..."
echo "-----------------------------"

# 单独构建前端镜像
echo "构建前端镜像..."
if docker build -t stock-platform-frontend-test .; then
    echo "✅ 前端镜像构建成功"
    docker rmi stock-platform-frontend-test
else
    echo "❌ 前端镜像构建失败"
    echo ""
    echo "🔍 可能的原因:"
    echo "1. 网络连接问题"
    echo "2. Docker 内存不足"
    echo "3. package.json 配置问题"
    echo ""
    echo "💡 建议:"
    echo "1. 检查网络连接"
    echo "2. 增加 Docker 内存限制"
    echo "3. 手动运行: docker build -t test ."
    exit 1
fi

# 单独构建后端镜像
echo "构建后端镜像..."
if docker build -t stock-platform-backend-test ./api; then
    echo "✅ 后端镜像构建成功"
    docker rmi stock-platform-backend-test
else
    echo "❌ 后端镜像构建失败"
    exit 1
fi

echo ""
echo "🎉 修复完成！"
echo "============"
echo "✅ 所有构建测试通过"
echo "💡 现在可以运行: ./local-deploy.sh"

echo ""
echo "📝 如果问题仍然存在:"
echo "1. 重启 Docker Desktop"
echo "2. 检查系统内存是否充足"
echo "3. 尝试手动构建: docker-compose build"
