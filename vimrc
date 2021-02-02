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
set hls
set nornu           " relativenumber
set scrolloff=20

syntax enable
syntax on
highlight Comment ctermfg=057   " BlueViolet

"set highlight Comment ctermfg=DarkGrey

" Registers
let @p='·'
let @b='</br>'

" Enter # (or any other comment) before the line
"let @c='s/^\(\s*\)\([^ \t#]\)/\1#\2/'
""let @c='I<!-- <Esc>'

" jump to the next tag attribute entry
let @t = "/=\"\n"

" Double surrounding elements
map DD  ylp%ylp
" 
" Comment selected lines; still doesn't work when
"
" called with the register, like :@c<Return>
map <C-x> :s/^\(\s*\)\([^ \t#]\)/\1#\2/<Return>:nohls<CR>
map <C-c> :s/#//<Return>

" Mappings
"
" Open $MYVIMRC
map si  :split $MYVIMRC<Return>

" Source $MYVIMRC
map so  :source $MYVIMRC<Return>

" Turn on or off search highlighting
map <C-n>   :set hls !<Return>

" Surrounding mappings
" 
" s"  surround double quotes
" s'  surround single quotes
" s9  surround with ( )
" s{  surround by { } 
" s{{ surround with {{ }}
" s[  surround [
" o{{  open  {{
" ob   open (bracket) ${}
" op   open (parenthesses)  $() 
map s" lbi"<Esc>Ea"<Esc>
map s' lbi'<Esc>Ea'<Esc>
map s9 lbi(<Esc>ea)<Esc>
map s[ lbi[<Esc>ea]<Esc>
map sb lbi${<Esc>ea}<Esc>
map s{ lbi{<Esc>ea}<Esc>
map s{{ lBi{{ <Esc>ea }}<Esc>
map o'  a''<Esc>i
map o"  a""<Esc>i
map o9 a()<Esc>i
map o{ a{}<Esc>i
map o{{ a{{ }}<Esc>F{a 
map ob a${}<Esc>i
map op a$()<Esc>i
map o"{{ a"{{}}<Esc>h%a. 

" Text pasting mappings
" pu      put word under cursor under the line
" pa      put word under cursor above the line
map XX yaWo<C-R>"<Space>
map pa O<C-R>"<Space>

map xx yaWo<C-R>"
map pu o<C-R>"

"map sv lF=a$(<Esc>Ea)<Esc>
"" surround as a variable $() till the end of the line
"map sV lF=a$(<Esc>A)<Esc>

map <S-i>    /=\"<Return>f"a

" Abbreviations
abbr teh the

" Pathogen
execute pathogen#infect('~/.vim/bundle/{}')

"set background=dark
"colorscheme default
"highlight IncSearch ctermfg=black  ctermbg=cyan
"highlight Search ctermbg=lightblue  ctermfg=black
"highlight Comment ctermbg=none ctermfg=green
