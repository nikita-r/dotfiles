#!/usr/bin/env bash

set -e
set -f

cwd=`pwd -P`

set -x

ln -Tfs "$cwd/gitconfig" "${HOME}/.gitconfig"

ln -Tfs "$cwd/Base_bashrc" "${HOME}/.bashrc"

ln -Tfs "$cwd/vim" "${HOME}/.vim"
ln -Tfs "$cwd/vimrc" "${HOME}/.vimrc"

