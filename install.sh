#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || true)"

safe_copy() {
    local src="$1"
    local dest="$2"
    if [ -f "$src" ]; then
        mkdir -p "$(dirname "$dest")"
        cp -f "$src" "$dest"
    fi
}

echo "==> [1/6] 安装全量系统级依赖与编译工具链..."
sudo pacman -S --needed --noconfirm \
    neovim git curl tar base-devel ripgrep \
    clang cmake ninja tree-sitter-cli lsof \
    unzip glow which python python-pynvim wget \
    2>/dev/null || true

echo "==> [2/6] 部署 WSL2 剪贴板工具 (win32yank)..."
if ! command -v win32yank.exe &> /dev/null && ! command -v win32yank &> /dev/null; then
    curl -sLo /tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/download/v0.1.1/win32yank-x64.zip
    sudo unzip -o /tmp/win32yank.zip -d /usr/local/bin win32yank.exe
    sudo chmod +x /usr/local/bin/win32yank.exe
    sudo ln -sf /usr/local/bin/win32yank.exe /usr/local/bin/win32yank
    rm -f /tmp/win32yank.zip
fi

echo "==> [3/6] 执行官方底座安装（终端交互选择偏好配置）..."
chmod +x "$SCRIPT_DIR/nvimrc-install.sh"
bash "$SCRIPT_DIR/nvimrc-install.sh"

echo "==> [4/6] 现场拉取更新 4 个存在 API 代差的插件..."
PACKER_START="$HOME/.local/share/nvim/site/pack/packer/start"
mkdir -p "$PACKER_START"

rm -rf "$PACKER_START/aerial.nvim"
git clone --depth 1 https://github.com/stevearc/aerial.nvim "$PACKER_START/aerial.nvim"

rm -rf "$PACKER_START/trouble.nvim"
git clone --depth 1 https://github.com/folke/trouble.nvim "$PACKER_START/trouble.nvim"

rm -rf "$PACKER_START/vim-matchup"
git clone --depth 1 https://github.com/andymass/vim-matchup "$PACKER_START/vim-matchup"

rm -rf "$PACKER_START/nvim-treesitter-textobjects"
git clone --depth 1 https://github.com/nvim-treesitter/nvim-treesitter-textobjects "$PACKER_START/nvim-treesitter-textobjects"

echo "==> [5/6] 检查路径并覆盖修改过的补丁文件与配置单文件..."
safe_copy "$SCRIPT_DIR/patches/move.lua" "$PACKER_START/nvim-treesitter-textobjects/lua/nvim-treesitter/textobjects/move.lua"
safe_copy "$SCRIPT_DIR/patches/swap.lua" "$PACKER_START/nvim-treesitter-textobjects/lua/nvim-treesitter/textobjects/swap.lua"
safe_copy "$SCRIPT_DIR/patches/shared.lua" "$PACKER_START/nvim-treesitter-textobjects/lua/nvim-treesitter/textobjects/shared.lua"
safe_copy "$SCRIPT_DIR/patches/tsrange.lua" "$PACKER_START/nvim-treesitter/lua/nvim-treesitter/tsrange.lua"

CONFIG_DIR="$HOME/.config/nvim"
safe_copy "$SCRIPT_DIR/config/init.vim" "$CONFIG_DIR/init.vim"
safe_copy "$SCRIPT_DIR/config/options.lua" "$CONFIG_DIR/lua/archvim/options.lua"
safe_copy "$SCRIPT_DIR/config/mappings.lua" "$CONFIG_DIR/lua/archvim/mappings.lua"
safe_copy "$SCRIPT_DIR/config/treesitter.lua" "$CONFIG_DIR/lua/archvim/config/treesitter.lua"
safe_copy "$SCRIPT_DIR/config/mason.lua" "$CONFIG_DIR/lua/archvim/config/mason.lua"
safe_copy "$SCRIPT_DIR/config/lualine.lua" "$CONFIG_DIR/lua/archvim/config/lualine.lua"
safe_copy "$SCRIPT_DIR/config/lspconfig.lua" "$CONFIG_DIR/lua/archvim/config/lspconfig.lua"

safe_copy "$SCRIPT_DIR/config/trouble.lua" "$CONFIG_DIR/lua/archvim/config/trouble.lua"
safe_copy "$SCRIPT_DIR/config/keymaps.lua" "$CONFIG_DIR/lua/archvim/config/keymaps.lua"
safe_copy "$SCRIPT_DIR/config/clangd_config.yaml" "$HOME/.config/clangd/config.yaml"
safe_copy "$SCRIPT_DIR/config/clang-format" "$HOME/.clang-format"

echo "==> [6/6] 激活 which-key 与 markdown-preview 服务..."
PREDOWNLOAD="$CONFIG_DIR/lua/archvim/predownload"

if [ -d "$PREDOWNLOAD/folke/which-key.nvim" ]; then
    ln -sf "$PREDOWNLOAD/folke/which-key.nvim" "$PACKER_START/"
fi

if [ -d "$PREDOWNLOAD/iamcco/markdown-preview.nvim" ]; then
    ln -sf "$PREDOWNLOAD/iamcco/markdown-preview.nvim" "$PACKER_START/"
    (
        cd "$PACKER_START/markdown-preview.nvim/app"
        bash install.sh || npm install
    )
    MDP_BIN="$PACKER_START/markdown-preview.nvim/app/bin/markdown-preview-linux"
    [ -f "$MDP_BIN" ] && chmod +x "$MDP_BIN"
fi

nvim --headless -c "PackerCompile" -c "sleep 1" -c "qa" >/dev/null 2>&1 || true

# ----------------- 附加功能：可选安装 Tmux 配置 -----------------
echo ""
read -p "==> 是否顺便安装小彭老师的 Tmux 配置？(y/N): " install_tmux
if [[ "$install_tmux" =~ ^[Yy]$ ]]; then
    echo "==> 正在安装 Tmux 依赖 (tmux, fzf, xsel)..."
    sudo pacman -S --needed --noconfirm tmux fzf xsel tree python 2>/dev/null || true
    
    echo "==> 正在克隆并初始化 Tmux 配置..."
    rm -rf "$HOME/.config/tmux"
    git clone https://github.com/archibate/tmux-conf "$HOME/.config/tmux" --depth=1
    bash "$HOME/.config/tmux/scripts/tmux_install.sh"
    echo "==> Tmux 配置安装完成！"
fi

echo "=========================================================="
echo "  安装更新与安全覆盖全部完成，Neovim 环境纯净无报错！"
echo "=========================================================="
