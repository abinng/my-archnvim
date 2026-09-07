vim.api.nvim_create_user_command("Quit", function ()
    vim.cmd [[ wall | if &buftype == 'quickfix' | cclose | elseif &buftype == 'prompt' | quit! | else | quit | endif ]]
end, {desc = 'Quit current window'})
-- 讨厌 q 用作退出的“宏孝子”请删除这 3 行：
vim.keymap.set("n", "q", "<cmd>Quit<CR>", { silent = true })
vim.keymap.set("v", "q", "<Esc>", { silent = true })
vim.keymap.set("n", "Q", "q", { silent = true, noremap = true })

-- 讨厌 jk 的同学请删除这 4 行：
vim.keymap.set("i", "jk", "<Esc>", { silent = true })
vim.keymap.set("i", "kj", "<Esc>", { silent = true })
vim.keymap.set("t", "jk", "<C-\\><C-n>", { silent = true })
vim.keymap.set("t", "kj", "<C-\\><C-n>", { silent = true })

-- Ctrl+Insert 复制；Shift+Insert 粘贴
vim.keymap.set({"n", "v"}, "<C-Insert>", "\"+y", { silent = true })
vim.keymap.set("i", "<C-Insert>", "<Esc>\"+yya", { silent = true })
vim.keymap.set({"n", "v"}, "<S-Insert>", "\"+p", { silent = true })
vim.keymap.set("i", "<S-Insert>", "<C-r>+", { silent = true })

-- Functional wrapper for mapping custom keybindings
-- local function map(mode, lhs, rhs, opts)
--     if type(mode) == 'table' then
--         for i = 1, #mode do
--             map(mode[i], lhs, rhs, opts)
--         end
--         return
--     end
--     local options = { noremap = true }
--     if opts then
--         options = vim.tbl_extend("force", options, opts)
--     end
--     vim.api.nvim_set_keymap(mode, lhs, rhs, options)
-- end

local function is_quickfix_open()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == 'quickfix' then
      return true
    end
  end
  return false
end

local function get_current_quickfix_entry()
  local qflist = vim.fn.getqflist({ idx = 0 })
  local current_idx = qflist.idx
  local entry = vim.fn.getqflist({ id = qflist.id, items = 0 }).items[current_idx]
  return entry
end

vim.keymap.set({"v", "n"}, "_", "+", { noremap = true })
vim.keymap.set({"v", "n"}, "gh", "(v:count == 0 || v:count == 1 ? '^^' : '^^' . (v:count - 1) . 'l')", { silent = true, expr = true })
vim.keymap.set({"v", "n"}, "gl", "(v:count == 0 || v:count == 1 ? '^$' : '^$' . (v:count - 1) . 'h')", { silent = true, expr = true })
vim.keymap.set({"v", "n"}, "gm", "gM", { noremap = true })
vim.keymap.set({"v", "n"}, "gM", "gm", { noremap = true })
vim.keymap.set({"v", "n", "i"}, "<F4>", "<cmd>wa<CR>")
vim.keymap.set({"v", "n", "i"}, "<F6>", "<cmd>cclose | Trouble qflist toggle<CR>")
vim.keymap.set({"v", "n", "i"}, "<F18>", "<cmd>copen<CR>")
-- vim.keymap.set({"v", "n", "i"}, "<F6>", function ()
--     if is_quickfix_open() then
--         return "<cmd>cclose<CR>"
--         -- if get_current_quickfix_entry() then
--         --     return "<cmd>cn<CR>"
--         -- else
--         --     return "<cmd>cc<CR>"
--         -- end
--     else
--         -- return "<cmd>cc<CR>"
--         return "<cmd>copen<CR>"
--     end
-- end, { noremap = true, expr = true })
-- -- vim.keymap.set({"v", "n", "i"}, "<F18>", function ()
-- --     if is_quickfix_open() then
-- --         return "<cmd>cclose<CR>"
-- --         -- if get_current_quickfix_entry() then
-- --         --     return "<cmd>cp<CR>"
-- --         -- else
-- --         --     return "<cmd>cclose<CR>"
-- --         -- end
-- --     else
-- --         -- return "<cmd>cc<CR>"
-- --         return "<cmd>copen<CR>"
-- --     end
-- -- end, { noremap = true, expr = true })
vim.keymap.set({"v", "n", "i", "t"}, "<F7>", "<cmd>NvimTreeFindFileToggle<CR>", { silent = true })
vim.keymap.set({"v", "n", "i", "t"}, "<F9>", "<cmd>Trouble diagnostics toggle focus=false<CR>", { silent = true })
vim.keymap.set({"v", "n", "i", "t"}, "<F21>", "<cmd>Trouble diagnostics toggle focus=false filter.buf=0<CR>", { silent = true })
if pcall(require, "cmake-tools") then
    vim.keymap.set({"v", "n", "i", "t"}, "<F5>", "<cmd>wa<CR><cmd>if luaeval('require\"cmake-tools\".is_cmake_project()')|call execute('CMakeRun')|elseif filereadable('platformio.ini')|call execute('TermExec cmd=\\<C-c>')|sleep 24m|call execute('TermExec cmd=''platformio -f -c vim run --target upload && platformio -f -c vim device monitor''')|elseif filereadable('run.sh')|call execute('TermExec cmd=./run.sh')|endif<CR>", { silent = true })
    vim.keymap.set({"v", "n", "i", "t"}, "<F17>", "<cmd>wa<CR><cmd>if luaeval('require\"cmake-tools\".is_cmake_project()')|call execute('CMakeStopRunner')|call execute('CMakeStopExecutor')|else|call execute('TermExec cmd=\\<C-c>')|endif<CR>", { silent = true })
    vim.keymap.set("n", "cmr", "<cmd>wa<CR><cmd>if luaeval('require\"cmake-tools\".is_cmake_project()')|call execute('CMakeRun')|elseif filereadable('platformio.ini')|call execute('TermExec cmd=\\<C-c>')|sleep 24m|call execute('TermExec cmd=''platformio -f -c vim run --target upload && platformio -f -c vim device monitor''')|elseif filereadable('run.sh')|call execute('TermExec cmd=./run.sh')|endif<CR>", { silent = true, desc = 'CMakeRun' })
    vim.keymap.set("n", "cmb", "<cmd>wa<CR><cmd>if luaeval('require\"cmake-tools\".is_cmake_project()')|call execute('CMakeBuild')|elseif filereadable('platformio.ini')|call execute('TermExec cmd=''platformio -f -c vim run''')|elseif filereadable('Makefile')|call execute('TermExec cmd=make')|elseif filereadable('build.sh')|call execute('TermExec cmd=./build.sh')|endif<CR>", { silent = true, desc = 'CMakeBuild' })
    vim.keymap.set("n", "cmc", "<cmd>wa<CR><cmd>if luaeval('require\"cmake-tools\".is_cmake_project()')|call execute('CMakeGenerate')|elseif filereadable('platformio.ini')|call execute('TermExec cmd=''platformio -f -c vim run --target compiledb''')|elseif filereadable('Makefile')|call execute('TermExec cmd=make configure')|elseif filereadable('configure')|call execute('TermExec cmd=./configure')|endif<CR>", { silent = true, desc = 'CMakeGenerate' })
    vim.keymap.set("n", "cms", "<cmd>wa<CR><cmd>if luaeval('require\"cmake-tools\".is_cmake_project()')|call execute('CMakeStopRunner')|call execute('CMakeStopExecutor')|else|call execute('TermExec cmd=\\<C-c>')|endif<CR>", { silent = true, desc = 'CMakeStopRunner' })
else
    vim.keymap.set({"v", "n", "i", "t"}, "<F5>", "<cmd>wa<CR><cmd>call execute('TermExec cmd=make')<CR>", { silent = true })
    vim.keymap.set({"v", "n", "i", "t"}, "<F17>", "<cmd>wa<CR><cmd>call execute('TermExec cmd=\\<C-c>')<CR>", { silent = true })
end
-- vim.keymap.set({"v", "n", "i", "t"}, "<F10>", "<cmd>Neogit<CR><cmd>set foldtext='+'<CR>", { silent = true })
vim.keymap.set({"v", "n", "i", "t"}, "<F10>", function()
    require'neogit'.open{}
end, { silent = true })
-- vim.keymap.set({"v", "n", "i", "t"}, "<F12>", "<cmd>NoiceAll<CR>", { silent = true })
-- vim.keymap.set({"v", "n", "i", "t"}, "<F10>", "<cmd>DapToggleBreakpoint<CR>", { silent = true })
-- vim.keymap.set({"v", "n", "i", "t"}, "<F22>", "<cmd>DapToggleRepl<CR>", { silent = true })
-- vim.keymap.set({"v", "n", "i", "t"}, "<F12>", "<cmd>DapStepOver<CR>", { silent = true })
-- vim.keymap.set({"v", "n", "i", "t"}, "<F24>", "<cmd>DapStepInto<CR>", { silent = true })
-- vim.keymap.set({"v", "n", "i", "t"}, "<C-F12>", "<cmd>DapStepOut<CR>", { silent = true })
-- if found_cmake then
--     vim.keymap.set({"v", "n", "i", "t"}, "<F9>", "<cmd>if luaeval('require\"cmake-tools\".is_cmake_project() and require\"dap\".session()==nil')|call execute('CMakeDebug')|else|call execute('DapContinue')|endif<CR>", { silent = true })
--     vim.keymap.set({"v", "n", "i", "t"}, "<F21>", "<cmd>if luaeval('require\"cmake-tools\".is_cmake_project() and require\"dap\".session()==nil')|call execute('CMakeStop')|else|call execute('DapTerminate')|endif<CR>", { silent = true })
-- else
--     vim.keymap.set({"v", "n", "i", "t"}, "<F9>", "<cmd>DapContinue<CR>", { silent = true })
--     vim.keymap.set({"v", "n", "i", "t"}, "<F21>", "<cmd>DapTerminate<CR>", { silent = true })
-- end
vim.keymap.set({'v', 'n', 'i', 't'}, '<Ins>', [[<Cmd>ZenMode<CR>]])
-- vim.keymap.set({"v", "n"}, "<CR>", "<cmd>nohlsearch<CR>", { silent = true })

-- vim.keymap.set({"v", "n"}, "g=", "<cmd>Neoformat<CR>", { silent = true })
-- vim.keymap.set({"v", "n"}, "go", "<cmd>Ouroboros<CR>", { silent = true })
-- vim.keymap.set({"v", "n"}, "gO", "<cmd>split | Ouroboros<CR>", { silent = true })
-- vim.keymap.set({"v", "n"}, "g<C-o>", "<cmd>vsplit | Ouroboros<CR>", { silent = true })
-- vim.keymap.set({"v", "n", "i"}, "<F10>", "<cmd>Neoformat<CR>", { silent = true })
-- vim.keymap.set("n", "Q", "<cmd>wa<CR><cmd>qa!<CR>", { silent = true })

-- vim.cmd [[
-- command! -nargs=0 A :ClangdSwitchSourceHeader
-- command! -nargs=? F :Neoformat <f-args>
-- ]]

-- vim.api.nvim_create_autocmd({"VimEnter"}, {
--     -- disable_n_more_files_to_edit
--     callback = function (data)
--         local no_name = data.file == "" and vim.bo[data.buf].buftype == ""
--         if not no_name then
--             -- vim.cmd [[ args % ]]
--         end
--     end,
-- })

vim.keymap.set({'c'}, '<C-a>', [[<Home>]])
vim.keymap.set({'c'}, '<C-e>', [[<End>]])
vim.keymap.set({'c'}, '<C-f>', [[<C-Right>]])
vim.keymap.set({'c'}, '<C-b>', [[<C-Left>]])
vim.keymap.set({'c'}, '<C-g>', [[<Esc>]])
vim.keymap.set({'i'}, '<C-a>', [[<Cmd>normal! ^<CR>]])
vim.keymap.set({'i'}, '<C-e>', [[<End>]])
vim.keymap.set({'i'}, '<C-f>', [[<C-Right>]])
vim.keymap.set({'i'}, '<C-b>', [[<C-Left>]])
vim.keymap.set({'i'}, '<C-n>', [[<Down>]])
vim.keymap.set({'i'}, '<C-p>', [[<Up>]])

if false then -- conflict with tmux M-hjkl, disable for now
    vim.keymap.set({'v', 'n'}, '<M-h>', [[h8h]])
    vim.keymap.set({'v', 'n'}, '<M-j>', [[<C-n>4<C-n>3<C-e>]])
    vim.keymap.set({'v', 'n'}, '<M-k>', [[<C-p>4<C-p>3<C-y>]])
    vim.keymap.set({'v', 'n'}, '<M-l>', [[l8l]])
    vim.keymap.set({'i'}, '<M-h>', [[<Esc>h]])
    vim.keymap.set({'i'}, '<M-j>', [[<Esc>j]])
    vim.keymap.set({'i'}, '<M-k>', [[<Esc>k]])
    vim.keymap.set({'i'}, '<M-l>', [[<Esc>l]])
end
vim.keymap.set({'v', 'n'}, '<M-z>', [[zz]])
vim.keymap.set({'v', 'n'}, '<M-b>', [[b2b]])
vim.keymap.set({'v', 'n'}, '<M-e>', [[e2e]])
vim.keymap.set({'v', 'n'}, '<M-w>', [[w2w]])
vim.keymap.set({'i'}, '<M-z>', [[<Cmd>normal! zz<CR>]])
vim.keymap.set({'i'}, '<M-b>', [[<Cmd>normal! b<CR>]])
vim.keymap.set({'i'}, '<M-e>', [[<Cmd>normal! e<CR>]])
vim.keymap.set({'i'}, '<M-w>', [[<Cmd>normal! w<CR>]])

vim.keymap.set({'n', 'i', 'v'}, '<C-LeftMouse>', '<Nop>', { noremap = true, silent = true })
vim.keymap.set({'n', 'i', 'v'}, '<C-RightMouse>', '<Nop>', { noremap = true, silent = true })

if not pcall(require, 'tmux') then
    vim.keymap.set({'v', 'n', 'i', 't'}, '<C-h>', [[<Cmd>wincmd h<CR>]])
    vim.keymap.set({'v', 'n', 'i', 't'}, '<C-j>', [[<Cmd>wincmd j<CR>]])
    vim.keymap.set({'v', 'n', 'i', 't'}, '<C-k>', [[<Cmd>wincmd k<CR>]])
    vim.keymap.set({'v', 'n', 'i', 't'}, '<C-l>', [[<Cmd>wincmd l<CR>]])
else
    vim.keymap.set({'v', 'i', 't'}, '<C-h>', [[<Cmd>lua require'tmux'.move_left()<CR>]])
    vim.keymap.set({'v', 'i', 't'}, '<C-j>', [[<Cmd>lua require'tmux'.move_bottom()<CR>]])
    vim.keymap.set({'v', 'i', 't'}, '<C-k>', [[<Cmd>lua require'tmux'.move_top()<CR>]])
    vim.keymap.set({'v', 'i', 't'}, '<C-l>', [[<Cmd>lua require'tmux'.move_right()<CR>]])
end
vim.keymap.set({'v', 'n', 'i', 't'}, '<C-S-h>', [[<Cmd>wincmd H<CR>]])
vim.keymap.set({'v', 'n', 'i', 't'}, '<C-S-j>', [[<Cmd>wincmd J<CR>]])
vim.keymap.set({'v', 'n', 'i', 't'}, '<C-S-k>', [[<Cmd>wincmd K<CR>]])
vim.keymap.set({'v', 'n', 'i', 't'}, '<C-S-l>', [[<Cmd>wincmd L<CR>]])
vim.keymap.set({'v', 'n', 'i', 't'}, '<M-r>', [[<Cmd>wincmd r<CR>]])
vim.keymap.set({'v', 'n', 'i', 't'}, '<M-x>', [[<Cmd>wincmd x<CR>]])
vim.keymap.set({'v', 'n', 'i', 't'}, '<M-s>', [[<Cmd>wincmd s<CR>]])
vim.keymap.set({'v', 'n', 'i', 't'}, '<M-v>', [[<Cmd>wincmd v<CR>]])
vim.keymap.set({'v', 'n', 'i', 't'}, '<M-=>', [[<Cmd>wincmd +<CR>]])
vim.keymap.set({'v', 'n', 'i', 't'}, '<M-->', [[<Cmd>wincmd -<CR>]])
vim.keymap.set({'v', 'n', 'i', 't'}, '<M-,>', [[<Cmd>wincmd <Lt><CR>]])
vim.keymap.set({'v', 'n', 'i', 't'}, '<M-.>', [[<Cmd>wincmd ><CR>]])
vim.keymap.set({'v', 'n', 'i', 't'}, '<C-q>', [[<Cmd>wincmd q<CR>]])
vim.keymap.set({'v', 'n', 'i', 't'}, '<M-q>', [[<Cmd>wincmd q<CR>]])
vim.keymap.set('n', '<Esc>', [[<Cmd>nohls<CR><Esc>]], { noremap = true })
-- vim.keymap.set('t', [[<C-\>]], [[<C-\><C-n>]], { noremap = true })
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { noremap = true })
-- vim.keymap.set('t', [[<Esc>]], [[<Esc>]], { noremap = true })
-- vim.keymap.set('t', [[jk]], [[<C-\><C-n>]], opts)

-- 开关终端
-- vim.keymap.set({"v", "n", "i", "t"}, "<C-t>", "<cmd>ToggleTerm<CR>", { silent = true })
vim.keymap.set({"v", "n", "i", "t"}, "<F8>", "<cmd>ToggleTerm<CR>", { silent = true })
vim.keymap.set({"v"}, "<C-S-t>", "<cmd>ToggleTermSendVisualSelection<CR>", { silent = true })
vim.keymap.set({"n", "i"}, "<C-S-t>", "<cmd>ToggleTermSendCurrentLine<CR>", { silent = true })
vim.keymap.set({"t"}, "<C-S-t>", "<cmd>ToggleTermToggleAll<CR>", { silent = true })
-- 格式化代码
vim.keymap.set({'v'}, 'g=', [[<Cmd>Neoformat<CR>]])
vim.keymap.set({'n'}, 'g=', function ()
    vim.lsp.buf.format()
end)
vim.keymap.set({'v', 'n', 'i'}, '<F16>', function()
    vim.lsp.buf.format()
end)
-- 查看文档
vim.keymap.set({'v', 'n'}, 'K', function ()
    vim.lsp.buf.hover()
end)
-- 函数签名
vim.keymap.set({'v', 'n'}, 'gK', function ()
    vim.lsp.buf.signature_help()
end)
-- 代码修复
vim.keymap.set({'v', 'n'}, 'gw', function ()
    vim.lsp.buf.code_action({
        apply = true,
    })
end)
-- 重命名变量
vim.keymap.set({'v', 'n'}, 'gn', function()
  return ":IncRename " .. vim.fn.expand("<cword>")
end, { expr = true, desc = 'Rename symbol' })
vim.keymap.set({'v', 'n'}, 'gN', function()
  return ":IncRename "
end, { expr = true, desc = 'Rename symbol' })
-- 查找符号定义
vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", { desc = 'Goto definition' })
-- 查找符号声明
vim.keymap.set("n", "gD", function()
    vim.lsp.buf.declaration()
end, { desc = 'Goto declaration' })
-- 开关静态分析错误列表
vim.keymap.set("n", "gss", "<cmd>Trouble diagnostics toggle<CR>")
-- 开关编译器报错列表
vim.keymap.set("n", "gsl", "<cmd>cclose | Trouble qflist toggle<CR>")
vim.keymap.set("n", "gsg", "<cmd>Neogit<CR>")
-- 当前光标下的静态分析错误
vim.keymap.set("n", "gsd", function()
    vim.diagnostic.open_float({
        scope = "cursor",
        focusable = false,
        close_events = {
            "CursorMoved",
            "CursorMovedI",
            "BufHidden",
            "InsertCharPre",
            "WinLeave",
            "BufEnter",
            "BufLeave",
        },
    })
end, { desc = 'Diagnostics under cursor' })
-- 开关 Inlay Hint
vim.keymap.set({"v", "n"}, "gsi", function()
        if vim.lsp.inlay_hint ~= nil then
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end
end, { desc = "Toggle inlay hint" })
-- 重启 LSP
vim.keymap.set({"v", "n"}, "gsu", "<cmd>LspStop | LspStart<CR>", { silent = true, desc = "Restart LSP" })
-- 开关项目文件树
vim.keymap.set({"v", "n"}, "gsp", "<cmd>NvimTreeFindFileToggle<CR>", { silent = true, desc = "Toggle Nvim Tree", })
-- 开关大纲视图
vim.keymap.set({"v", "n"}, "gso", "<cmd>AerialToggle!<CR>", { desc = "Toggle aerial outline" })
-- 查找类型定义
vim.keymap.set({"v", "n"}, "gy", "<cmd>Telescope lsp_type_definitions<CR>", { desc = 'Goto type definition' })
-- 查找所有引用
vim.keymap.set({"v", "n"}, "gr", "<cmd>Telescope lsp_references<CR>", { desc = 'Find references' })
-- 删除预定义的一些干扰
pcall(vim.keymap.del, {"n"}, "gri")
pcall(vim.keymap.del, {"n"}, "grr")
pcall(vim.keymap.del, {"v", "n"}, "gra")
pcall(vim.keymap.del, {"n"}, "grn")
pcall(vim.keymap.del, {"v"}, "grc")
pcall(vim.keymap.del, {"n"}, "grt")
-- 查找函数实现
vim.keymap.set({"v", "n"}, "gY", "<cmd>Telescope lsp_implementations<CR>", { desc = 'Find implementations' })
-- 查看全部
vim.keymap.set({"v", "n"}, "gz", "<cmd>Trouble lsp toggle<CR>")
-- 查看类型继承图
vim.keymap.set({"v", "n"}, "gst", function ()
    vim.lsp.buf.typehierarchy("subtypes")
end, { desc = 'List derived class hierarchy' })
vim.keymap.set({"v", "n"}, "gsT", function ()
    vim.lsp.buf.typehierarchy("supertypes")
end, { desc = 'List base class hierarchy' })
-- 头文件/源文件跳转
vim.keymap.set({"v", "n"}, "go", "<cmd>ClangdSwitchSourceHeader<CR>", { silent = true })
vim.keymap.set({"v", "n"}, "gO", "<cmd>split | ClangdSwitchSourceHeader<CR>", { silent = true })
vim.keymap.set({"v", "n"}, "g<C-o>", "<cmd>vsplit | ClangdSwitchSourceHeader<CR>", { silent = true })

vim.keymap.set({'n'}, '<S-Tab>', '<C-o>')
-- vim.keymap.set({'i'}, '<C-Space>', '<Space>')

vim.keymap.set({'n', 'v'}, '<C-g>', "<cmd>lua require('nvim-toggler').toggle()<CR>", { silent = true })

-- vim.keymap.set({'v', 'n'}, 'gp', ':GPT<Space>')
-- vim.keymap.set({'v', 'n'}, 'gP', ':GPT!<Space>')
-- vim.keymap.set({'i'}, '<C-Space>', '<Cmd>GPT<CR>')
-- vim.keymap.set({'i', 'n'}, '<C-t>', '<Cmd>-8,+8GPT refactor this code<CR>')
-- vim.keymap.set({'v'}, '<C-t>', '<Cmd>GPT refactor this code<CR>')

vim.cmd [[
augroup quickfix_setlocal
autocmd!
autocmd FileType qf setlocal wrap
\ | vnoremap <buffer> <F6> <cmd>cclose<CR>
\ | nnoremap <buffer> <F6> <cmd>cclose<CR>
\ | vnoremap <buffer> <F18> <cmd>cclose<CR>
\ | nnoremap <buffer> <F18> <cmd>cclose<CR>
\ | nnoremap <buffer> <Esc> <cmd>cclose<CR>
augroup END
]]

vim.cmd [[
augroup neogit_setlocal
autocmd!
autocmd FileType NeogitStatus nnoremap <buffer> <F10> <cmd>:q<CR>
autocmd FileType NeogitStatus vnoremap <buffer> <F10> <cmd>:q<CR>
autocmd FileType NeogitStatus inoremap <buffer> <F10> <cmd>:q<CR>
autocmd FileType NeogitStatus nnoremap <buffer> gsg <cmd>:q<CR>
augroup END
]]

-- if os.getenv('LOOPCOMMAND') then
--     vim.keymap.set('n', 'R', '<Cmd>R<CR>')
--     vim.api.nvim_create_user_command("R", function ()
--         vim.cmd [[
--         sil! UpdateRemotePlugins
--         wall!
--         cquit!
--         ]]
--     end, { desc = 'Restart NeoVim' })
-- end

-- Markdown 预览快捷键（全局或仅在 md 中生效）
-- ,gp 呼出终端 Glow 纯文本分屏预览
-- ,bp 唤醒 Windows 浏览器实时双向渲染预览
vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function(event)
        vim.keymap.set("n", ",gp", "<cmd>vsp | term glow %<cr>", { buffer = event.buf, desc = "Glow Preview" })
        vim.keymap.set("n", ",bp", "<cmd>MarkdownPreview<cr>", { buffer = event.buf, desc = "Browser Preview" })
    end,
})

return vim.keymap.set
