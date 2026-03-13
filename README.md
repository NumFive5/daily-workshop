# 吴昊爱胡珍珍 🎀

一个用 Flutter + Node.js 构建的浪漫表白 Web 应用

## 🚀 快速开始

### 后端已启动 ✅

后端服务已在 `http://localhost:3000` 运行

**测试后端：**
```bash
curl http://localhost:3000/health
```

**API 端点：**

| 方法 | 端点 | 说明 |
|-----|-----|------|
| GET | `/api/events` | 获取所有时间轴事件 |
| POST | `/api/events` | 添加新事件 |
| GET | `/api/messages` | 获取所有留言 |
| POST | `/api/messages` | 添加新留言 |
| GET | `/health` | 健康检查 |

**示例请求：**
```bash
# 获取事件
curl http://localhost:3000/api/events | jq .

# 添加新事件
curl -X POST http://localhost:3000/api/events \
  -H "Content-Type: application/json" \
  -d '{"date":"2025-01-01","title":"新年快乐","description":"新的一年，新的开始"}'
```

### 前端启动指南

#### 方式1：使用 Docker（推荐）

```bash
cd wh-love-hzz
docker build -t love-app .
docker run -p 5000:5000 love-app
```

然后访问 `http://localhost:5000`

#### 方式2：直接使用 Flutter

**前置条件：**
- 安装 Flutter SDK: https://flutter.dev/docs/get-started/install
- 确保 `flutter` 在 PATH 中

```bash
cd wh-love-hzz

# 获取依赖
flutter pub get

# 运行前端（Web）
flutter run -d web

# 或者构建并在浏览器中打开
flutter run -d web --release
```

#### 方式3：使用 Python 本地服务器（最简单）

我们已为 Web 版本构建了文件，可以用 Python 服务器快速运行：

```bash
cd wh-love-hzz/build/web
python3 -m http.server 5000
```

然后访问 `http://localhost:5000`

## 📂 项目结构

```
wh-love-hzz/
├── lib/
│   ├── main.dart              # 主应用入口
│   └── pages/
│       ├── home_page.dart     # 首页（导航）
│       ├── poem_page.dart     # 诗歌页面
│       ├── timeline_page.dart # 时间轴页面（连接后端）
│       └── gallery_page.dart  # 相册页面
├── web/                       # Web 资源
├── pubspec.yaml              # Flutter 依赖
└── README.md

wh-love-hzz-server/
├── server.js                 # Express 服务器
├── package.json              # Node 依赖
└── README.md
```

## 🎯 功能

### 💕 诗歌页面
- 显示藏头诗
- 含义说明

### ⏰ 时间轴页面
- 从后端获取重要事件
- 美观的时间轴展示
- 可添加新事件

### 📸 相册页面
- 展示回忆照片
- 点击查看详情

## 🔧 技术栈

**前端：**
- Flutter 3.0+
- Material Design 3
- HTTP 客户端（REST API）

**后端：**
- Node.js
- Express.js
- CORS 支持

## 🐛 故障排除

### 前端无法连接后端？

1. 确保后端正在运行：
   ```bash
   curl http://localhost:3000/health
   ```

2. 如果后端已启动但前端连接失败，可能是 CORS 问题
   - 后端已配置 CORS，应该没有问题

3. 检查防火墙是否阻止了 3000 端口

### Flutter 命令不存在？

按照官方文档安装 Flutter: https://flutter.dev/docs/get-started/install

或者使用 Docker 方式运行

## 📝 后端操作示例

### 获取所有事件
```bash
curl http://localhost:3000/api/events
```

### 添加新事件
```bash
curl -X POST http://localhost:3000/api/events \
  -H "Content-Type: application/json" \
  -d '{
    "date": "2025-02-14",
    "title": "情人节",
    "description": "我们的特殊日子"
  }'
```

### 获取所有留言
```bash
curl http://localhost:3000/api/messages
```

### 添加新留言
```bash
curl -X POST http://localhost:3000/api/messages \
  -H "Content-Type: application/json" \
  -d '{
    "author": "吴昊",
    "content": "珍珍，永远爱你❤️"
  }'
```

## 💝 开发

修改前端：
```bash
cd wh-love-hzz
flutter run -d web --hot  # Hot reload 开发模式
```

修改后端：
```bash
cd wh-love-hzz-server
npm start
# 修改后自动重启，或手动重启
```

## 📦 部署

**前端部署到 Vercel/Netlify：**
```bash
flutter build web
# 上传 build/web 文件夹到 Vercel/Netlify
```

**后端部署到 Heroku/Railway：**
```bash
# 按照各平台文档配置
git push heroku main
```

---

❤️ 吴昊爱胡珍珍 ❤️
