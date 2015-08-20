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
    echo -e "\e[31m\e[1m请使用root权限运行此脚本\e[0m"
    exit 1
fi

trap "rm -f continue.sh ; mv continue.sh.backup continue.sh ; reset ; exit" 1 2 3 15
mv -f continue.sh continue.sh.backup 2> /dev/null

# 将安装软件所需命令放入关联数组
declare -A softwareInstallCmd
# 软件
softwareInstallCmd['gvim']='sudo pacman -S --noconfirm gvim'
softwareInstallCmd['emacs']='sudo pacman -S --noconfirm emacs'
softwareInstallCmd['gedit']='sudo pacman -S --noconfirm gedit'
softwareInstallCmd['leafpad']='sudo pacman -S --noconfirm leafpad'
softwareInstallCmd['smplayer']='sudo pacman -S --noconfirm smplayer'
softwareInstallCmd['vlc']='sudo pacman -S --noconfirm vlc'
softwareInstallCmd['mpv']='sudo pacman -S --noconfirm mpv'
softwareInstallCmd['firefox']='sudo pacman -S --noconfirm firefox'
softwareInstallCmd['chromium']='sudo pacman -S --noconfirm firefox'
softwareInstallCmd['opera']='sudo pacman -S --noconfirm opera'
# 桌面环境
softwareInstallCmd['gnome']='sudo pacman -S --noconfirm gnome'
softwareInstallCmd['plasma']='sudo pacman -S --noconfirm plasma'
softwareInstallCmd['xfce4']='sudo pacman -S --noconfirm xfce4'
softwareInstallCmd['cinnamon']='sudo pacman -S --noconfirm cinnamon'
softwareInstallCmd['mate']='sudo pacman -S --noconfirm mate'

function chooseSoftware
{
    PS3='请输入选项：'
    select choose in "$@";do
        if [ ${choose:-NONE} == 'NONE' ];then
            continue;
        elif [ ${choose} != '不安装' ];then
            echo -e ${softwareInstallCmd[${choose}]} >> continue.sh
            break
        else
            echo '# ${choose}' >> continue.sh
            break
        fi
    done
}

function chinease
{
	cat <<- EOF
	请问您是否打算使用中文界面的系统？
	如果您选Y，那么我们将为您更新xinitrc。

	为了避免tty乱码，我们并不更改local变量。
	更改xinitrc只会在您startx并进入桌面环境时才会显示中文界面。

	EOF

	read -p "现在请输入您的选择(Y/n)：" zh
	if [[ ${zh} == [Yy]]];then

cat >> continue.sh << cEOF
cat >> ~/.xinitrc << EOF

export LANG=zh_CN.UTF-8
export LANGUAGE=zh_CN:en_US
export LC_CTYPE=en_US.UTF-8

EOF
cEOF

	elif [[${zh} == [Nn] ]];then
		echo "不设置中文" >> continue.sh
}



if [ $(getconf LONG_BIT) = 64 ];then
    sed -i '93d' /etc/pacman.conf > /dev/null 2>&1
    sed -i '92a Include = /etc/pacman.d/mirrorlist' /etc/pacman.conf > /dev/null 2>&1
    sed -i 's/\# \[multilib\]/\[multilib\]/g' /etc/pacman.conf  
fi


sed -i 's/# Color/Color/g' /etc/pacman.conf
sed -i 's/# TotalDownload/TotalDownload/g' /etc/pacman.conf
sed -i 's/# VerbosePkgLists/VerbosePkgLists/g' /etc/pacman.conf

pacman -Syy 
sudo pacman -S --noconfirm {wget,git}

clear
cat << EOF
欢迎来到Linux-quick-install-or-config.

首先，我们要为您创建一个普通用户（此用户为wheel用户组，可以使用sudo）

EOF


read -p "您的新用户的用户名：" usrnm

# 这里使用until来智能判断用户名是否合法，感谢@鼠标乱飘 提供的命令。
until [[ "${usrnm}" =~ ^[[:lower:]] ]]
do
    echo -e "\e[31m\e[1m\n用户名必须以小写英文字母开头！\e[0m"
    read -p "您的新用户的用户名：" usrnm
done



read -s -p "您的新用户的密码：" usrpasswd
useradd -m -G wheel -s /bin/bash ${usrnm}
echo "${usrnm}:${usrpasswd}" | chpasswd

if [ -n "${usrnm}" ];then
    sed -i "73a ${usrnm} ALL=(ALL) ALL" /etc/sudoers
fi
clear


cat >> continue.sh << EOF
# 安装必要组件
sudo pacman -S --noconfirm wqy-microhei
sudo pacman -S --noconfirm xorg-{server,xinit}
cp /etc/X11/xinit/xinitrc ~/.xinitrc
sed -i '\$d' ~/.xinitrc

EOF

echo -e "请问您是否想安装Yaourt？Yaourt作为pacman的一个外壳增加了对AUR的支持。\n"

read -n1 -p "请输入Y或N：" yaourt
if [[ ${yaourt} == [Yy] ]];then
    cat >> continue.sh << EOF
    # 安装Yaourt
    mkdir yaourt
    cd yaourt

    ## 安装依赖：package-query
    wget https://aur.archlinux.org/packages/pa/package-query/package-query.tar.gz
    tar zxf package-query.tar.gz
    cd package-query
    yes|makepkg -si
    cd ..

    ## 开始安装Yaourt
    wget https://aur.archlinux.org/packages/ya/yaourt/yaourt.tar.gz
    tar zxf yaourt.tar.gz
    cd yaourt
    yes|makepkg -si
    cd ..
    rm -rf yaourt
EOF
elif [[ ${yaourt} == [Nn] ]];then
    echo "# 不安装Yaourt" >> continue.sh
fi

clear



echo -e "请问您是否想安装Zsh？Zsh拥有比默认的Bash更加方便的设置与外观。\n"

while true
do
    read -n1 -p "请输入Y或N：" zsh
    echo

    if [[ ${zsh} == [Yy] ]];then
        echo "# 安装zsh" >> continue.sh
        echo -e "\n请问您是否想自动配置zsh？当前有以下选项："

        while true
        do

            select config in '使用oh-my-zsh' '使用grml-zsh-config' '不进行配置'
            do
                break
            done

            case ${config} in
                '使用oh-my-zsh')
                    function configzsh()
                    {
                        git clone https://github.com/robbyrussell/oh-my-zsh ~/.oh-my-zsh
                        cp -rf ~/.oh-my-zsh /home/${usrnm}/.oh-my-zsh
                        cp -f ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
                        echo "cp -f ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc" >> continue.sh
                    }
                    break
                    ;;
                '使用grml-zsh-config')
                    function configzsh()
                    {
                        pacman -S grml-zsh-config
                        cp /etc/zsh/zshrc ~/.zshrc
                        cp /etc/zsh/zshrch /home/${usrnm}/.zshrc
                    }
                    break
                    ;;
                '不进行配置')
                    break
                    ;;
            esac
        done

        function installzsh()
        {
            pacman -S --noconfirm zsh
            chsh -s /bin/zsh
            configzsh
            echo "echo "${usrpasswd}" | chsh -s /bin/zsh" >> continue.sh
        }
        break

    elif [ ${zsh} = N ] || [ ${zsh} = n ];then
        echo "# 不安装Zsh" >> continue.sh
        break
    fi
done
clear

cat << EOF
现在请您选择一个桌面环境或窗口管理器，我们当前提供：

桌面环境：Gnome、Plasma（KDE5）、Xfce4、Cinnamon、和Mate
窗口管理器：i3(wm)、Openbox、Awesome


EOF

select display in '桌面环境' '窗口管理器' '均不安装'
do
    break
done
clear

echo -e "现在请选择您要安装的${display}：\n"
if [ ${display} == '桌面环境' ];then

    chooseSoftware 'gnome' 'plasma' 'xfce4' 'cinnamon' 'mate'
    # choose为保存用户选项的全局变量，定义于chooseSoftware函数中

    clear
    case ${choose} in
        gnome)
			chinease
            echo "请问您是否要安装${choose}扩展包？其中包含了很多${choose}的原生软件和一些主题等"
            echo
            while true
            do
                read -n1 -p "请输入Y/N：" ge
                echo
                if [[ ${ge} == [Yy] ]];then
                    echo "sudo pacman -S --noconfirm gnome-extra" >> continue.sh
                    break
                elif [[ ${ge} == [Nn] ]];then
                    break
                fi
            done
            echo >> continue.sh
            echo "echo 'exec gnome-session' >> ~/.xinitrc" >> continue.sh
            ;;

        plasma)	
			chinease
            echo >> continue.sh
            echo "echo 'exec startkde' >> ~/.xinitrc" >> continue.sh
            ;;

        xfce4)	
			chinease
            echo "请问您是否要安装${choose}扩展包？其中包含了很多${choose}的原生软件和一些主题等"
            echo
            while true
            do
                read -n1 -p "请输入Y/N：" ge
                echo
                if [[ ${ge} == [Yy] ]];then
                    break
                    echo "sudo pacman -S --noconfirm xfce4-goodies" >> continue.sh
                elif [[ ${ge} == [Nn] ]];then
                    break
                fi
            done
            echo >> continue.sh
            echo "echo 'exec startxfce4' >> ~/.xinitrc" >> continue.sh
            ;;

        cinnamon)	
            chinease
            echo "请问您是否要安装${choose}扩展包？其中包含了很多${choose}的原生软件和一些主题等"
            echo
            while true
            do
                read -n1 -p "请输入Y/N：" ge
                echo
                if [[ ${ge} == [Yy] ]];then
                    echo "sudo pacman -S --noconfirm {gnome-screenshot,gnome-terminal,evince,viewnior,file-roller}" >> continue.sh
                    break
                elif [[ ${ge} == [Nn] ]];then
                    break
                fi
            done
            echo >> continue.sh
            echo "echo 'exec cinnamon-session' >> ~/.xinitrc" >> continue.sh
            ;;

        mate)	
			chinease
            echo "请问您是否要安装${choose}扩展包？其中包含了很多${choose}的原生软件和一些主题等"
            echo
            while true
            do
                read -n1 -p "请输入Y/N：" ge
                echo
                if [[ ${ge} == [Yy] ]];then
                    echo "sudo pacman -S  --noconfirm mate-extra" >> continue.sh
                    break
                elif [[ ${ge} == [Nn] ]];then
                    break
                fi
            done
            echo >> continue.sh
            echo "echo 'exec mate-session' >> ~/.xinitrc" >> continue.sh
            ;;
    esac

elif [ ${display} == '窗口管理器' ];then

    chooseSoftware  'i3(wm)' 'openbox' 'awesome'

    case ${choose} in
        i3)
			chinease
            echo >> continue.sh
            echo "echo 'exec i3' ~/.xinitrc" >> continue.sh
            ;;

        openbox)	
			chinease
            echo "mkdir -p ~/.config/openbox" >> continue.sh
            echo "cp /etc/xdg/openbox/{rc.xml,menu.xml,autostart,environment} ~/.config/openbox" >> continue.sh
            echo >> continue.sh
            echo "echo 'exec openbox-session' ~/.xinitrc" >> continue.sh
            ;;
        awesome)
			chinease
            echo >> continue.sh
            echo "echo 'exec awesome' ~/.xinitrc" >> continue.sh
            ;;
    esac

fi

clear
cat >> continue.sh << EOF
# 安装Networkmanager网络管理器
sudo pacman -S --noconfirm networkmanager
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager

EOF

cat << EOF
首先，我们要为您安装中文输入法。

本版本仅支持fcitx框架+Googlepinyin输入法


EOF


while true
do
    read -n1 -p "请输入Y/N：" fci
    echo
    if [[ ${fci} == [Yy] ]];then
        echo "# 安装中文输入法" >> continue.sh
        echo "sudo pacman -S --noconfirm fcitx-{im,qt5,googlepinyin,configtool}" >> continue.sh
        echo >> continue.sh
        break
    elif [[ ${fci} == [Nn] ]];then
        echo "# 不安装中文输入法" >> continue.sh
        echo
        break
    fi
done
clear



cat << EOF
您现在可以选择一个自己熟悉的文本编辑器了，我们共提供了4款编辑器：分别是emacs、gvim、gedit和leafpad。

其中，emacs和gvim属于专业编辑器。如果您对其不了解不要选择，而gedit和leafpad更加简单易用，大家可以随意挑选。


EOF

echo "# 安装文本编辑器" >> continue.sh

chooseSoftware 'gvim' 'emacs' 'gedit' 'leafpad' '不安装文本编辑器'
echo >> continue.sh
clear

cat << EOF
现在，我们来挑选一个音视播放器。本版本提供SMPlayer、mpv和VLC。

EOF
echo "# 安装视频播放器" >> continue.sh

chooseSoftware 'smplayer' 'vlc' 'mpv' '不安装视频播放器' 
echo >> continue.sh
clear


echo -e "现在，我们可以开始安装浏览器了：我们当前提供有firefox、opera和chromium\n"

echo "# 安装网页浏览器" >> continue.sh
echo "sudo pacman -S --noconfirm flashplugin" >> continue.sh

echo
chooseSoftware 'firefox' 'opera' 'chromium' '不安装网页浏览器'
clear
if [ ${choose} == 'firefox' ];then
    echo "请问您是否要安装Firefox的中文支持？安装后浏览器将为中文界面。"
    echo

    read -n1 -p "请输入Y/N：" chs
    if [[ ${chs} == [Yy] ]];then
        echo "sudo pacman -S --noconfirm firefox-i18n-zh-cn" >> continue.sh
    fi
fi
echo >> continue.sh
clear



cat << EOF
如果您现在是实体机安装并且是笔记本电脑而且带有触摸板的话

不安装这个驱动触摸板将不会工作,如果您确实是上述的情况请安装触摸板驱动：


EOF

while true
do
    read -n1 -p "请输入Y/N：" syna

    if [[ ${syna} = [Yy] ]];then
        echo "# 安装触摸板驱动" >> continue.sh
        echo "sudo pacman -S --noconfirm xf86-input-synaptics" >> continue.sh
        echo >> continue.sh
        break
    fi

    if [[ ${syna} == [Nn] ]];then
        echo "# 不安装触摸板驱动"
        break
    fi
done

installzsh

clear
mv -f continue.sh /home/${usrnm}/continue.sh
chmod 777 /home/${usrnm}/continue.sh
mv continue.sh.backup continue.sh
reset

cat << EOF
感谢您的使用，现在请先注销当前用户(使用<Ctrl+D>组合键或exit命令)
然后使用./continue.sh进行后续的软件安装吧。

最后再次感谢您的使用，再见。
EOF
