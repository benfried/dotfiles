# stty dec
stty erase '^?' intr '^c' kill '^u'
# echo "entering .custom/.profile"
#function myappend { test -d $2 && eval $1=$PATH:$2; }
#function myprepend { test -d $2 && eval PATH=$2:$PATH; }

# export PAGER=~/bin/more METAMAIL_PAGER=~/"bin/more -r"
#prepend PATH ~/bin/@sys
echo $PATH | tr ':' '\n' | grep -q sbin || prepend PATH ~/bin:/sbin:/usr/sbin:/usr/X11R6/bin
export GOROOT=~/go
append PATH $GOROOT/bin
test -x $GOROOT/bin/go && eval $(go env | grep -v TERM)
append PATH $GOPATH/bin
append PATH ~/src/flutter/bin
# module load dev
set -a
HISTSIZE=1000
#HISTFILE=/tmp/.histfile.ben.${HOST}.$$
HISTFILE=/tmp/.histfile.ben.${HOST}
FCEDIT='/usr/ucb/vi'
EXINIT='set aw ic sm sw=4'
#LESS='-Mir'
LESS='-MiR'
MORE='-MiR'
MAILPATH="/var/mail/${USER}?[You Have Mail]"
MAILCHECK=60
WHO=`who am i`

set +a
# echo "leaving .custom/.profile"


if [[ "${-#i*}" = "${-}" && "${-%i*}" = "${-}" ]]; then
    return 
fi

