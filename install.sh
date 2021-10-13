#!/usr/bin/env bash

set -e
set -f

cwd=`pwd -P`

set -x

ln -sT -f "$cwd/gitconfig" "${HOME}/.gitconfig"

ln -sT -f "$cwd/Base_bashrc" "${HOME}/.bashrc"

ln -sT -f "$cwd/vim" "${HOME}/.vim"
ln -sT -f "$cwd/vimrc" "${HOME}/.vimrc"

mkdir -p ~/.local/bin
cp -n -a "$cwd"/u.bin/. ~/.local/bin/

mkdir -p ~/.config/powershell
ln -s -f "$cwd"/profile.ps1 ~/.config/powershell/

