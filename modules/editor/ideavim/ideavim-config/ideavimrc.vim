" .ideavimrc is a configuration file for IdeaVim plugin. It uses
"   the same commands as the original .vimrc configuration.
" You can find a list of commands here: https://jb.gg/h38q75
" Find more examples here: https://jb.gg/share-ideavimrc
let mapleader = " "

" TODO Ideavim cannot use environment variables https://youtrack.jetbrains.com/issue/VIM-2143/expand-environment-variables-in-source-command
source /Users/benedekfauszt/.config/home-manager/vim/common-keymaps.vim

"" -- Suggested options --
" Show a few lines of context around the cursor. Note that this makes the
" text scroll if you mouse-click near the start or end of the window.
set scrolloff=5

" Do incremental searching.
set incsearch
set relativenumber
set ignorecase
set smartcase
set hlsearch

nmap <esc> :nohl<cr>
nmap <c-c> :nohl<cr>
nmap <leader>vo :!alacritty<space>-e<space>nvim<space>%<cr>

" Don't use Ex mode, use Q for formatting.
map Q gq

" --- Enable IdeaVim plugins https://jb.gg/ideavim-plugins

" Highlight copied text
Plug 'machakann/vim-highlightedyank'
" Commentary plugin
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'

"" -- Map IDE actions to IdeaVim -- https://jb.gg/abva4t
"" Map \r to the Reformat Code action
"map \r <Action>(ReformatCode)

"" Map <leader>d to start debug
"map <leader>d <Action>(Debug)

"" Map \b to toggle the breakpoint on the current line
"map \b <Action>(ToggleLineBreakpoint)

nmap <C-o> <Action>(Back)
nmap <C-i> <Action>(Forward)

nmap <leader>hr <Action>(Vcs.RollbackChangedLines)

" Switc between tabs
nmap <S-h> <Action>(PreviousTab)
nmap <S-l> <Action>(NextTab)
nmap <C-w><C-c> <Action>(CloseAllEditorsButActive)
" Select upward
map <A-k> <Action>(EditorSelectWord)
map <A-j> <Action>(EditorUnSelectWord)

nmap <leader>fs <Action>(FindInPath)
nmap <leader>ff <Action>(GotoFile)
nmap <leader>wh <Action>(HideAllWindows)

" Reorder tabs
nnoremap <leader>tp :tabm-1 <CR>
nnoremap <leader>tn :tabm+1 <CR>

nmap <C-t> <Action>(ActivateTerminalToolWindow)
nmap <C-e><C-f> <Action>(SelectInProjectView)
nmap <C-e><C-e> <Action>(ActivateProjectToolWindow)
nmap <C-w><C-f> <Action>(HideAllWindows)

set clipboard=unnamedplus "use system clipboard as default register

nnoremap <leader>vi :vs ~/.ideavimrc<cr>
nnoremap <leader>vs :source ~/.ideavimrc<cr>

"Wrapping in java
vnoremap <c-w><c-j>tc dOtry {<esc>p`]o<S-Tab>} catch(final Exception e) {<cr>}<esc>?try<cr>$| " Wrap selection info try catch block
vnoremap <c-w><c-j>tf dOtry {<esc>p`]o<S-Tab>} finally {<cr>}<esc>?try<cr>$| " Wrap selection info try finally block
vnoremap <c-w><c-j>tr dOtransactionTemplate.execute(status -> {<cr>return null;<cr>});<esc>kv>kp
vnoremap <c-w><c-j>ifi dOif () {<esc>p`]o<S-Tab>}<esc>%hh
vnoremap <c-w><c-j>ife dOif () {<cr>} else {<esc>p`]o<S-Tab>}<esc>
nnoremap <c-w><c-u><c-j><c-j> ?{<cr>v?;\|{<cr>/.<cr>ohd%x<c-o>x| "Removes the if ary any block around the current block

"Navigation-
noremap <leader>gbd gg/{<cr>/@Autowired<cr>Nj| "Goto bean declarations
