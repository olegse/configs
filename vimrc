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
set nornu           " relativenumber
set scrolloff=20

syntax enable
syntax on
highlight Comment ctermfg=red ctermbg=black
highlight IncSearch ctermfg=yellow  ctermbg=green
highlight Search ctermbg=yellow ctermfg=blue

nnoremap <C-C> :split /var/node/materials-ui/src/contexts/GlobalContext.js


" Registers
let @p='·'
let @b='</br>'

" Enter # (or any other comment) before the line
"let @c='s/^\(\s*\)\([^ \t#]\)/\1#\2/'
""let @c='I<!-- <Esc>'

" jump to the next tag attribute entry
let @t = "/=\"\n"
let @e = "/ *\"\nA"

" Double surrounding elements
map DD  ylp%ylp

 
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
map s{ lbi{<Esc>ea}<Esc>      " surround by brackets (b)
map s{{ lBi{{ <Esc>ea }}<Esc>
map o'  a''<Esc>i
map o"  a""<Esc>i
map o9 a()<Esc>i
map o{ a{}<Esc>i
map o{{ a{{ }}<Esc>F{a 
map ob a${}<Esc>i
map op a$()<Esc>i
map o"{{ a"{{}}<Esc>h%a. 
map f(   Ea()<Esc>

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

" HTML
"map <S-i>    /=\"<Return>f"a

" Copy word under cursor and past in don in 
map  yo" 

nnoremap  <Leader>i "nyw?importoimport n from '';<Esc>Ba
inoremap ^D <Esc>vaW^P?<a/<Esc>O

"""  Handling quotes """

" Enter double quotes
inoremap "" ""<Esc>i

" Ignore entering the insert mode inside quoutes
inoremap ""<Space> ""<Esc>i

" Open double-quotes on =" pattern
inoremap =" =""<Esc>i

" Open double-quotes on :" pattern, assumed in maps
inoremap :" : ""<Esc>i

""" Handle brackets """
inoremap (' ('')<Esc>2F'a

" Jump to the next entry poinst for := '" syntax
nnoremap en  /\(: *\\|form \\|from \) *['"a-zA-Z_]<Enter>/\s<Enter>/\w\\|\(''\)<Enter> :set nohls
"
" turn on the map on ef and turn off on field change
"map r en
" next is to handle inner value, like vr, conveniet after r

" substitute word under word
nnoremap <Leader>s :s/\<<C-r><C-w>\>/

""" Handle tags 
inoremap >< ><Esc>yaWEpF<a/<Esc>F<i
inoremap ><< ><Esc>yaWEpF<a/<Esc>F>a<Esc>O  
inoremap <<Space>/ < /><Esc>F<a

" Handle [] brackets
inoremap [] []<Esc>i

" Handling a single quotes
inoremap '' ''<Esc>i

" put Space after two quotes to ignore mapping
inoremap ''<Space> ''<Space>

" put , (comma) after two quotes to ignore mapping
inoremap '', '',

" Open double quotes 
noremap "" ""<Esc>i

" Put space after two quotes to leave a quotes
" as it is
inoremap ""<Space> ""<Space>

" Open a new entry in array with ,'
inoremap ,' <Esc>A,<Enter>

""" Handle open brackets """

" just open the brackets, no space in between
inoremap () ()<Esc>i

" ignore mapping 
inoremap ()<Space> ()<Space>

" open the brackets with one space
inoremap (<Space>) (  )<Esc>F(a<Space>

" open a block
inoremap (<Space><Space>) (<Enter>)<Esc>O  

inoremap ((<Space> ((  ))<Esc>F(a 


" same for the brackets
inoremap {{}} {{}}<Esc>hi

" Handling brackets
inoremap {} {}<Esc>i
inoremap {}<Space> {}<Space>
" open the brackets with one space
inoremap {<Space>} {  }<Esc>%a<Space>
" open a block for {...}
inoremap {<Enter> {<Enter>}<Esc>O  

" open double curly brackets
inoremap {{ {{  }}<Esc>F{a 

" Javascipt specific 
""" Handle arrow functions """

inoremap =(<Space> = ()<Esc>i
inoremap =(<Space><Space> = ()<Space>

inoremap =><Space> => {}<Esc>i
inoremap => => {}<Esc>O  

" Jump out of "" or '' or {} when within object and
" append comma, being ready for the next entry
inoremap  Ea, 

""" Handle comments """

" Open comment block
inoremap /*<Space> /* */<Esc>F<Space>i<Space>

inoremap import import from ;<Esc>^ea 

" Oftenly used mappings
" console.log
inoremap cons. console.log()<Esc>i
imap ret. return<Esc>

""" Autosave when accesing Escape mode """
inoremap  :w

" Navigate tabs
nnoremap <Right> gt
nnoremap <Left> gT

"Implement jump to the bottom line and
"enter INSERT mode
"inoremap > > <Esc>y2hA</<Esc>pF i
" Abbreviations
abbr teh the

" Pathogen
execute pathogen#infect('~/.vim/bundle/{}')

"set background=dark
colorscheme darkblue
"highlight Comment ctermbg=none ctermfg=green

augroup Html
  au BufNewFile *.blade.php 0r ~/.vim/skeleton/html
augroup end

augroup Javascript
  au VimEnter *.js let &path=expand("%:p:h") 
  au VimEnter *.ts set filetype=javascript
  au VimEnter *.tsx set filetype=javascript
  au VimEnter *.js set filetype=javascript
augroup end


" IDEA
" insert after next word
