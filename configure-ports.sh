#!/bin/bash

# 端口配置脚本
echo "🔧 股票平台期扫描工具 - 端口配置"
echo "=================================="

# 检查当前端口占用情况
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo "❌ 端口 $port 已被占用"
        return 1
    else
        echo "✅ 端口 $port 可用"
        return 0
    fi
}

# 默认端口
DEFAULT_FRONTEND_PORT=3000
DEFAULT_BACKEND_PORT=8001

echo ""
echo "检查默认端口占用情况..."
echo "------------------------"

# 检查前端端口
echo -n "前端端口 $DEFAULT_FRONTEND_PORT: "
check_port $DEFAULT_FRONTEND_PORT
FRONTEND_PORT_AVAILABLE=$?

# 检查后端端口
echo -n "后端端口 $DEFAULT_BACKEND_PORT: "
check_port $DEFAULT_BACKEND_PORT
BACKEND_PORT_AVAILABLE=$?

echo ""

# 如果默认端口都可用，直接使用
if [ $FRONTEND_PORT_AVAILABLE -eq 0 ] && [ $BACKEND_PORT_AVAILABLE -eq 0 ]; then
    echo "✅ 默认端口都可用，无需修改配置"
    echo "前端将运行在: http://localhost:$DEFAULT_FRONTEND_PORT"
    echo "后端将运行在: http://localhost:$DEFAULT_BACKEND_PORT"
    exit 0
fi

# 如果有端口冲突，提供解决方案
echo "⚠️  检测到端口冲突，请选择解决方案："
echo ""
echo "1. 自动分配可用端口"
echo "2. 手动指定端口"
echo "3. 查看端口占用详情"
echo "4. 退出"
echo ""

read -p "请选择 (1-4): " choice

case $choice in
    1)
        echo ""
        echo "🔍 正在寻找可用端口..."
        
        # 寻找可用的前端端口
        FRONTEND_PORT=$DEFAULT_FRONTEND_PORT
        while lsof -Pi :$FRONTEND_PORT -sTCP:LISTEN -t >/dev/null 2>&1; do
            FRONTEND_PORT=$((FRONTEND_PORT + 1))
        done
        
        # 寻找可用的后端端口
        BACKEND_PORT=$DEFAULT_BACKEND_PORT
        while lsof -Pi :$BACKEND_PORT -sTCP:LISTEN -t >/dev/null 2>&1; do
            BACKEND_PORT=$((BACKEND_PORT + 1))
        done
        
        echo "✅ 找到可用端口:"
        echo "   前端: $FRONTEND_PORT"
        echo "   后端: $BACKEND_PORT"
        ;;
    2)
        echo ""
        read -p "请输入前端端口 (默认 $DEFAULT_FRONTEND_PORT): " FRONTEND_PORT
        FRONTEND_PORT=${FRONTEND_PORT:-$DEFAULT_FRONTEND_PORT}
        
        read -p "请输入后端端口 (默认 $DEFAULT_BACKEND_PORT): " BACKEND_PORT
        BACKEND_PORT=${BACKEND_PORT:-$DEFAULT_BACKEND_PORT}
        
        # 验证端口
        if ! check_port $FRONTEND_PORT; then
            echo "❌ 前端端口 $FRONTEND_PORT 仍被占用"
            exit 1
        fi
        
        if ! check_port $BACKEND_PORT; then
            echo "❌ 后端端口 $BACKEND_PORT 仍被占用"
            exit 1
        fi
        ;;
    3)
        echo ""
        echo "📊 端口占用详情:"
        echo "----------------"
        if lsof -Pi :$DEFAULT_FRONTEND_PORT -sTCP:LISTEN >/dev/null 2>&1; then
            echo "前端端口 $DEFAULT_FRONTEND_PORT 被以下进程占用:"
            lsof -Pi :$DEFAULT_FRONTEND_PORT -sTCP:LISTEN
        fi
        
        if lsof -Pi :$DEFAULT_BACKEND_PORT -sTCP:LISTEN >/dev/null 2>&1; then
            echo "后端端口 $DEFAULT_BACKEND_PORT 被以下进程占用:"
            lsof -Pi :$DEFAULT_BACKEND_PORT -sTCP:LISTEN
        fi
        
        echo ""
        echo "💡 提示: 你可以使用 'sudo kill -9 <PID>' 来终止占用端口的进程"
        echo "或者重新运行此脚本选择其他端口"
        exit 0
        ;;
    4)
        echo "退出配置"
        exit 0
        ;;
    *)
        echo "❌ 无效选择"
        exit 1
        ;;
esac

# 更新 docker-compose.yml 文件
echo ""
echo "📝 正在更新配置文件..."

# 备份原文件
cp docker-compose.yml docker-compose.yml.backup
echo "✅ 已备份原配置文件为 docker-compose.yml.backup"

# 更新前端端口
sed -i.tmp "s/\"[0-9]*:80\"/\"$FRONTEND_PORT:80\"/g" docker-compose.yml

# 更新后端端口（如果需要）
if [ $BACKEND_PORT -ne $DEFAULT_BACKEND_PORT ]; then
    sed -i.tmp "s/\"$DEFAULT_BACKEND_PORT:$DEFAULT_BACKEND_PORT\"/\"$BACKEND_PORT:$BACKEND_PORT\"/g" docker-compose.yml
    sed -i.tmp "s/PORT=$DEFAULT_BACKEND_PORT/PORT=$BACKEND_PORT/g" docker-compose.yml
fi

# 清理临时文件
rm -f docker-compose.yml.tmp

echo "✅ 配置文件更新完成"
echo ""
echo "🚀 新的访问地址:"
echo "   前端: http://localhost:$FRONTEND_PORT"
echo "   后端: http://localhost:$BACKEND_PORT"
echo ""
echo "💡 现在可以运行 './deploy.sh' 来部署应用"
