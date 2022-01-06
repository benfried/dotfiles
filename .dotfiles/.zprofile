#
#	$Id: .profile,v 1.1 1995/04/10 21:44:45 dpk Exp $
#
# Default FID user .profile

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
export GOPATH=~/src/gocode/
export EDITOR=~/bin/emacsclient

BREW=/opt/homebrew/bin/brew
test -x ~/homebrew/bin/brew && BREW=~/homebrew/bin/brew

eval $(${BREW} shellenv)


fortune

##
# Your previous /Users/bf/.zprofile file was backed up as /Users/bf/.zprofile.macports-saved_2021-04-22_at_17:06:25
##

# MacPorts Installer addition on 2021-04-22_at_17:06:25: adding an appropriate DISPLAY variable for use with MacPorts.
export DISPLAY=:0
# Finished adapting your DISPLAY environment variable for use with MacPorts.

