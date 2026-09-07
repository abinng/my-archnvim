#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || true)"

echo "==> [1/4] 预装前置基础依赖 (which, unzip, glow, win32yank)..."
# 必须最优先装好 which 与 unzip，否则底座脚本的环境探测和剪贴板解压会直接报错
sudo pacman -S --needed --noconfirm which unzip nvim glow 2>/dev/null || true

# 适配 WSL2 原生剪贴板
if ! command -v win32yank.exe &> /dev/null && ! command -v win32yank &> /dev/null; then
    curl -sLo /tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/download/v0.1.1/win32yank-x64.zip
    sudo unzip -o /tmp/win32yank.zip -d /usr/local/bin win32yank.exe
    sudo chmod +x /usr/local/bin/win32yank.exe
    sudo ln -sf /usr/local/bin/win32yank.exe /usr/local/bin/win32yank
    rm -f /tmp/win32yank.zip
fi

echo "==> [2/4] 执行官方安装底座（请根据终端提示选择个性化配置）..."
chmod +x "$SCRIPT_DIR/nvimrc-install.sh"
bash "$SCRIPT_DIR/nvimrc-install.sh"

echo "==> [3/4] 注入 Neovim 0.12 兼容补丁..."
# A. 覆盖 Treesitter 源码补丁 (move, swap, shared)
TS_TARGET="$HOME/.local/share/nvim/site/pack/packer/start/nvim-treesitter-textobjects/lua/nvim-treesitter/textobjects"
if [ -d "$TS_TARGET" ]; then
    cp "$SCRIPT_DIR/patches/move.lua" "$TS_TARGET/"
    cp "$SCRIPT_DIR/patches/swap.lua" "$TS_TARGET/"
    cp "$SCRIPT_DIR/patches/shared.lua" "$TS_TARGET/"
fi

# B. 覆盖核心配置文件 (options, mappings, treesitter)
cp "$SCRIPT_DIR/config/options.lua" "$HOME/.config/nvim/lua/archvim/options.lua"
cp "$SCRIPT_DIR/config/mappings.lua" "$HOME/.config/nvim/lua/archvim/mappings.lua"
cp "$SCRIPT_DIR/config/treesitter.lua" "$HOME/.config/nvim/lua/archvim/config/treesitter.lua"

echo "==> [4/4] 挂载并激活扩展插件 (which-key, markdown-preview)..."
PACKER_START="$HOME/.local/share/nvim/site/pack/packer/start"
PREDOWNLOAD="$HOME/.config/nvim/lua/archvim/predownload"

mkdir -p "$PACKER_START"
[ -d "$PREDOWNLOAD/folke/which-key.nvim" ] && ln -sf "$PREDOWNLOAD/folke/which-key.nvim" "$PACKER_START/"

if [ -d "$PREDOWNLOAD/iamcco/markdown-preview.nvim" ]; then
    ln -sf "$PREDOWNLOAD/iamcco/markdown-preview.nvim" "$PACKER_START/"
    cd "$PACKER_START/markdown-preview.nvim/app"
    bash install.sh || npm install
fi

echo "=========================================================="
echo "  恭喜！官方底座已就绪，所有 0.12 补丁与扩展功能安装完毕！"
echo "=========================================================="
