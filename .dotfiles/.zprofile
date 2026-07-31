#
#	$Id: .profile,v 1.1 1995/04/10 21:44:45 dpk Exp $
#
# Default FID user .profile

alias ech=echo
alias ech=true
ech "entering .zprofile"

set +a
loginshell=1
SH_LEVEL=0
export ENV=$HOME/.envfile
export HOST
. ~/.custom/append
. ~/.custom/.profile
. ~/.zshfuncs
# The shell will now run .envfile.
# Only when there is a terminal to configure: `ssh host cmd` runs this file with
# no tty, and stty then prints "Inappropriate ioctl for device" on every call.
test -t 0 && stty dec
append PATH /usr/games
test -d /opt/local/bin && prepend PATH /opt/local/bin
# MANPATH is only extended for directories that actually exist -- and the
# trailing colon below matters: without it, setting MANPATH at all REPLACES the
# system search path from /etc/manpath.config instead of adding to it, which
# makes every system man page vanish.
test -d /opt/local/man && append MANPATH /opt/local/man
test -d /usr/share/man && append MANPATH /usr/share/man
export GOPATH=~/src/gocode/
# ~/bin/emacsclient is a macOS-only wrapper here; fall back to whatever exists.
if [ -x ~/bin/emacsclient ]; then
    export EDITOR=~/bin/emacsclient
elif command -v emacsclient >/dev/null 2>&1; then
    export EDITOR=$(command -v emacsclient)
elif command -v vi >/dev/null 2>&1; then
    export EDITOR=$(command -v vi)
fi

test -x /opt/homebrew/bin/brew && BREW=/opt/homebrew/bin/brew
test -x ~/homebrew/bin/brew && BREW=~/homebrew/bin/brew

test -n "${BREW}" && eval $(${BREW} shellenv)

# final change to PATH is to put ~/bin at the front, so can use it to override anything else
test -d ~/bin && prepend PATH ~/bin

# Both are optional extras; without guards they print "command not found" on
# every single login on a host where they are not installed.
command -v keychain >/dev/null 2>&1 && eval $(keychain --eval)

command -v fortune >/dev/null 2>&1 && fortune

##
# Your previous /Users/bf/.zprofile file was backed up as /Users/bf/.zprofile.macports-saved_2021-04-22_at_17:06:25
##

# MacPorts Installer addition on 2021-04-22_at_17:06:25: adding an appropriate DISPLAY variable for use with MacPorts.
# Never clobber an existing DISPLAY: over ssh -X the server sets it to something
# like localhost:10.0, and overwriting that silently breaks X11 forwarding.
if [ -z "${DISPLAY}" ] && [ "$(uname)" = "Darwin" ]; then
    export DISPLAY=:0
fi
# Finished adapting your DISPLAY environment variable for use with MacPorts.


# MacPorts Installer addition on 2022-03-16_at_13:02:53: adding an appropriate MANPATH variable for use with MacPorts.
test -d /opt/local/share/man && prepend MANPATH /opt/local/share/man
test -d /opt/homebrew/share/man && prepend MANPATH /opt/homebrew/share/man
# Finished adapting your MANPATH environment variable for use with MacPorts.

# Trailing colon = "and also the system default manpath". Without it man
# searches ONLY the entries above. See the MANPATH note earlier in this file.
test -n "${MANPATH}" && export MANPATH="${MANPATH}:"

ech "leaving .zprofile"

# Added by OrbStack: command-line tools and integration
test -f ~/.orbstack/shell/init.zsh && source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# Added by Antigravity CLI installer
export PATH="$HOME/.local/bin:$PATH"
