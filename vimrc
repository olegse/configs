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

"highlight Comment ctermfg=Blue
syntax enable

" Store substitution command in a register
let @c='s/^\(\s*\)\([^ \t#]\)/\1#\2/'

" Comment selected lines; still doesn't work when
" called with the register, like :@c<Return>
map <C-x> :s/^\(\s*\)\([^ \t#]\)/\1#\2/<Return>
map <C-c> :s/#//<Return>

"map <C-u> :@u<Return>

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
map oa{ a${}<Esc>i
map oa{{ a{{ }}<Esc>F{a 
"map oa}  a${}<Esc>i

"map sv lF=a$(<Esc>Ea)<Esc>
"" surround as a variable $() till the end of the line
"map sV lF=a$(<Esc>A)<Esc>
"" put copied text under the line
"map pu o<C-R>"
"" put copied text above the line
