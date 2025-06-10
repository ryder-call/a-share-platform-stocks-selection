import uvicorn
import sys
import os

# 添加当前目录到 Python 路径，以便导入模块
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))


if __name__ == "__main__":
    print("Starting FastAPI server...")
    # 使用环境变量来设置主机和端口，便于 Docker 部署
    host = os.getenv("HOST", "127.0.0.1")
    port = int(os.getenv("PORT", "8001"))
    # 在 Docker 容器中，我们直接在 api 目录下，所以导入 index:app
    uvicorn.run("index:app", host=host, port=port, reload=True)
