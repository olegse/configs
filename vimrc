set nocompatible
set number
set autoindent
set autowrite
set sw=0          " shiftwidth
set tabstop=2
set et
set nohls
set splitbelow
set matchpairs=<:>,[:],{:},(:)
highlight Comment ctermfg=Blue
syntax enable

map dd lBi"<Esc>Ea"<Esc>
map ss lBi'<Esc>Ea'<Esc>
map pu o<C-R>"
map pu O<C-R>"
