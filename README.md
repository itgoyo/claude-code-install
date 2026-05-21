# Claude Code 一键安装

by [itgoyo](https://github.com/itgoyo)

## 🚀 一行命令安装

### Windows (PowerShell)

**国际直连：**
```powershell
irm https://raw.githubusercontent.com/itgoyo/claude-code-install/main/cc.ps1 | iex
```

**国内加速（推荐中国用户）：**
```powershell
irm https://mirror.ghproxy.com/https://raw.githubusercontent.com/itgoyo/claude-code-install/main/cc.ps1 | iex
```

---

### macOS / Linux (Bash)

**国际直连：**
```bash
curl -fsSL https://raw.githubusercontent.com/itgoyo/claude-code-install/main/cc.sh | bash
```

**国内加速（推荐中国用户）：**
```bash
curl -fsSL https://mirror.ghproxy.com/https://raw.githubusercontent.com/itgoyo/claude-code-install/main/cc.sh | bash
```

---

## ✨ 特性

- 🌍 **自动检测网络环境** — 国内自动切换淘宝 npm 镜像，国外走官方源
- 📦 **npm 加速** — 国内使用 `registry.npmmirror.com`（淘宝源）
- 🐚 **跨平台** — 支持 Windows / macOS / Linux

## 📋 前置要求

- [Node.js](https://nodejs.org) >= 18

## 🔧 手动安装

```bash
# 国际
npm install -g @anthropic-ai/claude-code

# 国内加速
npm install -g @anthropic-ai/claude-code --registry https://registry.npmmirror.com
```
