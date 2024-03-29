#!/usr/bin/env bash

set -e
set -f

cwd=`pwd -P`

set -x

ln -sT -f "$cwd/gitconfig" "${HOME}/.gitconfig"

  if grep -wiq microsoft /proc/sys/kernel/osrelease; then
    if [ -d ~/.vscode-server ]; then
ln -sT -f "$cwd/VSC_bashrc" "${HOME}/.bashrc"
    else
ln -sT -f "$cwd/inputrc" "${HOME}/.inputrc"
ln -sT -f "$cwd/WSL_bashrc" "${HOME}/.bashrc"
    fi
  else
ln -sT -f "$cwd/Base_bashrc" "${HOME}/.bashrc"
  fi

ln -sT -f "$cwd/vim" "${HOME}/.vim"
ln -sT -f "$cwd/vimrc" "${HOME}/.vimrc"

mkdir -p ~/.local/bin
cp -n -a "$cwd"/u.bin/. ~/.local/bin/

mkdir -p ~/.config/powershell
ln -s -f "$cwd"/profile.ps1 ~/.config/powershell/

