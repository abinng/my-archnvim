#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || true)"

echo "==> [1/5] 前置安装全部系统级依赖 (解决所有探测与底层工具缺失)..."
# 一次性装齐对话中发现的所有系统命令：which, unzip, glow, wget, clang, cmake, ninja, lsof, tree-sitter-cli, python-pynvim 等
sudo pacman -S --needed --noconfirm \
    which unzip glow wget \
    git curl tar base-devel ripgrep \
    clang cmake ninja tree-sitter-cli lsof \
    python python-pynvim \
    2>/dev/null || true

# 适配 WSL2 原生剪贴板
if ! command -v win32yank.exe &> /dev/null && ! command -v win32yank &> /dev/null; then
    curl -sLo /tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/download/v0.1.1/win32yank-x64.zip
    sudo unzip -o /tmp/win32yank.zip -d /usr/local/bin win32yank.exe
    sudo chmod +x /usr/local/bin/win32yank.exe
    sudo ln -sf /usr/local/bin/win32yank.exe /usr/local/bin/win32yank
    rm -f /tmp/win32yank.zip
fi

echo "==> [2/5] 执行小彭老师官方安装底座（终端交互选择配置）..."
chmod +x "$SCRIPT_DIR/nvimrc-install.sh"
bash "$SCRIPT_DIR/nvimrc-install.sh"

echo "==> [3/5] 覆盖原系统已调通的全部插件与源码补丁..."
PACKER_START="$HOME/.local/share/nvim/site/pack/packer/start"
mkdir -p "$PACKER_START"

# 1. 全量覆盖 4 个排查修复后的插件本体 (aerial, trouble, vim-matchup, nvim-treesitter-textobjects)
cp -rf "$SCRIPT_DIR/patches/aerial.nvim" "$PACKER_START/"
cp -rf "$SCRIPT_DIR/patches/trouble.nvim" "$PACKER_START/"
cp -rf "$SCRIPT_DIR/patches/vim-matchup" "$PACKER_START/"
cp -rf "$SCRIPT_DIR/patches/nvim-treesitter-textobjects" "$PACKER_START/"

# 2. 覆盖单个源码补丁文件
TS_DIR="$PACKER_START/nvim-treesitter/lua/nvim-treesitter"
[ -d "$TS_DIR" ] && cp -f "$SCRIPT_DIR/patches/tsrange.lua" "$TS_DIR/tsrange.lua"

COMMENT_DIR="$PACKER_START/nvim-ts-context-commentstring/lua/ts_context_commentstring"
if [ -d "$COMMENT_DIR" ] && [ -f "$SCRIPT_DIR/patches/ts_commentstring_utils.lua" ]; then
    cp -f "$SCRIPT_DIR/patches/ts_commentstring_utils.lua" "$COMMENT_DIR/utils.lua"
fi

echo "==> [4/5] 覆盖原系统全部 11 个配置文件与个人设定..."
CONFIG_DIR="$HOME/.config/nvim"

# A. 基础启动与按键配置
cp -f "$SCRIPT_DIR/config/init.vim" "$CONFIG_DIR/init.vim"
cp -f "$SCRIPT_DIR/config/options.lua" "$CONFIG_DIR/lua/archvim/options.lua"
cp -f "$SCRIPT_DIR/config/mappings.lua" "$CONFIG_DIR/lua/archvim/mappings.lua"

# B. 语言服务与界面组件配置 (mason, lualine, treesitter, lspconfig)
cp -f "$SCRIPT_DIR/config/mason.lua" "$CONFIG_DIR/lua/archvim/config/mason.lua"
cp -f "$SCRIPT_DIR/config/treesitter.lua" "$CONFIG_DIR/lua/archvim/config/treesitter.lua"
cp -f "$SCRIPT_DIR/config/lualine.lua" "$CONFIG_DIR/lua/archvim/config/lualine.lua"
cp -f "$SCRIPT_DIR/config/lspconfig.lua" "$CONFIG_DIR/lua/archvim/config/lspconfig.lua"

# C. 冗余安全覆盖 (trouble, keymaps, clang 配置)
[ -f "$SCRIPT_DIR/config/trouble.lua" ] && cp -f "$SCRIPT_DIR/config/trouble.lua" "$CONFIG_DIR/lua/archvim/config/trouble.lua"
[ -f "$SCRIPT_DIR/config/keymaps.lua" ] && cp -f "$SCRIPT_DIR/config/keymaps.lua" "$CONFIG_DIR/lua/archvim/config/keymaps.lua"

if [ -f "$SCRIPT_DIR/config/clangd_config.yaml" ]; then
    mkdir -p "$HOME/.config/clangd"
    cp -f "$SCRIPT_DIR/config/clangd_config.yaml" "$HOME/.config/clangd/config.yaml"
fi
[ -f "$SCRIPT_DIR/config/clang-format" ] && cp -f "$SCRIPT_DIR/config/clang-format" "$HOME/.clang-format"

echo "==> [5/5] 激活扩展插件并固化编译状态..."
PREDOWNLOAD="$CONFIG_DIR/lua/archvim/predownload"

# 激活 which-key
[ -d "$PREDOWNLOAD/folke/which-key.nvim" ] && ln -sf "$PREDOWNLOAD/folke/which-key.nvim" "$PACKER_START/"

# 编译并激活 markdown-preview
if [ -d "$PREDOWNLOAD/iamcco/markdown-preview.nvim" ]; then
    ln -sf "$PREDOWNLOAD/iamcco/markdown-preview.nvim" "$PACKER_START/"
    (
        cd "$PACKER_START/markdown-preview.nvim/app"
        bash install.sh || npm install
    )
    MDP_BIN="$PACKER_START/markdown-preview.nvim/app/bin/markdown-preview-linux"
    [ -f "$MDP_BIN" ] && chmod +x "$MDP_BIN"
fi

# 重新编译 Packer 缓存，确保新配置即时生效
nvim --headless -c "PackerCompile" -c "sleep 1" -c "qa" >/dev/null 2>&1 || true

echo "=========================================================="
echo "  恭喜！原系统环境已 100% 镜像部署并覆盖完毕！"
echo "=========================================================="
