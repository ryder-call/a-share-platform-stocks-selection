# 股票平台期扫描工具部署指南

## 🚀 快速部署（推荐）

### 方案一：Docker Compose 一键部署

这是最简单的部署方式，适合大多数场景。

#### 前置要求
- Docker 和 Docker Compose 已安装
- 服务器有足够的内存（建议至少 2GB）

#### 部署步骤

1. **克隆项目到服务器**
```bash
git clone https://github.com/your-username/a-share-platform-stocks-selection.git
cd a-share-platform-stocks-selection
```

2. **配置端口（如果有冲突）**
```bash
# 检查并配置可用端口
chmod +x configure-ports.sh
./configure-ports.sh
```

3. **给部署脚本执行权限**
```bash
chmod +x deploy.sh
```

4. **运行部署脚本**
```bash
./deploy.sh
```

5. **访问应用**
- 前端：http://your-server-ip:3000（默认端口）
- 后端 API：http://your-server-ip:8001（默认端口）

> 💡 **端口说明**: 默认使用 3000 端口（前端）和 8001 端口（后端）。如果这些端口被占用，请运行 `./configure-ports.sh` 脚本自动配置可用端口。

#### 常用命令
```bash
# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 更新代码并重新部署
git pull origin main
docker-compose down
docker-compose up --build -d
```

## 🔧 手动部署

### 方案二：传统部署方式

如果你不想使用 Docker，可以手动部署前后端。

#### 后端部署

1. **安装 Python 依赖**
```bash
cd api
pip install -r requirements.txt
```

2. **启动后端服务**
```bash
# 开发环境
python run.py

# 生产环境（推荐使用 gunicorn）
pip install gunicorn
gunicorn -w 4 -k uvicorn.workers.UvicornWorker index:app --bind 0.0.0.0:8001
```

#### 前端部署

1. **安装 Node.js 依赖**
```bash
npm install
```

2. **构建前端**
```bash
npm run build
```

3. **部署到 Web 服务器**
```bash
# 将 dist 目录内容复制到 nginx 或 apache 的 web 根目录
cp -r dist/* /var/www/html/
```

4. **配置 Nginx（示例）**
```nginx
server {
    listen 80;
    server_name your-domain.com;

    # 前端静态文件
    location / {
        root /var/www/html;
        index index.html;
        try_files $uri $uri/ /index.html;
    }

    # API 代理
    location /api/ {
        proxy_pass http://localhost:8001/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

## 🌐 云服务器部署

### 方案三：使用 GitHub Actions 自动部署

1. **在 GitHub 仓库设置 Secrets**
   - `HOST`: 服务器 IP 地址
   - `USERNAME`: 服务器用户名
   - `SSH_KEY`: SSH 私钥
   - `DOCKER_USERNAME`: Docker Hub 用户名（可选）
   - `DOCKER_PASSWORD`: Docker Hub 密码（可选）

2. **在服务器上准备环境**
```bash
# 安装 Docker 和 Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 克隆项目
git clone https://github.com/your-username/a-share-platform-stocks-selection.git
cd a-share-platform-stocks-selection
```

3. **推送代码触发自动部署**
```bash
git push origin main
```

## 📊 监控和维护

### 健康检查
```bash
# 检查后端健康状态
curl http://localhost:8001/health

# 检查前端是否正常
curl http://localhost/
```

### 日志查看
```bash
# Docker 环境
docker-compose logs -f backend
docker-compose logs -f frontend

# 传统部署
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

### 性能优化建议

1. **内存优化**
   - 建议服务器至少 2GB 内存
   - 可以调整 Docker 容器的内存限制

2. **网络优化**
   - 使用 CDN 加速静态资源
   - 启用 gzip 压缩

3. **数据库优化**
   - 如果需要持久化数据，考虑添加 Redis 或 PostgreSQL

## 🔒 安全配置

### 生产环境安全建议

1. **HTTPS 配置**
```bash
# 使用 Let's Encrypt 获取免费 SSL 证书
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

2. **防火墙配置**
```bash
# 只开放必要端口
sudo ufw allow 22    # SSH
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS
sudo ufw enable
```

3. **环境变量配置**
```bash
# 创建 .env 文件存储敏感信息
echo "API_SECRET_KEY=your-secret-key" > .env
echo "DATABASE_URL=your-database-url" >> .env
```

## 🆘 故障排除

### 常见问题

1. **端口冲突**
   ```bash
   # 方法1: 使用端口配置脚本（推荐）
   ./configure-ports.sh

   # 方法2: 手动检查端口占用
   lsof -i :3000  # 检查前端端口
   lsof -i :8001  # 检查后端端口

   # 方法3: 手动修改 docker-compose.yml
   # 将 "3000:80" 改为 "你的端口:80"
   # 将 "8001:8001" 改为 "你的端口:8001"

   # 方法4: 终止占用端口的进程
   sudo kill -9 <PID>
   ```

2. **内存不足**
   - 增加服务器内存
   - 减少并发工作进程数量

3. **网络连接问题**
   - 检查防火墙设置
   - 确认 API 地址配置正确

### 获取帮助

如果遇到部署问题，请：
1. 查看日志文件
2. 检查网络连接
3. 确认依赖版本
4. 提交 GitHub Issue

## 📝 更新日志

- v1.0.0: 初始版本，支持 Docker 部署
- 后续版本将添加更多部署选项和优化
