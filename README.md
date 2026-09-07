# My-ArchVim (Neovim 0.12+ & WSL2 Ready)

本项目基于 [小彭老师 (Parallel101)](https://github.com/archibate) 开源的 **ArchVim** 进行针对性兼容修补与维护。

适配了 **Neovim 0.12+** 的 Treesitter AST 变更，修复了多处运行时代差崩溃，并原生增强了 WSL2 体验。

## 🚀 极速安装

在 Arch Linux / WSL2 终端中直接运行：

```bash
curl -sLf [https://raw.githubusercontent.com/abinng/my-archnvim/main/install.sh](https://raw.githubusercontent.com/abinng/my-archnvim/main/install.sh) | bash
```

## 🛠️ 主要修复与特性

Neovim 0.12 Treesitter 适配：修复 move.lua、swap.lua、shared.lua 的 AST 节点解包与边界空值崩溃问题。

WSL2 深度优化：集成 win32yank 原生系统剪贴板，使用 cmd.exe /c start 修复 gx 浏览器报错。

Markdown 预览：绑定 ,bp 唤醒浏览器实时渲染，绑定 ,gp 启用终端内 glow 分屏预览。

快捷键提示：预置 which-key.nvim 浮窗指引。

## 📄 许可声明

基于 ArchVim 原始项目构建，遵循 Mozilla Public License Version 2.0 (MPL-2.0)。
