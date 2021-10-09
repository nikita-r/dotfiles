#!/usr/bin/env bash

set -e
set -f
set -x

ln -sf "$(pwd)/gitconfig" "${HOME}/.gitconfig"

ln -sf "$(pwd)/Base_bashrc" "${HOME}/.bashrc"

ln -sf -T "$(pwd)/vim" "${HOME}/.vim"
ln -sf "$(pwd)/vimrc" "${HOME}/.vimrc"

