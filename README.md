# my-archnvim

针对 **Arch Linux / WSL2** 环境定制的自动化 Neovim 配置部署套件。以小彭老师的 **ArchVim** 为稳定底座，全面修复针对 **Neovim 0.12+** 及 **Python 3.14** 的插件代差与崩溃问题，实现全自动依赖补全与个人配置安全覆盖。

---

## 核心特性与修复

* **Neovim 0.12 API 兼容修复**：修复 Treesitter AST 数组解包、节点边界判空，解决 `nvim-treesitter-textobjects` 移动跳转、`aerial.nvim` 大纲解析以及 `ts_context_commentstring` 在目录树下的空指针崩溃问题。
* **Arch Linux Python 3.14 适配**：规避 PyPI 旧版构建死循环报错，剔除已废弃/冲突的 LSP 服务，确保包管理检测无痛通过。
* **WSL2 宿主机原生交互**：
  * 集成 `win32yank.exe` 剪贴板自动部署，打通宿主机与虚拟机剪贴板双向同步。
  * 修复 `gx` 打开超链接报 `explorer.exe` 异常退出。
  * 解决 Markdown 浏览器实时预览唤起失效问题。
* **可选 Tmux 终端环境集成**：脚本最后支持一键部署小彭老师优化的 Tmux 配置，提供 Vi 风格窗格导航、fzf 模糊会话选择器及 Gruvbox 状态栏[cite: 6]。
* **轻量化补丁架构**：仓库仅保存关键补丁单文件与个性化配置，安装时按需现场更新上游稳定插件并执行安全覆盖（`safe_copy`），告别臃肿子模块。

---

## 一键安装部署

在全新安装的 Arch Linux / WSL2 终端中直接运行：

```bash
git clone --depth=1 [https://github.com/abinng/my-archnvim.git](https://github.com/abinng/my-archnvim.git)
cd my-archnvim
sh install.sh
```

*(如果已配置 GitHub SSH Key，也可以使用 `git clone --depth=1 git@github.com:abinng/my-archnvim.git`)*

> **安装提示**：
> 1. 脚本会自动通过 `pacman` 安装必需的编译工具链与依赖（`clang`、`cmake`、`ninja`、`glow` 等）。
> 2. 底座解压完毕后，终端会短暂拉起原版的偏好配置问答供选择 Nerd Fonts 与按键习惯，随后补丁层将自动完成无感注入与编译。
> 3. 安装脚本的最后阶段会提示是否安装 **Tmux** 插件及配置（输入 `y` 即可自动完成依赖安装与 TPM 插件初始化）[cite: 6]。

---

## 常用扩展快捷键

| 快捷键 | 功能描述 |
| :--- | :--- |
| `,bp` | 在 Windows 宿主机默认浏览器中打开当前 Markdown 实时预览 |
| `,gp` | 在终端内部通过 `glow` 侧边分屏渲染预览 Markdown 文档 |
| `gx` | 在 Windows 默认浏览器中打开光标处的超链接 |
| `y` / `p` | 与 Windows 宿主机剪贴板无缝全局双向复制/粘贴 |

---

## 目录架构

```text
my-archnvim/
├── nvimrc-install.sh      # 48MB 官方自解压安装底座
├── install.sh             # 全自动化引导与单文件安全覆盖脚本
├── patches/               # 针对 Neovim 0.12 的底层源码修复补丁
└── config/                # 调通后的全量核心配置文件与个性化映射
```
