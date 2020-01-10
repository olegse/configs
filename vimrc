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

" Comment selected lines
let @c='s/^\(\s*\)\([^#]\)/\1#\2/'
map <C-x> :s/^\(\s*\)\([^ \t#]\)/\1#\2/<Return>
map <C-c> :s/#//<Return>
"map <C-u> :@u<Return>
"map dd lBi"<Esc>Ea"<Esc>
set matchpairs=<:>,[:],{:},(:)
highlight Search ctermfg=Blue
highlight Comment ctermfg=White ctermbg=Grey
syntax enable

"map dd lBi"<Esc>Ea"<Esc>
map SS lBi"<Esc>Ea"<Esc>
map ss lBi'<Esc>Ea'<Esc>
map pu o<C-R>"
map pu O<C-R>"
