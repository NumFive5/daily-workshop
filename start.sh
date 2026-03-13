#!/bin/bash

echo "🎀 吴昊爱胡珍珍 - 快速启动脚本"
echo "================================"
echo ""

# 检查后端
echo "✅ 检查后端服务..."
if curl -s http://localhost:3000/health > /dev/null; then
    echo "   后端正在运行 ✅ (http://localhost:3000)"
else
    echo "   ⚠️  后端未启动"
    echo "   提示：运行 'cd wh-love-hzz-server && npm start' 启动后端"
fi

echo ""
echo "🚀 启动前端的几种方式："
echo ""
echo "1️⃣  使用 Python 服务器（最简单）"
echo "   cd wh-love-hzz/build/web"
echo "   python3 -m http.server 5000"
echo "   然后访问：http://localhost:5000"
echo ""
echo "2️⃣  使用 Flutter（需要安装 Flutter）"
echo "   cd wh-love-hzz"
echo "   flutter pub get"
echo "   flutter run -d web"
echo ""
echo "3️⃣  使用 Docker"
echo "   cd wh-love-hzz"
echo "   docker build -t love-app ."
echo "   docker run -p 5000:5000 love-app"
echo ""
echo "选择一个方式，然后在浏览器中打开相应的 URL"
echo ""
