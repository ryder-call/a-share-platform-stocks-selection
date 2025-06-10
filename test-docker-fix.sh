#!/bin/bash

echo "🔧 Testing Docker import fixes..."
echo "================================"

# Build the backend Docker image
echo "📦 Building backend Docker image..."
cd api
docker build -t test-backend .

if [ $? -ne 0 ]; then
    echo "❌ Docker build failed!"
    exit 1
fi

echo "✅ Docker build successful!"

# Test the imports in the container
echo "🧪 Testing imports in container..."
docker run --rm test-backend python /app/test-imports.py

if [ $? -eq 0 ]; then
    echo "✅ Import test successful!"
else
    echo "❌ Import test failed!"
    exit 1
fi

echo "🎉 All tests passed! The import fixes are working."
