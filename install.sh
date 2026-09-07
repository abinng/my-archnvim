#!/usr/bin/env bash
set -e

GITHUB_USER="abinng"
REPO_NAME="my-archnvim"
TAG="v1.0.0"

echo "==> [1/4] 安装系统级依赖..."
sudo pacman -S --needed --noconfirm git curl tar gzip unzip glow nodejs npm 2>/dev/null || true

if ! command -v win32yank.exe &> /dev/null && ! command -v win32yank &> /dev/null; then
    echo "==> 安装 win32yank 剪贴板支持..."
    curl -sLo /tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/download/v0.1.1/win32yank-x64.zip
    sudo unzip -o /tmp/win32yank.zip -d /usr/local/bin win32yank.exe
    sudo chmod +x /usr/local/bin/win32yank.exe
    sudo ln -sf /usr/local/bin/win32yank.exe /usr/local/bin/win32yank
    rm -f /tmp/win32yank.zip
fi

echo "==> [2/4] 备份已有 Neovim 配置..."
[ -d "$HOME/.config/nvim" ] && mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$(date +%s)"

echo "==> [3/4] 下载预构建包并解压..."
DOWNLOAD_URL="https://github.com/${GITHUB_USER}/${REPO_NAME}/releases/download/${TAG}/archvim-bundle.tar.gz"
curl -L --progress-bar "$DOWNLOAD_URL" | tar -xz -C "$HOME"

echo "==> [4/4] 对齐软链接与执行权限..."
PACKER_START="$HOME/.local/share/nvim/site/pack/packer/start"
PREDOWNLOAD="$HOME/.config/nvim/lua/archvim/predownload"

mkdir -p "$PACKER_START"
[ -d "$PREDOWNLOAD/folke/which-key.nvim" ] && ln -sf "$PREDOWNLOAD/folke/which-key.nvim" "$PACKER_START/"
[ -d "$PREDOWNLOAD/iamcco/markdown-preview.nvim" ] && ln -sf "$PREDOWNLOAD/iamcco/markdown-preview.nvim" "$PACKER_START/"

MDP_BIN="$PACKER_START/markdown-preview.nvim/app/bin/markdown-preview-linux"
[ -f "$MDP_BIN" ] && chmod +x "$MDP_BIN"

echo "==> 部署完成！打开 nvim 即可使用。"
