""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Generic Settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set fenc=utf-8
set fencs=utf-8,usc-bom,euc-jp,gb18030,gbk,gb2312,cp936

syntax on

"set nu
"set cursorline
""set whether user can override the original chars
set backspace=indent,eol,start

filetype on
set noerrorbells


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Searching and Matching
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set showmatch
set incsearch
set hlsearch
set ignorecase



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Related to File
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set autoindent

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"for C
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set smartindent
set cindent

set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set smarttab

set ruler
set rulerformat=%20(%2*%<%f%=\ %m%r\ %3l\ %c\ %p%%%)
"set nu



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Some Convenient Functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <F5> :call CompileRunGpp()<CR>
func! CompileRunGpp()
    exec "w"
    exec "!g++ % -o %<"
    exec "! ./%<"
endfunc
