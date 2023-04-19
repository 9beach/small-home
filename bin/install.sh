#!/usr/bin/env bash

REPO_PATH="$(dirname $(cd "$(dirname "$0")" > /dev/null 2>&1; pwd -P))"

set -x
set -e

if [ $CP = 'yes' ]; then
	LN='cp'
else
	LN='ln -s'
fi

BACKUP_DIR=~/Downloads/home-backup.$(basename $(mktemp))
mkdir -p "$BACKUP_DIR"

function backup() {
	mv "$@" "$BACKUP_DIR" 2> /dev/null || true
}

case "$(uname -sr)" in
	Darwin*)
		PLATFORM='darwin'
		;;
	Linux*icrosoft*)
		PLATFORM='wsl'
		;;
	Linux*)
		PLATFORM='linux'
		;;
	*BSD*)
		PLATFORM='bsd'
		;;
	CYGWIN*|MINGW*|MINGW32*|MSYS*)
		PLATFORM='windows'
		;;
	*)
		echo "Do not support $(uname -sr)." && exit 1
		;;
esac

# Links to my profiles.
cd
touch ~/.hushlogin

if type zsh &> /dev/null; then
	# Essential zsh plugins.
	if ! [ -d ~/.zsh/pure ]; then
		git clone https://github.com/sindresorhus/pure.git ~/.zsh/pure
	fi
	if ! [ -d ~/.zsh/zsh-autosuggestions ]; then
		git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
	fi
	if ! [ -d ~/.zsh/zsh-z ]; then
		git clone https://github.com/agkozak/zsh-z ~/.zsh/zsh-z
	fi

	backup ~/.zshrc ~/.bashrc

	$LN $REPO_PATH/rc/profile ~/.zshrc
	$LN $REPO_PATH/rc/profile ~/.bashrc

	if ! [[ $SHELL =~ .*zsh ]]; then
		chsh -s $(which zsh)
	fi
else
	backup ~/.bashrc
	$LN $REPO_PATH/rc/profile ~/.bashrc
fi

backup ~/.writing-quotes ~/.vimrc
$LN $REPO_PATH/rc/writing-quotes ~/.writing-quotes
$LN $REPO_PATH/rc/vimrc ~/.vimrc

# Essential `vim` plugins.
if ! [ -d ~/.vim/bundle/Vundle.vim ]; then
	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

if type nvim &> /dev/null; then
	mkdir -p .config/nvim
	backup ~/.config/nvim/init.vim
	$LN $REPO_PATH/rc/vimrc ~/.config/nvim/init.vim

	nvim --headless +PluginInstall +qall 2> /dev/null
elif type vim &> /dev/null; then
	vim +PluginInstall +qall
fi

echo 'Install completed. Please logout and login again.'
