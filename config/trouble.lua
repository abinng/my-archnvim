require'trouble'.setup {
    icons = require'archvim.options'.nerd_fonts and {
        indent = {
            top           = "│ ",
            middle        = "├╴",
            -- last          = "└╴",
            last          = "╰╴",
            fold_open     = " ",
            fold_closed   = " ",
            ws            = "  ",
        },
        folder_closed   = " ",
        folder_open     = " ",
        kinds = {
            Array         = " ",
            Boolean       = "󰨙 ",
            Class         = " ",
            Constant      = "󰏿 ",
            Constructor   = " ",
            Enum          = " ",
            EnumMember    = " ",
            Event         = " ",
            Field         = " ",
            File          = " ",
            Function      = "󰊕 ",
            Interface     = " ",
            Key           = " ",
            Method        = "󰊕 ",
            Module        = " ",
            Namespace     = "󰦮 ",
            Null          = " ",
            Number        = "󰎠 ",
            Object        = " ",
            Operator      = " ",
            Package       = " ",
            Property      = " ",
            String        = " ",
            Struct        = "󰆼 ",
            TypeParameter = " ",
            Variable      = "󰀫 ",
        },
    } or nil,
}

vim.cmd [[
augroup trouble_setlocal
autocmd!
autocmd FileType trouble setlocal wrap
augroup END
]]
