# 🔧 故障排除指南

## 常见构建错误及解决方案

### 1. 前端构建错误

#### 错误：`vite: not found`
```
sh: vite: not found
The command '/bin/sh -c npm run build' returned a non-zero code: 127
```

**原因**: vite 在 devDependencies 中，但使用了 `--only=production` 参数

**解决方案**:
```bash
# 已修复，现在使用 npm ci 安装所有依赖
./quick-test.sh  # 测试修复是否生效
```

#### 错误：`nginx user already exists`
```
addgroup: group 'nginx' in use
```

**原因**: nginx:alpine 镜像已包含 nginx 用户

**解决方案**: 已移除用户创建代码，直接使用现有用户

### 2. 端口冲突错误

#### 错误：端口被占用
```
Error starting userland proxy: listen tcp4 0.0.0.0:3000: bind: address already in use
```

**解决方案**:
```bash
# 方法1: 自动配置端口
./configure-ports.sh

# 方法2: 手动检查并终止进程
lsof -i :3000
sudo kill -9 <PID>

# 方法3: 修改 docker-compose.yml
# 将 "3000:80" 改为其他端口，如 "3001:80"
```

### 3. Docker 相关错误

#### 错误：Docker 未运行
```
Cannot connect to the Docker daemon
```

**解决方案**:
```bash
# macOS/Windows: 启动 Docker Desktop
# Linux: 启动 Docker 服务
sudo systemctl start docker
```

#### 错误：内存不足
```
docker: Error response from daemon: failed to create shim
```

**解决方案**:
```bash
# 增加 Docker 内存限制（Docker Desktop 设置）
# 或清理不用的镜像和容器
docker system prune -a
```

### 4. 网络相关错误

#### 错误：npm 安装失败
```
npm ERR! network request failed
```

**解决方案**:
```bash
# 设置 npm 镜像源
npm config set registry https://registry.npmmirror.com/

# 或在 Dockerfile 中添加
RUN npm config set registry https://registry.npmmirror.com/
```

#### 错误：无法访问服务
```
curl: (7) Failed to connect to localhost port 3000
```

**解决方案**:
```bash
# 检查服务状态
docker-compose ps

# 检查日志
docker-compose logs frontend
docker-compose logs backend

# 检查端口映射
docker port <container_name>
```

## 🛠️ 快速修复工具

### 1. 快速测试
```bash
./quick-test.sh
```
测试 Docker 构建是否正常

### 2. 完整修复
```bash
./fix-build.sh
```
清理环境并重新构建

### 3. 端口配置
```bash
./configure-ports.sh
```
自动配置可用端口

### 4. 端口检查
```bash
./check-ports.sh
```
检查端口占用情况

## 🔍 调试命令

### 查看容器状态
```bash
docker-compose ps
docker-compose logs -f
```

### 进入容器调试
```bash
# 进入前端容器
docker-compose exec frontend sh

# 进入后端容器
docker-compose exec backend bash
```

### 手动构建测试
```bash
# 单独构建前端
docker build -t test-frontend .

# 单独构建后端
docker build -t test-backend ./api

# 查看构建过程
docker-compose build --no-cache
```

### 清理环境
```bash
# 停止所有服务
docker-compose down

# 清理缓存
docker system prune -f

# 清理所有镜像（谨慎使用）
docker system prune -a
```

## 📞 获取帮助

如果以上方法都无法解决问题：

1. **查看详细日志**
   ```bash
   docker-compose logs --tail=50
   ```

2. **检查系统资源**
   ```bash
   docker system df
   free -h  # Linux
   ```

3. **提供错误信息**
   - 完整的错误日志
   - 系统信息（OS、Docker 版本）
   - 运行的命令

4. **常见解决方案**
   - 重启 Docker Desktop
   - 重启计算机
   - 检查防火墙设置
   - 更新 Docker 版本

## 🎯 预防措施

1. **定期清理**
   ```bash
   # 每周运行一次
   docker system prune -f
   ```

2. **监控资源**
   - 确保有足够的磁盘空间
   - 监控内存使用情况

3. **备份配置**
   - 备份 docker-compose.yml
   - 记录自定义端口配置

4. **版本管理**
   - 使用固定版本的依赖
   - 定期更新基础镜像
