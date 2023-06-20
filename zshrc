
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

bindkey '^N' history-search-forward
bindkey '^P' history-search-backward

WORDCHARS=${WORDCHARS/\/}
export EDITOR=vim

