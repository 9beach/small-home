#!/usr/bin/env bash

REPO_PATH="$(dirname $(cd "$(dirname "$0")" > /dev/null 2>&1; pwd -P))"

set -x
set -e

if [ $CP = 'yes' ]; then
	LN='cp -f'
else
	LN='ln -sf'
fi

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

if [ -n "$ZSH_VERSION" ]; then
	# Essential zsh plugins.
	rm -rf ~/.zsh/pure
	git clone https://github.com/sindresorhus/pure.git ~/.zsh/pure
	rm -rf ~/.zsh/zsh-autosuggestions
	git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
	rm -rf ~/.zsh/zsh-z
	git clone https://github.com/agkozak/zsh-z ~/.zsh/zsh-z

	$LN $REPO_PATH/rc/profile ~/.zshrc
	$LN $REPO_PATH/rc/profile ~/.bashrc
	chsh -s $(which zsh)
else
	$LN $REPO_PATH/rc/profile ~/.bashrc
fi

$LN $REPO_PATH/rc/writing-quotes ~/.writing-quotes
$LN $REPO_PATH/rc/vimrc .vimrc
if type nvim &> /dev/null; then
	mkdir -p .config/nvim
	$LN $REPO_PATH/rc/vimrc ~/.config/nvim/init.vim
fi

# Essential `vim` plugins.
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

if type nvim &> /dev/null; then
	nvim --headless +PluginInstall +qall 2> /dev/null
elif type vim &> /dev/null; then
	vim +PluginInstall +qall
fi

echo 'Install completed. Please logout and login again.'
