param(
    [Parameter(Position=0)]
    [string]$Target = "latest"
)

Write-Host ""
Write-Host "  itgoyo - Claude Code Installer" -ForegroundColor Cyan
Write-Host "  https://github.com/itgoyo" -ForegroundColor DarkGray
Write-Host ""

# Check for 32-bit Windows
if (-not [Environment]::Is64BitProcess) {
    Write-Error "Claude Code does not support 32-bit Windows. Please use a 64-bit version of Windows."
    exit 1
}

# Check Node.js
try {
    $nodeVersion = & node --version 2>$null
    if (-not $nodeVersion) { throw "not found" }
    Write-Host "[1/3] Node.js detected: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "[!] Node.js not found. Please install Node.js 18+ from https://nodejs.org" -ForegroundColor Red
    exit 1
}

# Check npm
try {
    $npmVersion = & npm --version 2>$null
    Write-Host "[2/3] npm detected: v$npmVersion" -ForegroundColor Green
} catch {
    Write-Host "[!] npm not found. Please install Node.js from https://nodejs.org" -ForegroundColor Red
    exit 1
}

# Install Claude Code
Write-Host "[3/3] Installing Claude Code..." -ForegroundColor Yellow
try {
    & npm install -g @anthropic-ai/claude-code
    if ($LASTEXITCODE -ne 0) { throw "npm install failed" }
} catch {
    Write-Host "[!] Installation failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "  Claude Code installed successfully!" -ForegroundColor Green
Write-Host "  Run: claude" -ForegroundColor Cyan
Write-Host ""
