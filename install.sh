#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || true)"

echo "==> [1/5] 预装基础系统工具 (which, unzip, glow, wget, win32yank)..."
sudo pacman -S --needed --noconfirm which unzip glow wget 2>/dev/null || true

if ! command -v win32yank.exe &> /dev/null && ! command -v win32yank &> /dev/null; then
    curl -sLo /tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/download/v0.1.1/win32yank-x64.zip
    sudo unzip -o /tmp/win32yank.zip -d /usr/local/bin win32yank.exe
    sudo chmod +x /usr/local/bin/win32yank.exe
    sudo ln -sf /usr/local/bin/win32yank.exe /usr/local/bin/win32yank
    rm -f /tmp/win32yank.zip
fi

echo "==> [2/5] 执行官方安装底座（终端交互选择偏好配置）..."
chmod +x "$SCRIPT_DIR/nvimrc-install.sh"
bash "$SCRIPT_DIR/nvimrc-install.sh"

echo "==> [3/5] 使用原系统的稳定文件全量覆盖..."
PACKER_START="$HOME/.local/share/nvim/site/pack/packer/start"

# A. 覆盖 5 个插件底层文件
TS_OBJ="$PACKER_START/nvim-treesitter-textobjects/lua/nvim-treesitter/textobjects"
if [ -d "$TS_OBJ" ]; then
    cp "$SCRIPT_DIR/patches/move.lua" "$TS_OBJ/"
    cp "$SCRIPT_DIR/patches/swap.lua" "$TS_OBJ/"
    cp "$SCRIPT_DIR/patches/shared.lua" "$TS_OBJ/"
fi

COMMENT_DIR="$PACKER_START/nvim-ts-context-commentstring/lua/ts_context_commentstring"
[ -d "$COMMENT_DIR" ] && cp "$SCRIPT_DIR/patches/ts_commentstring_utils.lua" "$COMMENT_DIR/utils.lua"

AERIAL_DIR="$PACKER_START/aerial.nvim/lua/aerial/backends/treesitter"
[ -d "$AERIAL_DIR" ] && cp "$SCRIPT_DIR/patches/aerial_extensions.lua" "$AERIAL_DIR/extensions.lua"

# B. 覆盖 4 个核心配置文件
cp "$SCRIPT_DIR/config/options.lua" "$HOME/.config/nvim/lua/archvim/options.lua"
cp "$SCRIPT_DIR/config/mappings.lua" "$HOME/.config/nvim/lua/archvim/mappings.lua"
cp "$SCRIPT_DIR/config/treesitter.lua" "$HOME/.config/nvim/lua/archvim/config/treesitter.lua"
cp "$SCRIPT_DIR/config/lspconfig.lua" "$HOME/.config/nvim/lua/archvim/config/lspconfig.lua"

echo "==> [4/5] 挂载并激活扩展插件 (which-key, markdown-preview)..."
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

echo "==> [5/5] 静默安装 neocmakelsp 并重载编译缓存..."
nvim --headless \
    -c "MasonInstall neocmakelsp" \
    -c "sleep 2" \
    -c "PackerCompile" \
    -c "sleep 1" \
    -c "qa" >/dev/null 2>&1 || true

echo "=========================================================="
echo "  恭喜！原系统文件已完整克隆并覆盖部署，开箱即用！"
echo "=========================================================="
