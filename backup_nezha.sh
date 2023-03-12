#! /bin/bash
# 哪吒备份
src_dir="/opt/"
# 备份设置
backup_path="/backup/nezha"
backup_name=`date  +"%Y-%m-%d_%H.%M.%S"`
onedrive_path="/backup-vps/nezha"
# 通知设置
feishu_url="https://open.feishu.cn/open-apis/bot/v2/hook/741a60c0-78ee-4d49-bb14-db4296595a6b"
backup_file=nezha
success_info(){
curl -i -k  -H "Content-type: application/json" -X POST -d '{"msg_type":"'"text"'","content":{"text":"'"$backup_file 备份成功！"'"}}' $feishu_url >/dev/null 2>&1
}
error_info(){
curl -i -k  -H "Content-type: application/json" -X POST -d '{"msg_type":"'"text"'","content":{"text":"'"$backup_file 备份失败！"'"}}' $feishu_url >/dev/null 2>&1
}

if [ ! -d $onedrive_path ] ;then
    error_info && exit 1
fi

# 创建备份文件
[ -d $backup_path ] || mkdir $backup_path -p

tar -zcf ${backup_path}/${backup_name}.tar.gz -C $src_dir nezha
# 复制备份文件到onerive
[ -d $onedrive_path ] || mkdir $onedrive_path -p
cp ${backup_path}/${backup_name}.tar.gz $onedrive_path/
# 删除本机的备份文件
if [ -e $onedrive_path/${backup_name}.tar.gz ]; then
    rm ${backup_path}/${backup_name}.tar.gz && success_info
else
    error_info
fi
