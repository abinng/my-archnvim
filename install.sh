#!/usr/bin/env bash
set -e

GITHUB_USER="abinng"
REPO_NAME="my-archnvim"
BRANCH="main"

echo "==> [1/4] 安装基础依赖 (win32yank, glow, nodejs)..."
sudo pacman -S --needed --noconfirm git curl tar xz unzip glow nodejs npm 2>/dev/null || true

# 安装 WSL 剪贴板支持
if ! command -v win32yank.exe &> /dev/null && ! command -v win32yank &> /dev/null; then
    echo "正在安装 win32yank 剪贴板工具..."
    curl -sLo /tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/download/v0.1.1/win32yank-x64.zip
    sudo unzip -o /tmp/win32yank.zip -d /usr/local/bin win32yank.exe
    sudo chmod +x /usr/local/bin/win32yank.exe
    sudo ln -sf /usr/local/bin/win32yank.exe /usr/local/bin/win32yank
    rm -f /tmp/win32yank.zip
fi

echo "==> [2/4] 备份可能存在的旧 Neovim 配置..."
[ -d "$HOME/.config/nvim" ] && mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$(date +%s)"

echo "==> [3/4] 解压已修补的完整 Neovim 0.12 环境..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || true)"

if [ -f "$SCRIPT_DIR/archvim-bundle.tar.xz" ]; then
    echo "检测到本地包，直接本地解压..."
    tar -xJf "$SCRIPT_DIR/archvim-bundle.tar.xz" -C "$HOME"
else
    echo "从 GitHub 拉取预构建包..."
    DOWNLOAD_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${REPO_NAME}/${BRANCH}/archvim-bundle.tar.xz"
    curl -L --progress-bar "$DOWNLOAD_URL" | tar -xJf - -C "$HOME"
fi

echo "==> [4/4] 对齐软链接与权限..."
PACKER_START="$HOME/.local/share/nvim/site/pack/packer/start"
PREDOWNLOAD="$HOME/.config/nvim/lua/archvim/predownload"

mkdir -p "$PACKER_START"
[ -d "$PREDOWNLOAD/folke/which-key.nvim" ] && ln -sf "$PREDOWNLOAD/folke/which-key.nvim" "$PACKER_START/"
[ -d "$PREDOWNLOAD/iamcco/markdown-preview.nvim" ] && ln -sf "$PREDOWNLOAD/iamcco/markdown-preview.nvim" "$PACKER_START/"

MDP_BIN="$PACKER_START/markdown-preview.nvim/app/bin/markdown-preview-linux"
[ -f "$MDP_BIN" ] && chmod +x "$MDP_BIN"

echo "=========================================================="
echo "  恭喜！环境恢复完毕，输入 nvim 即可直接进入无报错工作流！"
echo "=========================================================="
