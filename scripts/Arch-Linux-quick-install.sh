#!/bin/bash
#
# Copyright 2015 Kevin Guan
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
	exit
fi

clear
cat << EOF
首先，请您手动进行分区，我们当前并没有自动分区的功能
当您结束分区后，请按<Ctrl+D>以终止。


EOF
echo -e "\e[32m\e[1m提示：当您分区结束后请直接按<Ctrl+D>。您并不需要手动挂载分区。\e[0m"
zsh
clear


echo -e "很高兴您已经完成了，现在让我们来开始安装吧\n"
while true
do

	read -p "请问您有一个交换分区(swap)吗？请输入Y/n：" swap

	case ${swap} in
		Y|y)
			lsblk
			read -p "请输入该分区的“编号”，如sda5或/dev/sda5：" swappart

			if [ $(echo ${swappart} | cut -c 1-4) != /dev ];then
				swappart=/dev/${swappart}
			fi

			if [ ! -e ${swappart} ];then
				echo -e "\e[32m\e[1m此分区并不存在，请检查您的拼写并重新输入\e[0m"
			else
				break
			fi

			mkswap ${swappart} > /dev/null 2>&1
			swapoff ${swappart} > /dev/null 2>&1
			swapon ${swappart} > /dev/null 2>&1
			clear
			break
			;;
		N|n)
			break
			;;
		*)
			echo -e "\e[31m\e[1m选择错误，请重试。\e[0m"
	esac
done

while true
do
	clear
	lsblk
	read -p "现在请输入您打算安装Arch的分区：" rootpart

	if [ $(echo ${rootpart} | cut -c 1-4) != /dev ];then
		rootpart=/dev/${rootpart}
	fi

	if [ ! -e ${rootpart} ];then
		echo "This partition doesn't exists. Please check your type."
	else
		break
	fi
done

clear
echo -n "请问您还有类似于home，boot之类的分区吗？请输入Y/n："

while true
do
	read mountother
	case ${mountother} in
		Y|y)
			lsblk
			echo -en "\n请输入分区类型（home，boot等）："
			read othertype

			echo -en "\n现在请输入分区编号："
			read otherpath

			if [ $(echo ${otherpath} | cut -c 1-4) != /dev ];then
				otherpath=/dev/${otherpath}
			fi

			if [ ! -e ${rootpart} ];then
				echo -e "\e[32m\e[1m此分区并不存在，请检查您的拼写并重新输入\e[0m"
			else
				break
			fi

			read -p "Will mount ${otherpath} to /mnt/${othertype}. Are you sure? Y/N: " sure
			if [ ${sure} == Y ] || [ ${sure} == y ];then

				mkdir /mnt/${othertype}
				mount ${otherpath} /mnt/${othertype}
			fi
			echo -en "还有其他的分区吗？请输入Y/n："
			;;

		N|n)
			break
			;;
		*)
			echo -e "\e[31m\e[1m选择错误，请重试。\e[0m"
	esac
done

umount /mnt 2> /dev/null
clear

mount ${rootpart} /mnt
wget "https://www.archlinux.org/mirrorlist/?country=CN&protocol=http&ip_version=4" -O /tmp/mirrorlist
grep Server /tmp/mirrorlist | sed 's/^#//g' > /etc/pacman.d/mirrorlist

clear
pacstrap -i /mnt base base-devel
clear

echo "恭喜您安装完成了，现在我们可以开始进行一些配置了："
genfstab -U -p /mnt >> /mnt/etc/fstab

mkdir /mnt/root
cat >> /mnt/root/config.sh <<- FileEOF
cat >>/etc/locale.gen <<- EOF
en_US.UTF-8 UTF-8
zh_CN.UTF-8 UTF-8
zh_TW.UTF-8 UTF-8
EOF


locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc --utc


echo -en "\n请问您打算使用什么主机名："
read hostnm
echo "\${hostnm}" > /etc/hostname

rm -f /etc/hosts > /dev/null 2>&1
echo "127.0.0.1       localhost.localdomain   localhost \${hostnm}" >> /etc/hosts 
echo "::1             localhost.localdomain   localhost \${hostnm}" >> /etc/hosts 


clear
while true
do
	echo -en "请问您需要使用Wifi吗？请输入Y/n\n
	如果您需要，我们将为您安装dialog和wpa_supplicant以便使用wifi-menu)："
	read wireless

	case \${wireless} in
		Y|y)
			pacman -S --noconfirm dialog wpa_supplicant
			break
			;;
		N|n)
			break
			;;
		*)
			echo -e "\e[31m\e[1m选择错误，请重试。\e[0m"
			;;
	esac
done
systemctl enable dhcpcd@\$(ls /sys/class/net/ | grep e)


echo -en "\n请输入您打算使用的root密码："
read -s rootpass
echo "root:\${rootpass}" | chpasswd


pacman -S --noconfirm grub


clear
while true
do
	echo -en "请问您需要grub引导其他的操作系统吗？请输入Y/n\n
	如果您需要，我们将为您安装os-prober)："
	read bootothersys

	case \${bootothersys} in
		Y|y)
			pacman -S --noconfirm os-prober
			break
			;;
		N|n)
			break
			;;
		*)
			echo -e "\e[31m\e[1m选择错误，请重试。\e[0m"
			;;
	esac
done



grub-install --target=i386-pc --recheck $(echo "${rootpart}" | cut -c 1-8)
grub-mkconfig -o /boot/grub/grub.cfg
FileEOF

arch-chroot /mnt /bin/bash /root/config.sh
rm /mnt/root/config.sh
umount /mnt 2> /dev/null

reset
echo -en "\e[1;31m感谢您的使用\e[0m";echo -en "\e[1;36m安装\e[0m"; echo -e "\e[1;32m已完成！\e[0m"
echo -en "\e[1;35m请问您现在需要重启吗？请输入Y/N：\e[0m"

read reboot
if [ ${reboot} = Y ] | [ ${reboot} = y ];then
	reboot
fi
