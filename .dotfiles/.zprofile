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
fortune
