set nocompatible
set encoding=utf-8

" no intro message
set shortmess+=I

let s:uname = system('uname')
let s:is_NT = ( s:uname =~ '^MSYS_NT-' || s:uname =~ '^MINGW\(32\|64\)_NT-' )

if s:is_NT
   set title
   set titlestring=vim\ «%F»
endif

" Don't time out on mappings.  Time out on key codes almost immediately
" because (a) I never want to enter them manually, and (b) "^[" hanging
" in showcmd area is annoying.
set notimeout ttimeout ttimeoutlen=10

set history=200
set ul=1000

" Don't lose the undo tree upon leaving a buffer.
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

set wrap nolbr

filetype off
set ai
set pastetoggle=<F2>
filetype indent off
filetype plugin on
let python_highlight_all = 1
au InsertLeave * set nopaste

" Parse the entire file in order to correct syntax highlighting.
nnoremap <F7> :syntax sync fromstart<CR>

if s:is_NT
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

set nu nuw=5
hi LineNr ctermfg=DarkGrey ctermbg=black

set noshowmatch
if v:version >= 700 | hi MatchParen ctermfg=black | endif

set ts=8
set sw=4
set expandtab
set sts=0 sta
set backspace=eol,start

if has('patch-8.2.0590')
set backspace=eol,nostop
endif

hi Tab ctermbg=232
match Tab /\t/

set listchars=extends:>,precedes:<,trail:~,eol:$,nbsp:˽,tab:↗↝
if has("patch-7.4.710") | set listchars+=space:· | endif

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

set noea lz

map Q @q
nmap Y y$

"Killing"
nmap <C-k> "_dd
vmap <C-k> "_d

" please no Help
map <F1> <Esc>
imap <F1> <Esc>

" follow the leader
nnoremap <Leader>i i<Space><Esc>r
nmap <Leader>n <Leader>i<CR>
nnoremap <Leader>b :ls<CR>:buffer<Space>

vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

inoremap <C-j><C-j> <C-j>
inoremap <C-j>date <C-r>=strftime('%Y-%m-%d')<CR>
inoremap <C-j>time <C-r>=strftime('%H:%M:%S')<CR>
inoremap <C-j>isot <C-r>=strftime('%FT%R%z')<CR>
inoremap <C-j>uuid <C-r>=substitute(system("uuidgen"), '\n$', '', '')<CR>
inoremap <C-j>fn <C-r>=expand('%')<CR>
inoremap <C-j>fp <C-r>=expand('%:p')<CR>

runtime macros/matchit.vim

runtime! vimrc/*.vim

set dir=~/.vim/swap-files//

" no monkeying with system clipboard
set clipboard=

