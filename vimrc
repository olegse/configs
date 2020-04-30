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
set rnu           " relativenumber

" Highlighting
highlight IncSearch ctermfg=blue  ctermbg=black
highlight Search ctermbg=blue  ctermfg=black
highlight Comment ctermbg=none ctermfg=DarkYellow

syntax enable


" Registers
let @p='·'
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
map <C-x> :s/^\(\s*\)\([^ \t#]\)/\1#\2/<Return><C-n>
map <C-c> :s/#//<Return>

" Mappings
"
" Open $MYVIMRC
map si  :split $MYVIMRC<Return>

" Source $MYVIMRC
map so  :source $MYVIMRC<Return>

" Clear search
map <C-n>   :nohls<Return>


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

abbr teh the
