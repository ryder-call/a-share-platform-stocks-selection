# 🚀 快速部署指南

## 端口冲突解决方案

如果你的服务器 80 和 8080 端口已被占用，按以下步骤操作：

### 方法一：自动配置（推荐）

```bash
# 1. 检查端口状态
./check-ports.sh

# 2. 自动配置可用端口
./configure-ports.sh

# 3. 部署应用
./deploy.sh
```

### 方法二：手动配置

1. **编辑 docker-compose.yml**
```yaml
# 修改前端端口（第28行左右）
ports:
  - "3000:80"  # 改为你想要的端口

# 修改后端端口（如果需要，第11行左右）
ports:
  - "8002:8001"  # 改为你想要的端口
```

2. **部署应用**
```bash
./deploy.sh
```

## 访问地址

部署完成后：
- **前端**: http://your-server-ip:3000
- **后端 API**: http://your-server-ip:8001

## 常用命令

```bash
# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 更新代码
git pull origin main
docker-compose down
docker-compose up --build -d
```

## 故障排除

### 端口仍然冲突？
```bash
# 查看端口占用
lsof -i :3000
lsof -i :8001

# 终止占用进程
sudo kill -9 <PID>
```

### 容器启动失败？
```bash
# 查看详细日志
docker-compose logs backend
docker-compose logs frontend

# 重新构建
docker-compose build --no-cache
docker-compose up -d
```

### 前端无法访问后端？
检查 nginx 配置中的代理设置，确保后端服务名称正确。

## 生产环境优化

1. **使用域名**
   - 配置域名解析
   - 申请 SSL 证书

2. **性能优化**
   - 启用 gzip 压缩
   - 配置 CDN

3. **安全配置**
   - 配置防火墙
   - 设置环境变量

## 需要帮助？

1. 查看完整文档：`cat DEPLOYMENT.md`
2. 检查端口状态：`./check-ports.sh`
3. 配置端口：`./configure-ports.sh`
4. 提交 Issue 到 GitHub
