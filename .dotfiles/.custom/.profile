# stty dec
stty erase '^?' intr '^c' kill '^u'
#function myappend { test -d $2 && eval $1=$PATH:$2; }
#function myprepend { test -d $2 && eval PATH=$2:$PATH; }

# export PAGER=~/bin/more METAMAIL_PAGER=~/"bin/more -r"
#prepend PATH ~/bin/@sys
prepend PATH ~/bin:/sbin:/usr/sbin:/usr/X11R6/bin
append PATH ~/android-sdk_38172_mac-x86/tools
export GOROOT=~/go
append PATH $GOROOT/bin
eval $(go env | grep -v TERM)
append PATH $GOPATH/bin
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
MAILPATH='/var/mail/bf?[You Have Mail]'
MAILCHECK=60
WHO=`who am i`

set +a

if [[ "${-#i*}" = "${-}" && "${-%i*}" = "${-}" ]]; then
    return 
fi

