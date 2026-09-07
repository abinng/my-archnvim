#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || true)"

echo "==> [1/5] 预装系统基础依赖 (which, unzip, glow, wget, win32yank)..."
sudo pacman -S --needed --noconfirm which neovim unzip glow wget 2>/dev/null || true

if ! command -v win32yank.exe &> /dev/null && ! command -v win32yank &> /dev/null; then
    curl -sLo /tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/download/v0.1.1/win32yank-x64.zip
    sudo unzip -o /tmp/win32yank.zip -d /usr/local/bin win32yank.exe
    sudo chmod +x /usr/local/bin/win32yank.exe
    sudo ln -sf /usr/local/bin/win32yank.exe /usr/local/bin/win32yank
    rm -f /tmp/win32yank.zip
fi

echo "==> [2/5] 执行官方底座安装（请按终端提示选择配置）..."
chmod +x "$SCRIPT_DIR/nvimrc-install.sh"
bash "$SCRIPT_DIR/nvimrc-install.sh"

echo "==> [3/5] 纯文件覆盖：注入原系统稳定补丁与配置..."
PACKER_START="$HOME/.local/share/nvim/site/pack/packer/start"

# 1. 覆盖 Treesitter Textobjects 移动/换位文件
TS_DIR="$PACKER_START/nvim-treesitter-textobjects/lua/nvim-treesitter/textobjects"
if [ -d "$TS_DIR" ]; then
    cp "$SCRIPT_DIR/patches/move.lua" "$TS_DIR/move.lua"
    cp "$SCRIPT_DIR/patches/swap.lua" "$TS_DIR/swap.lua"
    cp "$SCRIPT_DIR/patches/shared.lua" "$TS_DIR/shared.lua"
fi

# 2. 覆盖 ts_context_commentstring 文件
COMMENT_DIR="$PACKER_START/nvim-ts-context-commentstring/lua/ts_context_commentstring"
[ -d "$COMMENT_DIR" ] && cp "$SCRIPT_DIR/patches/ts_context_commentstring_utils.lua" "$COMMENT_DIR/utils.lua"

# 3. 覆盖 aerial 文件
AERIAL_DIR="$PACKER_START/aerial.nvim/lua/aerial/backends/treesitter"
[ -d "$AERIAL_DIR" ] && cp "$SCRIPT_DIR/patches/aerial_extensions.lua" "$AERIAL_DIR/extensions.lua"

# 4. 覆盖 4 个核心配置文件
cp "$SCRIPT_DIR/config/options.lua" "$HOME/.config/nvim/lua/archvim/options.lua"
cp "$SCRIPT_DIR/config/mappings.lua" "$HOME/.config/nvim/lua/archvim/mappings.lua"
cp "$SCRIPT_DIR/config/treesitter.lua" "$HOME/.config/nvim/lua/archvim/config/treesitter.lua"
cp "$SCRIPT_DIR/config/lspconfig.lua" "$HOME/.config/nvim/lua/archvim/config/lspconfig.lua"

echo "==> [4/5] 链接并编译扩展插件 (which-key, markdown-preview)..."
PREDOWNLOAD="$HOME/.config/nvim/lua/archvim/predownload"
mkdir -p "$PACKER_START"

[ -d "$PREDOWNLOAD/folke/which-key.nvim" ] && ln -sf "$PREDOWNLOAD/folke/which-key.nvim" "$PACKER_START/"

if [ -d "$PREDOWNLOAD/iamcco/markdown-preview.nvim" ]; then
    ln -sf "$PREDOWNLOAD/iamcco/markdown-preview.nvim" "$PACKER_START/"
    (
        cd "$PACKER_START/markdown-preview.nvim/app"
        bash install.sh || npm install
    )
    MDP_BIN="$PACKER_START/markdown-preview.nvim/app/bin/markdown-preview-linux"
    [ -f "$MDP_BIN" ] && chmod +x "$MDP_BIN"
fi

echo "==> [5/5] 安装 neocmakelsp 并重载 Packer 编译状态..."
nvim --headless \
    -c "MasonInstall neocmakelsp" \
    -c "sleep 2" \
    -c "PackerCompile" \
    -c "sleep 1" \
    -c "qa" >/dev/null 2>&1 || true

echo "=========================================================="
echo "  原系统镜像补丁部署完成，输入 nvim 即可正常进入工作！"
echo "=========================================================="
