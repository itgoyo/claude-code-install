# Claude Code 一键安装脚本 (Windows)
# 用法:
#   国际直连: irm https://raw.githubusercontent.com/itgoyo/claude-code-install/main/cc.ps1 | iex
#   国内加速: irm https://mirror.ghproxy.com/https://raw.githubusercontent.com/itgoyo/claude-code-install/main/cc.ps1 | iex

param(
    [string]$Mirror = "auto"  # auto, cn, global
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = 'SilentlyContinue'

# 检测是否在中国大陆（通过连接测试）
function Test-ChinaNetwork {
    try {
        $result = Invoke-WebRequest -Uri "https://registry.npmmirror.com" -TimeoutSec 3 -UseBasicParsing -ErrorAction Stop
        return $true
    } catch { }
    return $false
}

# 检测网络环境
if ($Mirror -eq "auto") {
    Write-Host "正在检测网络环境..." -ForegroundColor Cyan
    try {
        Invoke-WebRequest -Uri "https://registry.npmjs.org" -TimeoutSec 4 -UseBasicParsing -ErrorAction Stop | Out-Null
        $Mirror = "global"
        Write-Host "✓ 使用国际源" -ForegroundColor Green
    } catch {
        $Mirror = "cn"
        Write-Host "✓ 切换国内加速源" -ForegroundColor Yellow
    }
}

# 根据环境选择 npm registry
if ($Mirror -eq "cn") {
    $NPM_REGISTRY = "https://registry.npmmirror.com"
    Write-Host "npm 镜像: 淘宝源 (npmmirror.com)" -ForegroundColor Yellow
} else {
    $NPM_REGISTRY = "https://registry.npmjs.org"
    Write-Host "npm 镜像: 官方源 (npmjs.org)" -ForegroundColor Green
}

# 检查 Node.js
Write-Host ""
Write-Host "=== Claude Code 安装程序 ===" -ForegroundColor Cyan
Write-Host "by itgoyo | https://github.com/itgoyo/claude-code-install" -ForegroundColor DarkGray
Write-Host ""

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Error "未检测到 Node.js，请先安装 Node.js (https://nodejs.org) 再运行此脚本。"
    exit 1
}

$nodeVersion = (node --version)
Write-Host "✓ Node.js $nodeVersion" -ForegroundColor Green

# 安装 Claude Code
Write-Host "正在安装 Claude Code..." -ForegroundColor Cyan

try {
    & npm install -g @anthropic-ai/claude-code --registry $NPM_REGISTRY
    if ($LASTEXITCODE -ne 0) { throw "npm install 失败" }
} catch {
    Write-Error "安装失败: $_"
    exit 1
}

# 验证安装
if (Get-Command claude -ErrorAction SilentlyContinue) {
    $claudeVersion = (claude --version 2>$null)
    Write-Host ""
    Write-Host "✓ Claude Code 安装成功！版本: $claudeVersion" -ForegroundColor Green
    Write-Host ""
    Write-Host "运行 'claude' 开始使用。" -ForegroundColor Cyan
} else {
    Write-Warning "Claude Code 已安装，但 'claude' 命令未找到，请重启终端后重试。"
}
