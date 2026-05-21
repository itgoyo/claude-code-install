# Claude Code 一键安装脚本 (Windows PowerShell)
# 用法:
#   irm https://raw.githubusercontent.com/itgoyo/claude-code-install/main/cc.ps1 | iex

param(
    [string]$Mirror = "auto"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = 'SilentlyContinue'

Write-Host ""
Write-Host "=== Claude Code 安装程序 ===" -ForegroundColor Cyan
Write-Host "by itgoyo | https://github.com/itgoyo/claude-code-install" -ForegroundColor DarkGray
Write-Host ""

# 测试 URL 是否可达
function Test-Url {
    param([string]$Url, [int]$TimeoutSec = 5)
    try {
        $req = [System.Net.HttpWebRequest]::Create($Url)
        $req.Timeout = $TimeoutSec * 1000
        $req.Method = "HEAD"
        $resp = $req.GetResponse()
        $resp.Close()
        return $true
    } catch { return $false }
}

# 检测网络环境
Write-Host "正在检测网络环境..." -ForegroundColor Cyan

if (Test-Url "https://registry.npmjs.org" -TimeoutSec 5) {
    $NPM_REGISTRY = "https://registry.npmjs.org"
    Write-Host "✓ npm: 官方源可用" -ForegroundColor Green
} else {
    $NPM_REGISTRY = "https://registry.npmmirror.com"
    Write-Host "✓ npm: 切换淘宝镜像 (npmmirror.com)" -ForegroundColor Yellow
}

Write-Host ""

# 检查 Node.js
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "✗ 未检测到 Node.js" -ForegroundColor Red
    Write-Host ""
    Write-Host "请先安装 Node.js: https://nodejs.org" -ForegroundColor Yellow
    Write-Host "安装后重新运行此脚本。"
    exit 1
}

$nodeVersion = (node --version)
Write-Host "✓ Node.js $nodeVersion" -ForegroundColor Green

# 安装 Claude Code（主源 + 自动 fallback）
Write-Host "正在安装 Claude Code..." -ForegroundColor Cyan
Write-Host "npm registry: $NPM_REGISTRY" -ForegroundColor DarkGray
Write-Host ""

$installed = $false

try {
    & npm install -g @anthropic-ai/claude-code --registry $NPM_REGISTRY
    if ($LASTEXITCODE -eq 0) { $installed = $true }
} catch { }

# 主源失败则切换备用
if (-not $installed) {
    if ($NPM_REGISTRY -eq "https://registry.npmjs.org") {
        Write-Host "官方源失败，切换淘宝镜像重试..." -ForegroundColor Yellow
        try {
            & npm install -g @anthropic-ai/claude-code --registry "https://registry.npmmirror.com"
            if ($LASTEXITCODE -eq 0) { $installed = $true }
        } catch { }
    }
}

if (-not $installed) {
    Write-Host "安装失败，请检查网络后重试。" -ForegroundColor Red
    exit 1
}

# 验证安装
if (Get-Command claude -ErrorAction SilentlyContinue) {
    $claudeVersion = try { claude --version 2>$null } catch { "已安装" }
    Write-Host ""
    Write-Host "✓ Claude Code 安装成功！版本: $claudeVersion" -ForegroundColor Green
    Write-Host ""
    Write-Host "运行 'claude' 开始使用。" -ForegroundColor Cyan
} else {
    Write-Host "⚠ 已安装，但 'claude' 命令未找到，请重启终端后重试。" -ForegroundColor Yellow
}
