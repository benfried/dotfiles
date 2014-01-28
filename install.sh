#!/bin/zsh


if [ ! -d .dotfiles ]; then
	echo 'install.sh must be run from root of dotfiles src tree' 1>&2
	exit 1
fi

pushd ~
da=$(date "+%Y%m%d%H%M.%S")

echo "backing up old dotfiles to $HOME/.dotfiles/${da}"

mkdir -p .dotfiles/${da} || { echo "error in mkdir"; exit 1 }
set -o extendedglob
cp -rp .[A-z]*~(.Trash|.dotfiles) .dotfiles/${da}/ || { echo "error copying files"; exit 1 }
rm -rf .[A-z]*~(.Trash|.dotfiles) || { echo "error deleting old dotfiles after backing up"; exit 1 }

popd

cd .dotfiles
ln -s ${PWD}/.[A-Za-z]* ~/

