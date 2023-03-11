#! /bin/bash

backup(){
    # 备份文件的路径
    backup_path="/backup/$file"
    [ -d $backup_path ] || mkdir $backup_path -p
    # 删除7天前的文件
    find $backup_path/* -type f -mtime +7 -exec sh rm -rf {} \;
    # 源文件的路径
    dir="/docker/"
    # 备份文件的命名
    name=`date  +"%Y-%m-%d_%H.%M.%S"`
    tar -zcf ${backup_path}/${name}.tar.gz -C $dir $file
}


copyfile(){
    # OneDrive储存路径
    cloud_dir="/backup-vps/$file"
    [ -d $cloud_dir ] || mkdir $cloud_dir -p
    cp ${backup_path}/* $cloud_dir/ -r
}
notification_feishu(){
    feishu_url="https://open.feishu.cn/open-apis/bot/v2/hook/741a60c0-78ee-4d49-bb14-xxxx"
    if [ $? -eq 0 ];then
curl -i -k  -H "Content-type: application/json" -X POST -d '{"msg_type":"'"text"'","content":{"text":"'"$file 备份成功！"'"}}' $feishu_url >/dev/null 2>&1
    else
curl -i -k  -H "Content-type: application/json" -X POST -d '{"msg_type":"'"text"'","content":{"text":"'"$file 备份失败！"'"}}' $feishu_url >/dev/null 2>&1
    fi
}
file="bitwarden" && backup && copyfile
notification_feishu
file="freenom" && backup && copyfile
notification_feishu
