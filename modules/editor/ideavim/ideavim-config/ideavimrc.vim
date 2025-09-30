" .ideavimrc is a configuration file for IdeaVim plugin. It uses
"   the same commands as the original .vimrc configuration.
" You can find a list of commands here: https://jb.gg/h38q75
" Find more examples here: https://jb.gg/share-ideavimrc
"
"""""" OPTIONS """"""
let mapleader = " "
set incsearch
set number
set relativenumber
set ignorecase
set smartcase
set hlsearch
" Show a few lines of context around the cursor. Note that this makes the
" text scroll if you mouse-click near the start or end of the window.
set scrolloff=5

"""""" CORE KEYMAPS """"""
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

nnoremap <C-q> :q<CR>
nnoremap <C-b> :bd<CR>

inoremap <C-.> <esc>mqA;<esc>`qa| "Add ; to the end of the line and go back
nnoremap <C-.> mqA;<esc>`q| "Add ; to the end of the line and go back
inoremap <C-,> <esc>mqA,<esc>`qa| "Add , to the end of the line and go back
nnoremap <C-,> mqA,<esc>`q| "Add , to the end of the line and go back

nnoremap <C-y> e<c-u>normal! <cr>| "For tiling window manager mapping conflict
nmap <esc> :nohl<cr>
nmap <c-c> :nohl<cr>
nmap <leader>vo :!alacritty<space>-e<space>nvim<space>%<cr>

"" -- Suggested options --

" --- Enable IdeaVim plugins https://jb.gg/ideavim-plugins

Plug 'machakann/vim-highlightedyank'
Plug 'justinmk/vim-sneak'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'

" justinmk/vim-sneak
xmap ű <Plug>Sneak_s
xmap Ű <Plug>Sneak_S


"" -- Map IDE actions to IdeaVim -- https://jb.gg/abva4t
map <leader>ll <Action>(ReformatCode)
nmap <C-o> <Action>(Back)
nmap <C-i> <Action>(Forward)
nmap <C-z> <Action>(EditorChooseLookupItem)
imap <C-z> <Action>(EditorChooseLookupItem)
nmap úc <Action>(NextDiff)
nmap őc <Action>(PreviousDiff)
nmap <leader>hr <Action>(Vcs.RollbackChangedLines)
nmap <C-p> <Action>(PreviousTab)
nmap <C-n> <Action>(NextTab)
nmap <C-w><C-c> <Action>(CloseAllEditorsButActive)
map <A-k> <Action>(EditorSelectWord)
map <A-j> <Action>(EditorUnSelectWord)
nmap <leader>fs <Action>(FindInPath)
nmap <leader>ff <Action>(GotoFile)
nmap <leader>wh <Action>(HideAllWindows)

nmap <C-t> <Action>(ActivateTerminalToolWindow)
nmap <C-e><C-f> <Action>(SelectInProjectView)
nmap <C-e><C-e> <Action>(ActivateProjectToolWindow)
nmap <C-w><C-f> <Action>(HideAllWindows)

set clipboard=unnamedplus "use system clipboard as default register

"Running stuff
nmap <leader>tr <Action>(RunClass)
nmap <leader>tl <Action>(Rerun)
nmap <leader>rr <Action>(RunClass)
nmap <leader>rl <Action>(Rerun)
nmap <leader>tm <Action>(RunMenu)
