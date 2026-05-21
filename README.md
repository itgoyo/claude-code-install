# Claude Code 一键安装

> by [itgoyo](https://github.com/itgoyo)

一行命令安装 Claude Code，自动检测网络环境，国内自动切换加速源。

---

## 安装命令

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/itgoyo/claude-code-install/main/cc.ps1 | iex
```

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/itgoyo/claude-code-install/main/cc.sh | bash
```

---

## 国内加速（如果直连慢）

### Windows

```powershell
irm https://ghproxy.net/https://raw.githubusercontent.com/itgoyo/claude-code-install/main/cc.ps1 | iex
```

备用：

```powershell
irm https://ghfast.top/https://raw.githubusercontent.com/itgoyo/claude-code-install/main/cc.ps1 | iex
```

### macOS / Linux

```bash
curl -fsSL https://ghproxy.net/https://raw.githubusercontent.com/itgoyo/claude-code-install/main/cc.sh | bash
```

备用：

```bash
curl -fsSL https://ghfast.top/https://raw.githubusercontent.com/itgoyo/claude-code-install/main/cc.sh | bash
```

---

## 功能特性

- ✅ 自动检测网络，国内自动切换淘宝 npm 镜像
- ✅ npm 安装失败自动 fallback 备用源
- ✅ 检查 Node.js 是否已安装
- ✅ 安装后自动验证

---

## 前置要求

- [Node.js](https://nodejs.org) 18+（[国内镜像](https://registry.npmmirror.com/binary.html?path=node/)）
