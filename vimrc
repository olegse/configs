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
highlight Search ctermbg=green ctermfg=black

"highlight Comment ctermfg=Blue
syntax enable


" Store substitution command in a register
let @c='s/^\(\s*\)\([^ \t#]\)/\1#\2/'

" Comment selected lines; still doesn't work when
" called with the register, like :@c<Return>
map <C-x> :s/^\(\s*\)\([^ \t#]\)/\1#\2/<Return>
map <C-c> :s/#//<Return>

"map <C-u> :@u<Return>

" Mappings
map si  :split $MYVIMRC<Return>
map so  :source $MYVIMRC<Return>

" Surrounding mappings
" 
" s"  surround double quotes
" s'  surround single quotes
" s{  surround by { } 
" s{{ surround with {{ }}
" s[  surround [
" oa{{  open a {{
map s" lBi"<Esc>Ea"<Esc>
map s' lBi'<Esc>Ea'<Esc>
map s[ lbi[<Esc>ea]<Esc>
map s{ lbi{<Esc>ea}<Esc>
map s{{ lBi{{ <Esc>ea }}<Esc>
map o'  a''<Esc>i
map o{ a${}<Esc>i
map o{{ a{{ }}<Esc>F{a 
map o( a$()<Esc>i

" Text pasting mappings
" pu      put word under cursor under the line
" pa      put word under cursor above the line
map ya yiwo<C-R>"<Space>
map pa O<C-R>"<Space>

map yu yiwo<C-R>"<Space>
map pu o<C-R>"<Space>

"map sv lF=a$(<Esc>Ea)<Esc>
"" surround as a variable $() till the end of the line
"map sV lF=a$(<Esc>A)<Esc>
