vim.g.mapleader = ','

vim.cmd [[
set mouse=a
set mousemodel=extend
set updatetime=400
set nu nornu ru ls=2
set et sts=0 ts=4 sw=4
set signcolumn=number
set nohls
set listchars=tab:▸\ ,trail:⋅,extends:❯,precedes:❮
set cinoptions=j1,(0,ws,Ws,g0,:0,=0,l1
set cinwords=if,else,switch,case,for,while,do
set showbreak=↪
set list
" set clipboard+=unnamedplus
set switchbuf=useopen
set exrc
set foldtext='+--'
set bri wrap
" set cc=80
set termguicolors
]]

vim.cmd [[
augroup disable_formatoptions_cro
autocmd!
autocmd BufEnter * setlocal formatoptions-=cro
augroup end
]]

vim.cmd [[
augroup disable_swap_exists_warning
autocmd!
autocmd SwapExists * let v:swapchoice = "e"
augroup end
]]

vim.cmd [[
augroup check_file_updated
autocmd!
autocmd FocusGained,BufEnter * :checktime
augroup end
]]

-- vim.cmd [[
-- augroup neogit_setlocal
-- autocmd!
-- autocmd FileType NeogitStatus set foldtext='+--'
-- augroup END
-- ]]

-- vim.g_printed = ''
-- vim.g_print = function(msg)
--     vim.g_printed = vim.g_printed .. tostring(msg) .. '\n'
-- end
-- vim.g_dump = function()
--     print(vim.g_printed)
-- end

-- vim.lsp.set_log_level("warn")

local default_opts = {
    nerd_fonts = true,
    disable_notify = true,
    transparent_color = false,
    more_cpp_ftdetect = true,
    enable_signature_help = false,
    enable_inlay_hint = true,
    enable_clipboard = true,
    enable_kitty = false,
}

(function()
    local data_path = vim.fn.stdpath('data') .. '/archvim'
    local file_name = data_path .. '/opts.json'
    local file = io.open(file_name, 'r')
    if file then
        local content = file:read('*a')
        file:close()
        local result = vim.fn.json_decode(content)
        for k, v in pairs(result) do
            default_opts[k] = v
        end
    end
end)()

vim.opt.clipboard:append { 'unnamed', 'unnamedplus' }
vim.g.clipboard = 'osc52'

local yank_bin = (vim.fn.executable("win32yank") == 1 and "win32yank")
              or (vim.fn.executable("win32yank.exe") == 1 and "win32yank.exe")

if yank_bin then
    vim.g.clipboard = {
        name = "win32yank-wsl",
        copy = {
            ["+"] = yank_bin .. " -i --crlf",
            ["*"] = yank_bin .. " -i --crlf",
        },
        paste = {
            ["+"] = yank_bin .. " -o --lf",
            ["*"] = yank_bin .. " -o --lf",
        },
        cache_enabled = 0,
    }
end

-- 解决 WSL 下 gx 打开链接报 explorer.exe command failed (1) 的问题
if vim.fn.has("wsl") == 1 then
    vim.ui.open = function(path)
        -- 使用 cmd.exe /c start 打开 URL，返回码为 0，且完美支持带参数的复杂链接
        vim.fn.jobstart({ "cmd.exe", "/c", "start", '""', path }, { detach = true })
    end
end

-- 启用 which-key 浮窗按键提示
-- local ok, wk = pcall(require, "which-key")
-- if ok then
--     wk.setup({
--         plugins = {
--             presets = {
--                 operators = true,
--                 motions = true,
--                 text_objects = true,
--                 windows = true,
--                 nav = true,
--                 z = true,
--                 g = true, -- 开启针对 g 的内置按键提示
--             },
--         },
--     })
--     vim.o.timeout = true
--     vim.o.timeoutlen = 300 -- 按下 g 后停顿 300ms 弹出提示
-- end

-- markdown-preview WSL2 浏览器自动唤起配置
if vim.fn.has("wsl") == 1 then
    -- 自定义调用 Windows 浏览器函数
    vim.g.mkdp_browserfunc = 'OpenMarkdownPreviewWSL'
    vim.cmd([[
        function! OpenMarkdownPreviewWSL(url)
            call jobstart(['cmd.exe', '/c', 'start', '""', a:url], {'detach': v:true})
        endfunction
    ]])
    -- 让预览服务绑定在 127.0.0.1，确保 Windows 本地端口转发互通
    vim.g.mkdp_open_to_the_world = 0
    vim.g.mkdp_open_ip = '127.0.0.1'
    vim.g.mkdp_port = '8080'
end

return setmetatable({}, {
    __newindex = function (_, k, v)
        rawset(default_opts, k, v)
        local data_path = vim.fn.stdpath('data') .. '/archvim'
        if vim.fn.isdirectory(data_path) ~= 1 then
            vim.fn.mkdir(data_path, 'p')
        end
        local file_name = data_path .. '/opts.json'
        local file = io.open(file_name, 'w')
        assert(file, string.format("cannot open file '%s' for write", file_name))
        file:write(vim.fn.json_encode(default_opts))
        file:close()
    end,
    __index = function (_, k)
        return rawget(default_opts, k)
    end,
})
