#!/bin/bash
#
# Copyright 2015 Guanrenfu
#
# Licensed under the Apache License, Version 2.0 (the License); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 
# 
#     http://www.apache.org/licenses/LICENSE-2.0 
# 
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an AS IS BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License. 
if [ ${UID} != 0 ];then
	echo "You're not root. You need run this script as root."
fi

#更改软件源
echo "deb http://mirrors.ustc.edu.cn/kali kali main non-free contrib" > /etc/apt/sources.list
echo "deb-src http://mirrors.ustc.edu.cn/kali kali main non-free contrib" >> /etc/apt/sources.list
echo "deb http://mirrors.ustc.edu.cn/kali-security kali/updates main contrib non-free" >> /etc/apt/sources.list
echo "deb http://mirrors.aliyun.com/kali kali main non-free contrib" >> /etc/apt/sources.list
echo "deb-src http://mirrors.aliyun.com/kali kali main non-free contrib" >> /etc/apt/sources.list
echo "deb http://mirrors.aliyun.com/kali-security kali/updates main contrib non-free" >> /etc/apt/sources.list

#更新软件源并安装fcitx，google拼音和flash
yes|apt-get update
yes|apt-get install fcitx fcitx-googlepinyin
yes|apt-get install flashplugin-nonfree
yes|update-flashplugin-nonfree --install

#启用Metasploit数据库
update-rc.d postgresql enable
update-rc.d metasploit enable
service postgresql start
service metasploit start

#更改字体
yes|apt-get install ttf-wqy-microhei

#美化Vim、开启语法高亮、自动缩进等功能。
echo "filetype indent on" >> /etc/vim/vimrc
echo "colorscheme murphy" >> /etc/vim/vimrc
echo "syntax enable" >> /etc/vim/vimrc

#解决显示“设备未托管”从而导致无法使用网络的问题
sed -i '$d' /etc/NetworkManager/NetworkManager.conf
echo "managed=true" >> /etc/NetworkManager/NetworkManager.conf

##替换VLC、删除gedit、leafpad等仅保留vim。如果不了解请不要启用这些命令
#yes|apt-get purge vlc
#yes|apt-get purge gedit
#yes|apt-get purge leafpad
#yes|apt-get install smplayer

#解决启动Wireshark报错的问题
sed -i '$d' /usr/share/wireshark/init.lua
sed -i '$d' /usr/share/wireshark/init.lua
echo "--dofile(DATA_DIR.."console.lua")" >> /usr/share/wireshark/init.lua
echo "--dofile(DATA_DIR.."dtd_gen.lua")" >> /usr/share/wireshark/init.lua

##安装Zsh并自动配置，不需要请删除下面的命令直到下一个#号
yes|apt-get install zsh
git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
chsh -s /bin/zsh
##删除到这里

#清理系统垃圾与多余文件并更新系统
yes|apt-get upgrade
reset
yes|apt-get autoremove
yes|apt-get clean
yes|apt-get autoclean
dpkg -l |grep "^rc"|awk '{print $2}' |xargs aptitude -y purge
cd /usr/share/man && rm -rf `ls | grep -v "man"` > /dev/null 2>&1
rm -rf /var/log/*
rm -rf /tmp/*

reset
read -n1 -s -p "恭喜您完成了Kali快速设置，现在请您先重启然后手动设置输入法。设置的方法是右键点击右上方的小键盘，然后选择更改设置并将Google拼音移动到最上方以设为默认（如果您不需要则没有必要），顺便建议您将皮肤设置为十分大气的dark（黑色，尽显高端）。感谢您使用此脚本。" va
