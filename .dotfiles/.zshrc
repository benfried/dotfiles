alias ech=echo
alias ech=true
ech "entering .zshrc"
emulate zsh
. ~/.zshnew
export ZSH=$HOME/src/oh-my-zsh
plugins=(brew flutter git golang iterm2 macos macports pip pipenv)
source $ZSH/oh-my-zsh.sh
setenv () {
        eval "$1=\"$2\""
        export $1
}
# my long-term prompt is below
PS1='%B%m%(!.%F{yellow}#%f.$)%b '
# have prompt include current conda env (in blue) if it is set and not
# the base PS1='%B%m${CONDA_DEFAULT_ENV:+
# ${bs}($CONDA_DEFAULT_ENV)%f}%(!.%F{yellow}#%f.$)%b ' logic: turn on
# bold. first part of prompt is hostname. Second, if CONDA_DEFAULT_ENV
# is set and not base, add it, in blue, to the prompt; then end the
# blue sequence. Next, the prompt care is either '#' if we are root or
# '$' if not. Then turn off bold and add a space.
bs='%F{blue}'
PS1='%B%m${${CONDA_DEFAULT_ENV:#base}:+ ${bs}($CONDA_DEFAULT_ENV)%f}%(!.%F{yellow}#%f.$)%b '
bindkey "?" list-choices
set -X -9 -k
setopt nobgnice
setopt noallexport
setopt correct_all
setopt no_hist_ignore_dups
setopt interactive_comments
setopt long_list_jobs
setopt multios
setopt print_exit_value
setopt pushd_ignore_dups
setopt pushd_to_home
setopt nonomatch
export WORDCHARS='*_-[]~=;!#$%^(){}<>'
#for i in $fpath; do
#    if [ "${i%%zsh*}" =  "$i" ]; then
#	$nfpath = "$i $nfpath"
#    fi
#done
#for i in $fpath; do
#	for j in $(egrep -h "^function" $i/* | sort | uniq | awk '{print $2}'); do
#		autoload $j
#	done
#done

if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
    test -e ${HOME}/.iterm2_shell_integration.zsh && source ${HOME}/.iterm2_shell_integration.zsh
fi

test ! -z "${-:#*i*}" && return

# echo "got here in .zshrc"

compctl -z -P '%' bg
compctl -j -P '%' fg jobs disown
compctl -j -P '%' + -s '`ps -x | tail +2 | cut -c1-5`' wait
compctl -A shift
compctl -caF type whence which
compctl -c unhash
compctl -x 'w[1,-d] p[2]' -n - 'w[1,-d] p[3]' -g '*(-/)' - \
	'p[1]' -c - 'p[2]' -g '*(-x)' -- hash
compctl -F functions unfunction
compctl -a unalias
compctl -v getln getopts read unset vared
compctl -b bindkey
compctl -x 'C[-1,-*e]' -c - 'C[-1,-[ARWI]##]' -f -- fc
compctl -x 'p[1]' - 'p[2,-1]' -l '' -- sched
compctl -x 'C[-1,[+-]o]' -o - 'c[-1,-A]' -A -- set
compctl -l '' nohup noglob exec nice eval - time rusage
compctl -l '' -x 'p[1]' -eB -- builtin
compctl -l '' -x 'p[1]' -em -- command
compctl -x 'p[1]' -c - 'p[2,-1]' -k signals -- trap
compctl -j -P '%' + -s '`ps -x | tail +2 | cut -c1-5`' + \
	-x 's[-] p[1]' -k "($signals[1,-3])" -- kill
#------------------------------------------------------------------------------
compctl -s "\$(awk '/^[a-zA-Z0-9][^ 	]+:/ {print \$1}' FS=: [mM]akefile)" -x \
	'c[-1,-f]' -f -- make gmake
compctl -f -x 'C[-1,*f*] p[2]' -g "*.tar" -- tar
#------------------------------------------------------------------------------
# rmdir only real directories
compctl -g '*(/)' rmdir dircmp
compctl -g '*.tex*' + -g '*(-/)' {,la,gla,ams{la,},{g,}sli}tex texi2dvi
compctl -g '*.dvi' + -g '*(-/)' xdvi dvips
# For rcs users, co and rlog from the RCS directory.  We don't want to see
# the RCS and ,v though.
compctl -g 'RCS/*(:s@RCS/@@:s/,v//)' co rlog rcs rcsdiff
# gzip uncompressed files, but gzip -d only gzipped or compressed files
compctl -x 'R[-*[dt],^*]' -g '*.(gz|z|Z|t[agp]z|tarZ|tz)' + -g '*(-/)' + -f - \
    's[]' -g '^*(.(tz|gz|t[agp]z|tarZ|zip|ZIP|jpg|JPG|gif|GIF|[zZ])|[~#])' \
    + -f -- gzip
compctl -g '*.(gz|z|Z|t[agp]z|tarZ|tz)' + -g '*(-/)' gunzip # zcat if you use GNU
compctl -g '*.(Z|gz)' + -g '*(-/)' uncompress zmore zcat zgrep
compctl -x 'r[-exec,;][-ok,;]' -l '' - \
's[-]' -s 'daystart {max,min,}depth follow noleaf version xdev \
	{a,c,}newer {a,c,m}{min,time} empty false {fs,x,}type gid inum links \
	{i,}{l,}name {no,}{user,group} path perm regex size true uid used \
	exec {f,}print{f,0,} ok prune ls' - \
'p[1]' -g '. .. *(-/)' - \
'C[-1,-((a|c|)newer|fprint(|0|f))]' -f - \
'c[-1,-fstype]' -k '(ufs 4.2 4.3 nfs tmp mfs S51K S52K)' - \
'c[-1,-group]' -k groups - \
'c[-1,-user]' -u -- find
compctl -g "*.[cCoa]" -x 's[-I]' -g "*(/)" - \
	's[-l]' -s '${(s.:.)^LD_LIBRARY_PATH}/lib*.a(:t:r:s/lib//)' -- cc
compctl -g '*.([cCmisSoa]|cc|cxx|ii)' -x \
	's[-l]' -s '${(s.:.)^LD_LIBRARY_PATH}/lib*.a(:t:r:s/lib//)' - \
	'c[-1,-x]' -k '(none c objective-c c-header c++ cpp-output assembler assembler-with-cpp)' - \
	'c[-1,-o]' -f - \
	'C[-1,-i(nclude|macros)]' -g '*.h' - \
	'C[-1,-i(dirafter|prefix)]' -g '*(-/)' - \
	's[-B][-I][-L]' -g '*(-/)' - \
	's[-fno-],s[-f]' -k '(all-virtual cond-mismatch dollars-in-identifiers enum-int-equiv external-templates asm builtin strict-prototype signed-bitfields signd-char this-is-variable unsigned-bitfields unsigned-char writable-strings syntax-only pretend-float caller-saves cse-follow-jumps cse-skip-blocks delayed-branch elide-constructors expensive-optimizations fast-math float-store force-addr force-mem inline-functions keep-inline-functions memoize-lookups default-inline defer-pop function-cse inline peephole omit-frame-pointer rerun-cse-after-loop schedule-insns schedule-insns2 strength-reduce thread-jumps unroll-all-loops unroll-loops)' - \
	's[-g]' -k '(coff xcoff xcoff+ dwarf dwarf+ stabs stabs+ gdb)' - \
	's[-mno-][-mno][-m]' -k '(486 soft-float fp-ret-in-387)' - \
	's[-Wno-][-W]' -k '(all aggregate-return cast-align cast-qual char-subscript comment conversion enum-clash error format id-clash-6 implicit inline missing-prototypes missing-declarations nested-externs import parentheses pointer-arith redundant-decls return-type shadow strict-prototypes switch template-debugging traditional trigraphs uninitialized unused write-strings)' - \
	's[-]' -k '(pipe ansi traditional traditional-cpp trigraphs pedantic pedantic-errors nostartfiles nostdlib static shared symbolic include imacros idirafter iprefix iwithprefix nostdinc nostdinc++ undef)' -X 'Use "-f", "-g", "-m" or "-W" for more options' -- gcc g++
Xcolours() {
  reply=( ${(L)=:-$(awk '{ if (NF = 4) print $4 }' < /usr/lib/X11/rgb.txt)} )
}
Xcursor() {
  reply=( $(sed -n 's/^#define[	 ][ 	]*XC_\([^ 	]*\)[ 	].*$/\1/p' \
	  < /usr/include/X11/cursorfont.h) )
}
compctl -k '(-help -def -display -cursor -cursor_name -bitmap -mod -fg -bg
   -grey -rv -solid -name)' -x 'c[-1,-display]' -k hosts -S ':0.0' - \
   'c[-1,-cursor]' -f -  'c[-2,-cursor]' -f - \
   'c[-1,-bitmap]' -g '/usr/include/X11/bitmaps/*' - \
   'c[-1,-cursor_name]' -K Xcursor - \
   'C[-1,-(solid|fg|bg)]' -K Xcolours -- xsetroot

compctl -k '(if of conv ibs obs bs cbs files skip file seek count)' \
	-S '=' -x 's[if=], s[of=]' -f - 'C[0,conv=*,*] n[-1,,], s[conv=]' \
	-k '(ascii ebcdic ibm block unblock lcase ucase swap noerror sync)' \
	-q -S ',' - 'n[-1,=]' -X '<number>'  -- dd

if test -d $HOME/miniforge3; then
    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    __conda_setup="$(${HOME}'/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
	eval "$__conda_setup"
    else
	if [ -f "${HOME}/miniforge3/etc/profile.d/conda.sh" ]; then
	    . "${HOME}/miniforge3/etc/profile.d/conda.sh"
	else
	    export PATH="${HOME}/miniforge3/bin:$PATH"
	fi
    fi
    unset __conda_setup
    # <<< conda initialize <<<
fi

export PS1='%B%m${${CONDA_DEFAULT_ENV:#base}:+ ${bs}($CONDA_DEFAULT_ENV)%f}%(!.%F{yellow}#%f.$)%b '
ech "leaving .zshrc"
