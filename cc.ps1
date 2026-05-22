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

$npmRegistries = @(
    @{ Key = "official"; Name = "npm 官方源"; Url = "https://registry.npmjs.org" },
    @{ Key = "npmmirror"; Name = "淘宝 npmmirror"; Url = "https://registry.npmmirror.com" },
    @{ Key = "huawei"; Name = "华为云 npm"; Url = "https://repo.huaweicloud.com/repository/npm/" },
    @{ Key = "tencent"; Name = "腾讯云 npm"; Url = "https://mirrors.cloud.tencent.com/npm/" }
)

function Get-NpmRegistryCandidates {
    param([string]$MirrorName)

    $official = @($npmRegistries | Where-Object { $_["Key"] -eq "official" })
    $domestic = @($npmRegistries | Where-Object { $_["Key"] -ne "official" })

    if ($MirrorName -and $MirrorName -ne "auto") {
        $selected = @($npmRegistries | Where-Object {
            $_["Key"] -eq $MirrorName -or $_["Url"].TrimEnd("/") -eq $MirrorName.TrimEnd("/")
        })

        if ($selected.Count -eq 0 -and $MirrorName -match "^https?://") {
            $selected = @(@{ Key = "custom"; Name = "自定义镜像"; Url = $MirrorName })
        }

        if ($selected.Count -gt 0) {
            $remaining = @($npmRegistries | Where-Object { $_["Url"].TrimEnd("/") -ne $selected[0]["Url"].TrimEnd("/") })
            return @($selected[0]) + $remaining
        }

        Write-Host "⚠ 未识别镜像 '$MirrorName'，使用自动模式。" -ForegroundColor Yellow
    }

    if (Test-Url "https://registry.npmjs.org" -TimeoutSec 5) {
        Write-Host "✓ npm: 官方源可用，失败时自动切换国内镜像" -ForegroundColor Green
        return $official + $domestic
    }

    Write-Host "✓ npm: 官方源不可用，优先使用国内镜像" -ForegroundColor Yellow
    return $domestic + $official
}

$registryCandidates = Get-NpmRegistryCandidates -MirrorName $Mirror

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

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host "✗ 未检测到 npm" -ForegroundColor Red
    Write-Host "请修复 Node.js/npm 安装后重新运行此脚本。" -ForegroundColor Yellow
    exit 1
}

$npmVersion = (npm --version)
Write-Host "✓ npm $npmVersion" -ForegroundColor Green

# 安装 Claude Code（主源 + 自动 fallback）
Write-Host "正在安装 Claude Code..." -ForegroundColor Cyan
Write-Host "候选 npm registry:" -ForegroundColor DarkGray
foreach ($registry in $registryCandidates) {
    $candidateName = $registry["Name"]
    $candidateUrl = $registry["Url"]
    Write-Host "  - ${candidateName}: ${candidateUrl}" -ForegroundColor DarkGray
}
Write-Host ""

$installed = $false

foreach ($registry in $registryCandidates) {
    $registryName = $registry["Name"]
    $registryUrl = $registry["Url"]
    $installError = $null
    Write-Host "尝试使用 $registryName..." -ForegroundColor Cyan

    try {
        & npm install -g @anthropic-ai/claude-code --registry $registryUrl
        if ($LASTEXITCODE -eq 0) {
            $installed = $true
            break
        }
    } catch {
        $installError = $_.Exception.Message
    }

    if ($installError) {
        Write-Host "$registryName 安装出错: $installError" -ForegroundColor Yellow
    } else {
        Write-Host "$registryName 安装失败。" -ForegroundColor Yellow
    }
}

if (-not $installed) {
    Write-Host "所有 npm registry 都安装失败，请检查网络、Node.js/npm 配置后重试。" -ForegroundColor Red
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
