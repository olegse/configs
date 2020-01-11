set nocompatible
set number
set autoindent
set autowrite
set sw=0          " shiftwidth
set tabstop=2
set et
set nohls
set splitbelow
highlight Search ctermbg=green ctermfg=black
"highlight Comment ctermfg=Blue
syntax enable

" Store substitution command in a register
let @c='s/^\(\s*\)\([^#]\)/\1#\2/'

" Comment selected lines; still doesn't work when
" called with the register, like :@c<Return>
map <C-x> :s/^\(\s*\)\([^ \t#]\)/\1#\2/<Return>
map <C-c> :s/#//<Return>
"map <C-u> :@u<Return>
"map dd lBi"<Esc>Ea"<Esc>
"map ss lBi'<Esc>Ea'<Esc>
" put copied text under the line
map pu o<C-R>"
" put copied text above the line
map pa O<C-R>"
