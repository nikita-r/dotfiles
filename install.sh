#!/usr/bin/env bash

set -e
set -f
set -x

ln -sf "$(pwd)/gitconfig" "${HOME}/.gitconfig"
ln -sf "$(pwd)/vimrc" "${HOME}/.vimrc"
ln -sf "$(pwd)/vim" "${HOME}/.vim"

