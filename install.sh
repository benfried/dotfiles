#!/bin/zsh

if [ ! -d .dotfiles ]; then
	echo 'install.sh must be run from root of dotfiles src tree' 1>&2
	exit 1
fi

# Remember where we started: this script cds into .dotfiles and then ~/src, so
# later steps cannot reach sibling scripts by relative path.
DOTFILES_SRC=${PWD}

# Check prerequisites BEFORE the backup below, which deletes the home dotfiles
# it is about to replace. A failure after that point leaves a stripped home
# directory, so anything fatal has to be caught here.
missing=()
for c in git; do
    command -v $c >/dev/null 2>&1 || missing+=($c)
done
if (( ${#missing} )); then
    echo "install.sh: required command(s) not found: ${missing}" 1>&2
    echo "           install them and re-run." 1>&2
    exit 1
fi

# Not fatal: these are used by the configs this installs, not by this script.
# Without them logins still work, they just emit errors.
soft_missing=()
for c in tmux fortune keychain; do
    command -v $c >/dev/null 2>&1 || soft_missing+=($c)
done
if (( ${#soft_missing} )); then
    echo "install.sh: note -- not installed: ${soft_missing}"
    echo "           the shell configs reference these; logins will complain until they exist."
fi

pushd ~
da=$(date "+%Y%m%d%H%M.%S")

echo "backing up old dotfiles to $HOME/.dotfiles/${da}"

mkdir -p .dotfiles/${da} || { echo "error in mkdir"; exit 1 }
set -o extendedglob
# .ssh is excluded deliberately -- see the ~/.ssh section below. Deleting it
# here would take authorized_keys with it, which on a cloud VM is machine-owned
# rather than ours.
cp -rp .[A-Za-z]*~(.Trash|.dotfiles|.ssh) .dotfiles/${da}/ || { echo "error copying files"; exit 1 }
rm -rf .[A-Za-z]*~(.Trash|.dotfiles|.ssh) || { echo "error deleting old dotfiles after backing up"; exit 1 }

popd

if [ ! -d ~/lib ]; then
    cp -rp lib ~/ || exit 2
fi

cd .dotfiles

# Everything except .ssh gets symlinked wholesale. No parentheses around the
# ~ exclusion: with a single alternative zsh reads (.ssh) as glob qualifiers
# rather than a pattern group, and dies with "unknown file attribute".
for f in .[A-Za-z]*~.ssh; do
    ln -sfn "${PWD}/$f" ~/ || echo "warning: could not link $f"
done

# ~/.ssh is handled per-file rather than symlinked as a directory.
#
# On a GCE VM the google-guest-agent rewrites ~/.ssh/authorized_keys from
# instance metadata. If ~/.ssh pointed into this repo, that machine-owned file
# would land in the git tree -- and sshd runs StrictModes, so every parent
# directory of the repo would then have to satisfy its permission checks or key
# auth breaks entirely. Private keys and authorized_keys therefore stay local to
# the machine, and only the two non-secret files are linked out of the repo.
if [ -L ~/.ssh ]; then
    echo
    echo "WARNING: ~/.ssh is a symlink to $(readlink ~/.ssh) -- the old layout."
    echo "         Leaving it as-is: migrating automatically would relocate private"
    echo "         key material, which should be a deliberate act. To migrate:"
    echo "             mv ~/.ssh ~/.ssh.link && mkdir -m 700 ~/.ssh"
    echo "             cp \$(readlink ~/.ssh.link)/id_* ~/.ssh/ 2>/dev/null"
    echo "             cp \$(readlink ~/.ssh.link)/google_compute_engine* ~/.ssh/ 2>/dev/null"
    echo "             rm ~/.ssh.link && ./install.sh"
    echo
else
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    ln -sfn "${PWD}/.ssh/config" ~/.ssh/config
    ln -sfn "${PWD}/.ssh/known_hosts" ~/.ssh/known_hosts
fi

# git records no directory modes and only the executable bit on files, so a
# fresh clone yields 755 dirs and 644 files. ssh refuses to use a private key
# that is group- or world-readable. Strip group/world bits: 644 -> 600,
# 755 -> 700.
chmod 700 "${PWD}/.ssh"
chmod -R go-rwx "${PWD}/.ssh"

if [ "$(uname)" = "Darwin" ]; then
    ln -sfn ~/.tmux.conf.mac ~/.tmux.conf
    echo "Don't forget to run brew bundle install ~/src/dotfiles/Brewfile"
else
    ln -sfn ~/.tmux.conf.non-mac ~/.tmux.conf
fi


if [ ! -d ~/src ]; then
	mkdir ~/src || exit 2
fi

cd ~/src

if [ ! -d oh-my-zsh ]; then
    git clone https://github.com/robbyrussell/oh-my-zsh.git
else
    cd oh-my-zsh
    git pull
    cd ..
fi

# Register this machine's SSH key with the GCP VMs. On a fresh install gcloud is
# usually not yet installed or authenticated, so this normally just prints what
# to do later -- it is deliberately non-fatal, since a dotfiles install must not
# fail over an optional cloud step.
if [ -x ${DOTFILES_SRC}/setup-gcp-ssh.sh ]; then
    echo
    ${DOTFILES_SRC}/setup-gcp-ssh.sh || echo "setup-gcp-ssh.sh failed; continuing anyway"
fi


