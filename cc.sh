#!/bin/bash
set -e

echo ""
echo "  itgoyo - Claude Code Installer"
echo "  https://github.com/itgoyo"
echo ""

# Check Node.js
if ! command -v node &>/dev/null; then
    echo "[!] Node.js not found. Please install Node.js 18+ from https://nodejs.org"
    exit 1
fi
echo "[1/3] Node.js detected: $(node --version)"

# Check npm
if ! command -v npm &>/dev/null; then
    echo "[!] npm not found."
    exit 1
fi
echo "[2/3] npm detected: v$(npm --version)"

# Install Claude Code
echo "[3/3] Installing Claude Code..."
npm install -g @anthropic-ai/claude-code

echo ""
echo "  Claude Code installed successfully!"
echo "  Run: claude"
echo ""
