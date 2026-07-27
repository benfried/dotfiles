# Setting PATH for MacPython 2.5
# The orginal version is saved in .profile.pysave
# Sat Jul 23 18:42:43 EDT 2022 Apparently not used by zsh
# NB: this file IS used by bash, which is the default login shell on Linux
# hosts, so the macOS-only paths below are guarded on existence.
test -d "/Library/Frameworks/Python.framework/Versions/Current/bin" && \
    PATH="/Library/Frameworks/Python.framework/Versions/Current/bin:${PATH}"
GOROOT=~/go
GOPATH=~/gocode
test -d /opt/local/bin && PATH=/opt/local/bin:$PATH
PATH=$PATH:$GOROOT/bin
export PATH GOROOT GOPATH
test -f "$HOME/.cargo/env" && . "$HOME/.cargo/env"


# Added by Antigravity CLI installer
export PATH="$HOME/.local/bin:$PATH"
