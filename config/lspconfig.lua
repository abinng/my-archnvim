-- local function pyright_on_attach(client, bufnr)
--     local function organize_imports()
--         local params = {
--             command = 'pyright.organizeimports',
--             arguments = { vim.uri_from_bufnr(0) },
--         }
--         vim.lsp.buf.execute_command(params)
--     end
--
--     if client.name == "pyright" then
--         vim.api.nvim_create_user_command("PyrightOrganizeImports",
--             organize_imports, {desc = 'Organize Imports'})
--     end
-- end
--
-- (function()
--     local old_notify = rawget(vim, 'notify')
--     rawset(vim, 'notify', function(msg, ...)
--         -- if msg:match([[clangd: -32602]]) then
--         --     return
--         -- end
--         --
--         if msg:match([[{ "Corresponding file cannot be determined" }]]) then
--             vim.cmd[[Ouroboros]]
--             return
--         end
--
--         old_notify(msg, ...)
--     end)
-- end)()
--
-- local function clangd_on_attach(client, bufnr)
--     if vim.api.nvim_buf_get_name(bufnr):match "^%a+://" then
--         return
--     end
--
--     local function switch_source_header()
--         local params = {
--             command = 'textDocument/switchSourceHeader',
--             arguments = { vim.uri_from_bufnr(0) },
--         }
--         vim.lsp.buf.execute_command(params)
--     end
--
--     if client.name == "clangd" then
--         vim.api.nvim_create_user_command("ClangdSwitchSourceHeader",
--             switch_source_header, {desc = 'Switch Source Header'})
--     end
-- end
--
-- vim.lsp.config.pyright.setup{
--     on_attach = pyright_on_attach,
-- }
-- -- vim.lsp.config.pylyzer.setup{}
-- vim.lsp.config.lua_ls.setup{}
-- vim.lsp.config.cmake.setup{}
-- -- vim.lsp.config.rust_analyzer.setup{}
--
-- vim.lsp.config.clangd.setup{
--     on_attach = clangd_on_attach,
--     on_new_config = function(new_config, new_cwd)
--         local status, cmake = pcall(require, "cmake-tools")
--         if status then
--             cmake.clangd_on_new_config(new_config)
--         end
--     end,
-- }
--
-- -- vim.api.nvim_set_hl(0, 'LspReferenceRead', {link = 'Search'})
-- -- vim.api.nvim_set_hl(0, 'LspReferenceText', {link = 'Search'})
-- -- vim.api.nvim_set_hl(0, 'LspReferenceWrite', {link = 'Search'})
--
-- local function setup_lsp(event)
--     local id = vim.tbl_get(event, 'data', 'client_id')
--     local client = id and vim.lsp.get_client_by_id(id)
--     if client == nil then
--         return
--     end
--
--     if client.server_capabilities.inlayHintProvider then
--         if vim.lsp.inlay_hint ~= nil and require'archvim.options'.enable_inlay_hint then
--             vim.lsp.inlay_hint.enable(true)
--         end
--     end
--
--     if client.supports_method('textDocument/documentHighlight') then
--         local group = vim.api.nvim_create_augroup('highlight_symbol', {clear = false})
--
--         vim.api.nvim_clear_autocmds({buffer = event.buf, group = group})
--
--         vim.api.nvim_create_autocmd({'CursorHold', 'CursorHoldI'}, {
--             group = group,
--             buffer = event.buf,
--             -- callback = vim.lsp.buf.document_highlight,
--             callback = function()
--                 vim.cmd [[
--             hi LspReferenceText guibg=none "gui=bold "guisp=#a3e697
--             hi LspReferenceRead guibg=none "gui=bold "guisp=#87c2e6
--             hi LspReferenceWrite guibg=none "gui=bold "guisp=#e8a475
-- ]]
--                 vim.lsp.buf.document_highlight()
--             end,
--         })
--
--         vim.api.nvim_create_autocmd({'CursorMoved', 'CursorMovedI'}, {
--             group = group,
--             buffer = event.buf,
--             callback = vim.lsp.buf.clear_references,
--         })
--     end
--
--     -- vim.api.nvim_create_autocmd({"CursorHold"}, {
--     --     callback = function()
--     --         for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
--     --             if vim.api.nvim_win_get_config(winid).zindex then
--     --                 return
--     --             end
--     --         end
--     --         vim.diagnostic.open_float({
--     --             scope = "cursor",
--     --             focusable = false,
--     --             close_events = {
--     --                 "CursorMoved",
--     --                 "CursorMovedI",
--     --                 "BufHidden",
--     --                 "InsertCharPre",
--     --                 "WinLeave",
--     --                 "BufEnter",
--     --                 "BufLeave",
--     --             },
--     --         })
--     --     end,
--     -- })
--
--     -- if client.supports_method('textDocument/signatureHelp') then
--     --     if vim.lsp.buf.signature_help ~= nil and require'archvim.options'.enable_signature_help then
--     --         local group = vim.api.nvim_create_augroup('signature_help', {clear = false})
--     --
--     --         vim.api.nvim_clear_autocmds({buffer = event.buf, group = group})
--     --
--     --         vim.api.nvim_create_autocmd({'CursorHoldI'}, {
--     --             group = group,
--     --             buffer = event.buf,
--     --             callback = function()
--     --                 vim.lsp.buf.signature_help()
--     --             end
--     --         })
--     --     end
--     -- end
-- end
--
-- vim.api.nvim_create_autocmd('LspAttach', {
--   desc = 'Setup LSP',
--   callback = setup_lsp,
-- })

vim.api.nvim_create_user_command("LspInlayHintToggle", function ()
    if vim.lsp.inlay_hint.is_enabled() then
        vim.lsp.inlay_hint.enable(false)
    else
        vim.lsp.inlay_hint.enable(true)
    end
end, {desc = 'Toggle inlay hints'})

vim.api.nvim_create_user_command("LspDiagnosticsToggle", function ()
    if vim.diagnostic.is_enabled() then
        vim.diagnostic.enable(false)
    else
        vim.diagnostic.enable(true)
    end
end, {desc = 'Toggle diagnostics'})


-- vim.lsp.config('clangd')
