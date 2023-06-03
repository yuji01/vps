#!/bin/bash
echo "本脚本将安装 LXDE桌面环境 + Tightvnch和Firefox+中文语言包（可选）"
# 参考 https://blog.ievo.top/index.php/archives/19/
# echo "    URL:http://blog.ievo.top"
# echo "    Telegram:@bestomy"
echo "---------------------------------------------------------------------------------------------------------------------" 
echo "按任意键继续！ 使用 Ctrl + C 退出！"

touch /dev/fuse  #不支持fuse的ovz的必要工作 感谢time4vps

cd /root
apt-get update -y
apt-get -y install ca-certificates sudo
apt-get install xorg -y
apt-get install lxde-core -y
apt-get install tightvncserver -y

tightvncserver :1 # 启动 TightVNC 服务器并创建一个新的 VNC 会话
tightvncserver -kill :1 # 用于停止指定的 TightVNC 会话

echo " #!/bin/sh
xrdb $HOME/.Xresources
xsetroot -solid grey
export XKL_XMODMAP_DISABLE=1
/etc/X11/Xsession
lxterminal &
/usr/bin/lxsession -s LXDE & " > ~/.vnc/xstartup

read -e -p "是否安装中文支持及火狐浏览器？Y/n  " INPUT
case $INPUT in
  Y|y) 
    echo "将安装firefox和中文支持"
    apt-get install iceweasel -y
    apt-get install lxde -y
    apt-get install ttf-arphic-uming -y
    apt-get install xfonts-intl-chinese -y
    apt-get install xfonts-wqy -y
    apt-get install ttf-arphic-ukai ttf-arphic-uming ttf-arphic-gbsn00lp ttf-arphic-bkai00mp ttf-arphic-bsmi00lp -y
    ;;
  *)
    echo "不会安装firefox和中文支持"
esac
tightvncserver :1
echo "VNC已经启动完成，关闭使用 tightvncserver -kill :1 "
echo "-------安装完成 祝您搞机愉快-------"
