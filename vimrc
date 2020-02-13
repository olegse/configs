set nocompatible
set number
set autoindent
set autowrite
set sw=0          " shiftwidth
set tabstop=2
set is            " increment search
set et            " expand tab
set nohls
set splitbelow
highlight Search ctermbg=green ctermfg=black

"
"highlight Comment ctermfg=Blue
syntax enable

" Store substitution command in a register
let @c='s/^\(\s*\)\([^#]\)/\1#\2/'

" Comment selected lines; still doesn't work when
" called with the register, like :@c<Return>
map <C-x> :s/^\(\s*\)\([^ \t#]\)/\1#\2/<Return>
map <C-c> :s/#//<Return>
"map <C-u> :@u<Return>
" surround with double quote
map sd lBi"<Esc>Ea"<Esc>
" surround with single quote
map ss lBi'<Esc>Ea'<Esc>
" open a \"{{ }}"
map sa a"{{ }}"<Esc>F{a 
" surround as a variable till the first space
map sv lF=a$(<Esc>Ea)<Esc>
" surround as a variable till the end of the line
map sV lF=a$(<Esc>A)<Esc>
" put copied text under the line
map pu o<C-R>"
" put copied text above the line
map pa O<C-R>"

if has("autocmd")
  augroup templates
    autocmd BufNewFile *.yml 0r ~/.vim/templates/skeleton.yml
  augroup END
endif
