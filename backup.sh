#! /bin/bash

backup(){
    # 备份文件的路径
    backup_path="/backup/$file"
    [ -d $backup_path ] || mkdir $backup_path -p
    # 删除7天前的文件
    find $backup_path/* -type f -mtime +7 -exec rm -rf {}\;
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

file="bitwarden" && backup && copyfile
file="freenom" && backup && copyfile
