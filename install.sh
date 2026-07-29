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
# .ssh and .config are excluded deliberately -- see their sections below. Both
# are directories other software owns and writes to: .ssh holds authorized_keys,
# which on a cloud VM is machine-owned, and .config holds live state for a large
# number of unrelated applications. Only named files inside them are linked.
cp -rp .[A-Za-z]*~(.Trash|.dotfiles|.ssh|.config) .dotfiles/${da}/ || { echo "error copying files"; exit 1 }
rm -rf .[A-Za-z]*~(.Trash|.dotfiles|.ssh|.config) || { echo "error deleting old dotfiles after backing up"; exit 1 }

popd

if [ ! -d ~/lib ]; then
    cp -rp lib ~/ || exit 2
fi

cd .dotfiles

# Everything except .ssh and .config gets symlinked wholesale.
for f in .[A-Za-z]*~(.ssh|.config); do
    ln -sfn "${PWD}/$f" ~/ || echo "warning: could not link $f"
done

# ~/.config, like ~/.ssh, is a directory owned by other software -- symlinking
# the whole thing into this repo would drag every application's state in with
# it. Create the directories for real and link only the files we manage.
for rel in ghostty/config; do
    if [ -f "${PWD}/.config/${rel}" ]; then
        mkdir -p ~/.config/"$(dirname "$rel")"
        ln -sfn "${PWD}/.config/${rel}" ~/.config/"${rel}"
    fi
done

# Ghostty ships its terminfo only inside its own app bundle, so a host you ssh
# INTO does not know TERM=xterm-ghostty and curses programs break outright.
# Ghostty's ssh-terminfo shell integration handles the common case, but not a
# tmux session that outlives the ssh which seeded it, a root shell after
# sudo -i, or a connection from some other client -- so install it here too.
# Skipped where the entry already resolves, which includes the Mac running
# Ghostty itself.
if command -v tic >/dev/null 2>&1 && ! infocmp xterm-ghostty >/dev/null 2>&1; then
    if tic -x -o ~/.terminfo "${DOTFILES_SRC}/terminfo/xterm-ghostty.terminfo" 2>/dev/null; then
        echo "installed xterm-ghostty terminfo into ~/.terminfo"
    else
        echo "warning: could not install xterm-ghostty terminfo" 1>&2
    fi
fi

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
    # The public half of the GCP key is committed, so link it alongside the
    # private half that lives on the machine. Without this, setup-gcp-ssh.sh
    # finds a key with no .pub and refuses to proceed. Guarded rather than
    # unconditional: ln -sfn to a missing source yields a dangling link, and
    # -f on a dangling link is false, which reads as "no .pub" anyway.
    if [ -f "${PWD}/.ssh/google_compute_engine.pub" ]; then
        ln -sfn "${PWD}/.ssh/google_compute_engine.pub" ~/.ssh/google_compute_engine.pub
    fi
fi

# git records no directory modes and only the executable bit on files, so a
# fresh clone yields 755 dirs and 644 files. ssh refuses to use a private key
# that is group- or world-readable. Strip group/world bits: 644 -> 600,
# 755 -> 700.
chmod 700 "${PWD}/.ssh"
chmod -R go-rwx "${PWD}/.ssh"

if [ "$(uname)" = "Darwin" ]; then
    ln -sfn ~/.tmux.conf.mac ~/.tmux.conf
    echo "Don't forget to run: brew bundle install --file=${DOTFILES_SRC}/Brewfile"
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


