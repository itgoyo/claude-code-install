#!/bin/bash
# Claude Code 一键安装脚本 (macOS / Linux)
# 用法:
#   国际直连: curl -fsSL https://raw.githubusercontent.com/itgoyo/claude-code-install/main/cc.sh | bash
#   国内加速: curl -fsSL https://mirror.ghproxy.com/https://raw.githubusercontent.com/itgoyo/claude-code-install/main/cc.sh | bash

set -e

MIRROR="${1:-auto}"  # auto, cn, global

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

echo ""
echo -e "${CYAN}=== Claude Code 安装程序 ===${NC}"
echo -e "${GRAY}by itgoyo | https://github.com/itgoyo/claude-code-install${NC}"
echo ""

# 自动检测网络环境
if [ "$MIRROR" = "auto" ]; then
    echo -e "${CYAN}正在检测网络环境...${NC}"
    if curl -fsSL --connect-timeout 4 https://registry.npmjs.org > /dev/null 2>&1; then
        MIRROR="global"
        echo -e "${GREEN}✓ 使用国际源${NC}"
    else
        MIRROR="cn"
        echo -e "${YELLOW}✓ 切换国内加速源${NC}"
    fi
fi

# 选择 npm registry
if [ "$MIRROR" = "cn" ]; then
    NPM_REGISTRY="https://registry.npmmirror.com"
    echo -e "${YELLOW}npm 镜像: 淘宝源 (npmmirror.com)${NC}"
else
    NPM_REGISTRY="https://registry.npmjs.org"
    echo -e "${GREEN}npm 镜像: 官方源 (npmjs.org)${NC}"
fi

echo ""

# 检查 Node.js
if ! command -v node &>/dev/null; then
    echo -e "${RED}✗ 未检测到 Node.js${NC}"
    echo ""
    echo "请先安装 Node.js:"
    if [ "$(uname)" = "Darwin" ]; then
        echo "  brew install node"
        echo "  或访问: https://nodejs.org"
    else
        echo "  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -"
        echo "  sudo apt-get install -y nodejs"
    fi
    exit 1
fi

NODE_VERSION=$(node --version)
echo -e "${GREEN}✓ Node.js ${NODE_VERSION}${NC}"

# 安装 Claude Code
echo -e "${CYAN}正在安装 Claude Code...${NC}"

npm install -g @anthropic-ai/claude-code --registry "$NPM_REGISTRY"

# 验证安装
if command -v claude &>/dev/null; then
    CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "未知")
    echo ""
    echo -e "${GREEN}✓ Claude Code 安装成功！版本: ${CLAUDE_VERSION}${NC}"
    echo ""
    echo -e "${CYAN}运行 'claude' 开始使用。${NC}"
else
    echo -e "${YELLOW}⚠ Claude Code 已安装，但 'claude' 命令未找到，请重启终端后重试。${NC}"
fi
