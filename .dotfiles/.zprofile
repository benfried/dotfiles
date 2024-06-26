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
stty dec
append PATH /usr/games
prepend PATH /opt/local/bin
append MANPATH /opt/local/man
append MANPATH /usr/share/man
export GOPATH=~/src/gocode/
export EDITOR=~/bin/emacsclient

test -x /opt/homebrew/bin/brew && BREW=/opt/homebrew/bin/brew
test -x ~/homebrew/bin/brew && BREW=~/homebrew/bin/brew

test -n "${BREW}" && eval $(${BREW} shellenv)

# final change to PATH is to put ~/bin at the front, so can use it to override anything else
test -d ~/bin && prepend PATH ~/bin

eval $(keychain --eval --agents gpg --inherit any)

fortune

##
# Your previous /Users/bf/.zprofile file was backed up as /Users/bf/.zprofile.macports-saved_2021-04-22_at_17:06:25
##

# MacPorts Installer addition on 2021-04-22_at_17:06:25: adding an appropriate DISPLAY variable for use with MacPorts.
export DISPLAY=:0
# Finished adapting your DISPLAY environment variable for use with MacPorts.


# MacPorts Installer addition on 2022-03-16_at_13:02:53: adding an appropriate MANPATH variable for use with MacPorts.
prepend MANPATH /opt/local/share/man

# Finished adapting your MANPATH environment variable for use with MacPorts.

ech "leaving .zprofile"

# Added by OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
