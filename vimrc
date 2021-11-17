set nocompatible
set encoding=utf-8

set shortmess+=I " turn off the intro
set shortmess+=c " turn off ins-completion-menu status
set shortmess-=S " show matches counter when searching

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

set history=255

" Don't lose the undo tree upon leaving a buffer; set 'undolevels'.
set hid ul=4095

set ls=2
set ruler
set stl=%F\ [%{strlen(&fenc)?&fenc:'none'},%{&ff}]%y\ %r%m\ %w
set stl+=\ %=\ 
set stl+=<u%04.B>\ %7.(%c%V%)\|\ %5.l/%L\ 
set showcmd
set wildmode=list:longest,full

set  virtualedit=block,onemore
fu! ToggleVE()
  if &ve != 'all'|  set ve=all
  else|   set ve=block,onemore
  endif
  set ve?
endfu
nnoremap <F8> :call ToggleVE()<CR>

set wrap nolbr so=0

filetype indent off
set ai nosi pastetoggle=<F2>
au InsertLeave * set nopaste

filetype plugin on
let python_highlight_all = 1
syntax on

" Parse the entire file in order to correct syntax highlighting.
nnoremap <F7> :syntax sync fromstart<CR>

if s:is_NT
  color industry
  hi Visual ctermbg=53
else
  set t_Co=256
  if !empty(globpath(&rtp, 'colors/inkpot.vim'))
    let g:inkpot_black_background = 1
    color inkpot
    hi ErrorMsg ctermfg=white
  else
    color zellner
    hi Comment ctermfg=90
  endif
endif

set noshowmatch mps+=<:> " to include '<' and '>' in MatchParen

if v:version >= 700
  hi MatchParen ctermfg=white ctermbg=DarkCyan
  hi Pmenu ctermfg=253 ctermbg=238
  hi PmenuSbar ctermfg=253 ctermbg=211
  hi PmenuSel ctermfg=253 ctermbg=61
  hi PmenuThumb ctermfg=253 ctermbg=61
endif

set nu nuw=5
hi LineNr ctermfg=DarkGrey ctermbg=black

set ts=8
set sw=4
set expandtab
set sts=0 sta shiftround
set backspace=eol,start

if has('patch-8.2.0590')
set backspace=eol,nostop
endif

hi Tab ctermbg=232
match Tab /\t/

set listchars=extends:›,precedes:‹,trail:·,nbsp:˽,tab:↗↝
if has("patch-7.4.710") | set listchars+=space:· | endif

set ic smartcase
set wrapscan
set incsearch " enable /_CTRL-G and /_CTRL-T
set hlsearch
hi Search ctermfg=white ctermbg=DarkCyan
nnoremap <silent> <F3> :noh<CR>
nnoremap <silent> <S-F3> :set hls<CR>
vmap <F3> <Esc><F3>gv| imap <F3> <C-o><F3>
vmap <S-F3> <Esc><S-F3>gv| imap <S-F3> <C-o><S-F3>

" Recognize the sequence that PuTTY sends when you press <S-F3>.  The sequence
" was captured by typing <C-v><S-F3> in i-mode.
set <S-F3>=[25~

set iskeyword+=-

vnoremap <silent> <F4> y:let @/='\V'.substitute(@",'\','\\\\','g')<CR>
                        \:set hls<CR>

set noea lz notf
set nolz ttyfast " kill this line if the performance is of concern

set shortmess-=f
nnoremap <C-g> 2<C-g>

map Q @q
nmap Y y$

"Killing"
nmap <C-k> "_dd
vmap <C-k> "_d

" escape Help
map <F1> <Esc>
imap <F1> <Esc>

" Follow the Leader!
nnoremap <Leader>i i<Space><Esc>r
nmap <Leader>n <Leader>i<CR>
nnoremap <Leader>b :ls<CR>:buffer<Space>

vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

inoremap <C-j><C-j> <C-j>
inoremap <C-j>date <C-r>=strftime('%Y-%m-%d')<CR>
inoremap <C-j>time <C-r>=strftime('%H:%M:%S')<CR>
inoremap <C-j>isot <C-r>=strftime('%FT%T%z')<CR>
inoremap <C-j>uuid <C-r>=substitute(system("uuidgen"), '\n$', '', '')<CR>
inoremap <C-j>fn <C-r>=expand('%')<CR>
inoremap <C-j>fp <C-r>=expand('%:p')<CR>

runtime macros/matchit.vim

runtime! vimrc/*.vim

set dir=~/.vim/swap-files//

" no monkeying with system clipboard
set clipboard=

