#!/usr/bin/env bash

REPO_PATH="$(dirname $(cd "$(dirname "$0")" > /dev/null 2>&1; pwd -P))"

set -x
set -e

case "$(uname -sr)" in
	Darwin*)
		PLATFORM='darwin'
		;;
	Linux*icrosoft*)
		PLATFORM='wsl'
		echo "Do not support $(uname -sr)." && exit 1
		;;
	Linux*)
		PLATFORM='linux'
		;;
	*BSD*)
		PLATFORM='bsd'
		;;
	*)
		echo "Do not support $(uname -sr)." && exit 1
		;;
esac

# Links to my profiles.
cd
touch .hushlogin

if type zsh &> /dev/null; then
	# Essential zsh plugins.
	git clone https://github.com/sindresorhus/pure.git ~/.zsh/pure
	git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
	git clone https://github.com/agkozak/zsh-z ~/.zsh/zsh-z

	ln -s $REPO_PATH/rc/profile .zshrc
	ln -s $REPO_PATH/rc/profile .bashrc
	chsh -s $(which zsh)
else
	ln -s $REPO_PATH/rc/profile .bashrc
fi

ln -s $REPO_PATH/rc/writing-quotes .writing-quotes
ln -s $REPO_PATH/rc/vimrc .vimrc
if type nvim &> /dev/null; then
	mkdir -p .config/nvim
	ln -s $REPO_PATH/rc/vimrc .config/nvim/init.vim
fi

# Essential `vim` plugins.
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

if type nvim &> /dev/null; then
	nvim --headless +PluginInstall +qall 2> /dev/null
elif type vim &> /dev/null; then
	vim +PluginInstall +qall
fi
