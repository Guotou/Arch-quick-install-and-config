===================================
Arch Linux quick install and config
===================================

欢迎来到Linux quick install or config。

我们致力于开发开源简单的Linux快速安装（或配置）的Shell脚本。


----
Tips
----


所有的脚本均存放在scripts文件夹内。dev分支为开发版本。


大家可以 **谨慎使用** 开发版本，我们也欢迎大家帮忙测试。如果测试没有bug可以告诉我们。

Edit: 经过测试当前开发版本有严重bug，请不要使用直到我们开发团队测试并修复bug。


------------
Installation 
------------


首先是Arch-Linux-quick-install，请确保您正在使用 *root* 用户。

然后您需要安装下列程序并运行fbterm，全部的命令像这样：


::

    pacman -Syy
    pacman -S git fbterm wqy-microhei 
    fbterm

此时会进入一个虚拟终端，前面输入的将被清空。

现在tty就可以正常显示中文了，之后输入这些：

::

    git clone --depth=1 https://github.com/K-Guan/Arch-quick-install-and-config
    ./Arch-quick-install-and-config/scripts/Arch-Linux-quick-install.sh

好了，之后根据提示做就可以了。


**Arch-Linux-quick-config** 的话和上面的做法一样，但是需要更改文件名。像这样：

::
  
    pacman -Syy
    pacman -S git fbterm wqy-microhei 
    fbterm

    git clone --depth=1 https://github.com/K-Guan/Arch-quick-install-and-config
    ./Arch-quick-install-and-config/scripts/Arch-Linux-quick-config.sh
    
    
----
Tip:
----


1. 本脚本暂不支持UEFI，UEFI的电脑请不要使用本脚本安装。

2. fbterm对虚拟机支持并不好，请不要在虚拟机中使用此脚本。

3. 如果在安装fbterm和git等软件时发现速度太慢，可以参考wiki的 *选择安装镜像* 部分更改软件源。
