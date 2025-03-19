" TODO Ideavim cannot use environment variables https://youtrack.jetbrains.com/issue/VIM-2143/expand-environment-variables-in-source-command
source /Users/benedekfauszt/.config/home-manager/public/vim/wrapping.vim
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

nnoremap <leader>vk :vs<space>$HOME_MANAGER_LOCATION/vim/common-keymaps.vim<cr>| " Opens the common-keymaps.vim file
nnoremap <leader>vs :source<space>$HOME_MANAGER_LOCATION/vim/common-keymaps.vim<cr>| " sources the keymap file

vnoremap <leader>w" <esc>`>a"<esc>`<i"<esc>| "Wrap selection into ""
vnoremap <leader>w' <esc>`>a'<esc>`<i'<esc>| "Wrap selection into ''
vnoremap <leader>w{ <esc>`a}<esc>`<i{<esc>| "Wrap selection into {}
vnoremap <leader>w( <esc>`>a)<esc>`<i(<esc>| "Wrap selection into ()
vnoremap <leader>w[ <esc>`>a]<esc>`<i[<esc>| "Wrap selection into []
vnoremap <leader>wu <esc>`>x`<x| " Unwraps the edges of the selection
inoremap <C-2> ""<Left>
inoremap <C-1> ''<Left>
inoremap <C-7> {}<Left>
inoremap <C-7><CR> {}<Left><CR><esc>O
inoremap <C-8> ()<Left>
inoremap <C-8><CR> ()<Left><CR><esc>O

nnoremap <C-y> :<c-u>normal! <cr>| "For aerospace mapping conflict

inoremap <C-.> <esc>mqA;<esc>`qa| "Add ; to the end of the line and go back
nnoremap <C-.> mqA;<esc>`q| "Add ; to the end of the line and go back
inoremap <C-,> <esc>mqA,<esc>`qa| "Add , to the end of the line and go back
nnoremap <C-,> mqA,<esc>`q| "Add , to the end of the line and go back

augroup inside_function_operator
  autocmd!
  autocmd FileType javascript,typescript onoremap  if :<c-u>execute "normal! ?\\v(function\\|\\=\\>)\\s\r/{\r:nohlsearch\rv%kg_oj_"<cr>
  autocmd FileType javascript,typescript nnoremap vif :<c-u>execute "normal! ?\\(function\\|=>\\)\r/{\r:nohlsearch\r"<cr>v%kg_oj_
augroup END

nnoremap ]q :cn<cr>
nnoremap [q :cp<cr>

nnoremap ]@ :cn<cr>
nnoremap [@ :cp<cr>

command! MessagesClear for n in range(200) | echom "" | endfor

set errorformat+={\"name\":%*\[\ \]\"%m\"\\,%*\\s\"ref\":%*\\s\"%f:%l\"}\\, " Error format with line number
set errorformat+={\"name\":%*\[\ \]\"%m\"\\,%*\\s\"ref\":%*\\s\"%f\"}\\, " Error format without line number
set errorformat+={\"name\":%*\[\ \]\"%m\"\\,%*\\s\"ref\":%*\\s\"%f:%l\"} " Error format with line number without comma
set errorformat+={\"name\":%*\[\ \]\"%m\"\\,%*\\s\"ref\":%*\\s\"%f\"} " Error format without line number without comma


" Jump to the next word starting with the given letter
nnoremap <c-f> :call SearchWordForward()<CR>
nnoremap <c-f><c-f> :call SearchWordBackward()<CR>
function! SearchWordForward()
  let l:char = nr2char(getchar())
  execute "normal! /\\\<" . l:char . ""
endfunction
function! SearchWordBackward()
  let l:char = nr2char(getchar())
  execute "normal! ?\\\<" . l:char . ""
endfunction
