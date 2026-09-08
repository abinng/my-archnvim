if has('nvim')
  let g:archvim_predownload=1
  lua require('archvim')
else
  echoerr "You are using Vim, not NeoVim"
endif

if filereadable('.vim_localrc')
    source .vim_localrc
endif

lua << EOF
local ok, ts_comment = pcall(require, 'ts_context_commentstring')
if ok then
  ts_comment.setup {
    enable_autocmd = false,
  }
end
EOF
