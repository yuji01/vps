#! /bin/bash

src_dir="/docker/"
# 备份设置
backup_path="/backup/$1"
backup_name=`date  +"%Y-%m-%d_%H.%M.%S"`
onedrive_path="/backup-vps/$1"

feishu_url="https://open.feishu.cn/open-apis/bot/v2/hook/741a60c0-78ee-4d49-bb14-db4296595a6b"
success_info(){
curl -i -k  -H "Content-type: application/json" -X POST -d '{"msg_type":"'"text"'","content":{"text":"'"$1 备份成功！"'"}}' $feishu_url >/dev/null 2>&1
}
error_info(){
curl -i -k  -H "Content-type: application/json" -X POST -d '{"msg_type":"'"text"'","content":{"text":"'"$1 备份失败！"'"}}' $feishu_url >/dev/null 2>&1
}
[ -d onedrive_path ] || { error_info ; exit 1 }
# 创建备份文件
[ -d $backup_path ] || mkdir $backup_path -p
# 删除7天前的文件
find $backup_path/* -type f -mtime +7 -exec sh rm -rf {} \;
tar -zcf ${backup_path}/${backup_name}.tar.gz -C $src_dir $1

# 复制备份文件到onerive
[ -d onedrive_path ] || mkdir $onedrive_path -p
cp ${backup_path}/${backup_name}.tar.gz $onedrive_path/
# 删除本机的备份文件
if [ -e $onedrive_path/${backup_name}.tar.gz ];then
    rm ${backup_path}/${backup_name}.tar.gz && success_info
else
    error_info
fi
