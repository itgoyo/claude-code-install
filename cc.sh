#!/bin/bash
# Claude Code 一键安装脚本 (macOS / Linux)
# 用法:
#   curl -fsSL https://raw.githubusercontent.com/itgoyo/claude-code-install/main/cc.sh | bash

set -e

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

# 国内 GitHub 加速代理列表（按优先级）
GH_PROXIES=(
    "https://ghproxy.net"
    "https://ghfast.top"
    "https://gh.con.sh"
)

RAW_URL="https://raw.githubusercontent.com/itgoyo/claude-code-install/main/cc.sh"

# 检测能否直连 GitHub
can_reach_github() {
    curl -fsSL --connect-timeout 4 --max-time 6 "https://raw.githubusercontent.com" > /dev/null 2>&1
}

# 检测能否直连 npmjs 官方源
can_reach_npm() {
    curl -fsSL --connect-timeout 4 --max-time 6 "https://registry.npmjs.org" > /dev/null 2>&1
}

# 测试代理可用性
test_proxy() {
    local proxy="$1"
    curl -fsSL --connect-timeout 5 --max-time 8 "${proxy}/https://raw.githubusercontent.com/itgoyo/claude-code-install/main/cc.sh" > /dev/null 2>&1
}

echo -e "${CYAN}正在检测网络环境...${NC}"

if can_reach_npm; then
    NPM_REGISTRY="https://registry.npmjs.org"
    echo -e "${GREEN}✓ npm: 官方源可用${NC}"
else
    NPM_REGISTRY="https://registry.npmmirror.com"
    echo -e "${YELLOW}✓ npm: 切换淘宝镜像 (npmmirror.com)${NC}"
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
echo -e "${GRAY}npm registry: ${NPM_REGISTRY}${NC}"
echo ""

if npm install -g @anthropic-ai/claude-code --registry "$NPM_REGISTRY"; then
    :
else
    # 主源失败，切换备用
    if [ "$NPM_REGISTRY" = "https://registry.npmjs.org" ]; then
        echo -e "${YELLOW}官方源失败，切换淘宝镜像重试...${NC}"
        npm install -g @anthropic-ai/claude-code --registry "https://registry.npmmirror.com"
    else
        echo -e "${RED}安装失败，请检查网络后重试。${NC}"
        exit 1
    fi
fi

# 验证安装
if command -v claude &>/dev/null; then
    CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "已安装")
    echo ""
    echo -e "${GREEN}✓ Claude Code 安装成功！版本: ${CLAUDE_VERSION}${NC}"
    echo ""
    echo -e "${CYAN}运行 'claude' 开始使用。${NC}"
else
    echo -e "${YELLOW}⚠ 已安装，但 'claude' 命令未找到，请重启终端后重试。${NC}"
fi
