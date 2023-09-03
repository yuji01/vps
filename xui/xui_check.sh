#! /bin/bash
# 作用：检查xui是否还能登录

# 路径
xui=xui.txt

# 文件内容如下格式，不要有反斜杠
# https://38.59.245.128:54321
# https://38.59.238.43:54321

DIR=./xui_check/

mkdir $DIR 2>&1
rm -rf ${DIR}/successd.log ${DIR}/failed.log > /dev/null 2>&1

for i in $(sed -n "p" $xui) ;do
    res=$(curl --request POST --data 'username=admin&password=admin' --insecure --max-time 3 "${i}/login" )
    if [[ "$res" =~ .*true.* ]]; then
       echo $i >> ${DIR}/succeed.log
    else
       echo $i >> ${DIR}/failed.log
    fi
done
