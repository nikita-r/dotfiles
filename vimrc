set nocompatible
set encoding=utf-8

" Don't get reminded about poor children in Uganda.
set shortmess+=I

let s:is_msys = system('uname') =~ '^MSYS_NT-'

if s:is_msys
   set title
   set titlestring=vim\ «%F»
endif

" Don't time out on mappings.  Time out on key codes almost immediately
" because (a) I never want to enter them manually, and (b) "^[" hanging
" in showcmd area is annoying.
set notimeout ttimeout ttimeoutlen=10

set history=200
set ul=1000

" Don't lose the undo tree when I leave buffer.
set hid

set ls=2
set ruler
set stl=%F\ [%{strlen(&fenc)?&fenc:'none'},%{&ff}]%y\ %r%m\ %w
set stl+=\ %=\ 
set stl+=<u%04.B>\ %7.(%c%V%)\|\ %5.l/%L\ 
set showcmd
set wildmode=list:longest,full

set virtualedit=block,onemore
fu! ToggleVE()
  if &ve != 'all'| set ve=all
             else| set ve=block,onemore
  endif
  set ve?
endfu
nnoremap <F8> :call ToggleVE()<CR>

set ai pastetoggle=<F2>
au InsertLeave * set nopaste

filetype plugin indent on
syntax on
au BufRead,BufNewFile *.py let python_highlight_all=1

" Parse the entire file in order to correct syntax highlighting.
nnoremap <F7> :syntax sync fromstart<CR>

if s:is_msys
  color industry
else
    set t_Co=256
    if !empty(globpath(&rtp, 'colors/inkpot.vim'))
      let g:inkpot_black_background = 1
      color inkpot
      hi ErrorMsg ctermfg=white
      if v:version >= 700
        hi PmenuThumb ctermbg=121
      endif
    else
      color zellner
      hi Statement ctermfg=196
      if v:version >= 700
        hi Pmenu ctermfg=black
        hi PmenuSel ctermfg=black
        hi PmenuThumb ctermbg=45
      endif
    endif
endif

set wrap nolbr
set nu
hi LineNr ctermfg=DarkGrey ctermbg=black

set noshowmatch
if v:version >= 700 | hi MatchParen ctermfg=black | endif

set expandtab
set softtabstop=4
let &shiftwidth = &softtabstop
set backspace=indent,eol,start

set tabstop=8
hi Tab ctermbg=232
match Tab /\t/

set listchars=extends:>,precedes:<,trail:~,eol:$,nbsp:·,tab:↗↝

set ic smartcase
set wrapscan
set incsearch
set hlsearch
"hi Search ctermfg=white ctermbg=DarkBlue
nnoremap <silent> <F3> :noh<CR>
nnoremap <silent> <S-F3> :set hls<CR>
vmap <F3> <Esc><F3>gv| imap <F3> <C-o><F3>
vmap <S-F3> <Esc><S-F3>gv| imap <S-F3> <C-o><S-F3>
vnoremap <silent> <F4> y:let @/='\V'.substitute(@",'\','\\\\','g')<CR>:set hls<CR>

" Recognize the sequence that PuTTY sends when you press <S-F3>.  The sequence
" was captured by typing <C-v><S-F3> in i-mode.
set <S-F3>=[25~

set noea
set lazyredraw

map Q @q
nmap Y y$

"Killing"
nmap <C-k> "_dd
vmap <C-k> "_d

" Insert one character.
nnoremap <Leader>i i<Space><Esc>r
" Split the line.
nmap <Leader>n <Leader>i<CR>

vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

nnoremap <Leader>b :ls<CR>:buffer<Space>

inoremap <C-j><C-j> <C-j>
inoremap <C-j>date <C-r>=strftime('%Y-%m-%d')<CR>
inoremap <C-j>time <C-r>=strftime('%H:%M:%S')<CR>
inoremap <C-j>isot <C-r>=strftime('%FT%R%z')<CR>
inoremap <C-j>uuid <C-r>=substitute(system("uuidgen"), '\n$', '', '')<CR>
inoremap <C-j>fn <C-r>=expand('%')<CR>
inoremap <C-j>fp <C-r>=expand('%:p')<CR>

runtime macros/matchit.vim
"runtime macros/editexisting.vim

runtime! vimrc/*.vim

set dir=~/.vim/swap-files//

