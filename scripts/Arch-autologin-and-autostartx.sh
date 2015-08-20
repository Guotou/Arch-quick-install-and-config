#!/bin/bash
if [ ${UID} != 0 ];then
	echo -e "\e[31m\e[1m请使用root权限运行此脚本\e[0m"
	exit
fi

usersh=$(env | grep SHELL | cut -d "/" -f 3)

function startxlogin()
{
	if [[ ${usersh} == zsh ]];then
		if [[ ! -f /home/${username}/.zprofile ]];then
			cp /etc/zsh/zprofile /home/${username}/.zprofile
		fi
		sed -i s/'\[\[ \-z \$DISPLAY \&\& \$XDG_VTNR \-eq 1 \]\] \&\& exec startx'//g .zprofile
		echo '[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx' >> /home/${username}/.zprofile
	fi

	if [[ ${usersh} == bash ]];then
		if [[ ! -f /home/${username}/.bash_profile ]];then
			cp /etc/skel/.bash_profile /home/${username}/.bash_profile
		fi
		sed -i s/'\[\[ \-z \$DISPLAY \&\& \$XDG_VTNR \-eq 1 \]\] \&\& exec startx'//g .bash_profile
		echo '[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx' >> /home/${username}/.bash_profile
	fi
}

function stopstartxloin()
{
	case ${usersh} in
		zsh)
			sed -i s/'\[\[ \-z \$DISPLAY \&\& \$XDG_VTNR \-eq 1 \]\] \&\& exec startx'//g .zprofile
			;;
		bash)
			sed -i s/'\[\[ \-z \$DISPLAY \&\& \$XDG_VTNR \-eq 1 \]\] \&\& exec startx'//g .bash_profile
			;;
	esac
}

function autologin()
{
	mkdir -p /etc/systemd/system/{getty@tty1.service.d,serial-getty@ttyS0.service.d}

	cat >> /etc/systemd/system/getty@tty1.service.d/override.conf <<- EOF
	[Service]
	ExecStart=
	ExecStart=-/usr/bin/agetty --autologin ${username} --noclear %I 38400 linux
	EOF

	cat >> /etc/systemd/system/getty@tty1.service.d/autologin.conf <<- EOF
	[Service]
	ExecStart=
	ExecStart=-/usr/bin/agetty --autologin ${username} -s %I 115200,38400,9600 vt102
	EOF
}

function stopautologin()
{
	rm -rf /etc/systemd/system/getty@tty1.service.d/
}


PS3=您的选择：
tput clear
tput setf 5
tput bold
echo "欢迎使用Arch自动登录与自动进入桌面环境的脚本。"
read -p "首先，请输入您的用户名：" username
echo 
echo "现在，请输入您的选项："


tput setf 2                      
tput bold

while true
do

select choose in "自动登录" "关闭自动登录" "自动进入桌面环境" "关闭自动进入桌面环境" "同时开启" "同时关闭" "退出"
do
	break
done

case ${choose} in
	"自动登录")
		autologin
		;;
	"关闭自动登录")
		stopautologin
		;;
	"自动进入桌面环境")
		startxlogin
		;;
	"关闭自动进入桌面环境")
		stopstartxlogin
		;;
	"同时开启")
		autologin
		startxlogin
		;;
	"同时关闭")
		stopautologin
		stopstartxlogin
		;;
	"退出")
		break
		;;
esac
clear

done

tput setf 5
tput bold
echo "设置完成"
