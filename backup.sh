#! /bin/bash

backup(){
    backup_path="/backup/$file"
    [ -d $backup_path ] || mkdir $backup_path -p
    dir="/docker/"
    name=`date  +"%Y-%m-%d_%H.%M.%S"`
    tar -zcf ${backup_path}/${name}.tar.gz -C $dir $file
}
file="bitwarden" && backup
file="freenom" && backup
