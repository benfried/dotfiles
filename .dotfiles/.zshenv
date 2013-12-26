#emulate ksh
#for i in $fpath; do
#        for j in $(egrep -h "^function" $i/* | sort | uniq | awk '{print $2}'); do
#                autoload $j
#        done
#done
. ~/.envfile
#unfunction pushd popd
emulate zsh
