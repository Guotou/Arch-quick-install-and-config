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


------------
Installation 
------------

首先是Arch-Linux-quick-install，请确保您正在使用 *root* 用户。

然后您需要安装下列程序并运行fbterm：

::

    pacman -S git fbterm wqy-microhei 
    fbterm

此时会进入一个虚拟终端，前面输入的将被清空。

现在tty就可以正常显示中文了，之后输入这些：

::

    git clone --depth=1 https://github.com/Guanrenfu/Arch-quick-install-and-config
    Arch-quick-install-and-config/scripts/Arch-Linux-quick-install.sh

好了，之后根据提示做就可以了。


**Arch-Linux-quick-config** 的话和上面的做法一样，但是需要更改文件名。像这样：

::

    pacman -S git fbterm wqy-microhei 
    fbterm
    git clone --depth=1 https://github.com/Guanrenfu/Arch-quick-install-and-config
    Arch-quick-install-and-config/scripts/Arch-Linux-quick-config.sh

*Enjoy your Arch Linux*


============
Announcement
============


1. 本人所有项目迁移至本帐号 *K-Guan* 的名下。

2. 抛弃使用release文件夹的方式，开发版本请在dev分支提交。

3. 因Kali 2.0的发布，故取消快速配置Kali的脚本。项目正式更名为： **Arch-quick-install-and-config**

4. 从现在起README使用reStructuredText编写。
