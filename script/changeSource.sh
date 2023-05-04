#!/bin/bash

echo "*************************************************************"
echo "欢迎使用辉少一键换源脚本，请选择镜像源："
echo "
    1.阿里
    2.清华
    3.网易
    4.中科大
    5.以上4个源全添加(推荐)
    6.reflector加载源(资源丰富)
    7.开启社区源(必须)
    8.开启32位软件源
    9.安装Yay(一次成功即可)
    "
echo "*************************************************************"
read mirrorlist

if [ $mirrorlist -ne 1 ]&&[ $mirrorlist -ne 2 ]&&[ $mirrorlist -ne 3 ]&&[ $mirrorlist -ne 4 ]&&[ $mirrorlist -ne 5 ]&&[ $mirrorlist -ne 6 ]&&[ $mirrorlist -ne 7 ]&&[ $mirrorlist -ne 8 ]&&[ $mirrorlist -ne 9 ];
then
    echo
    echo '输入有误,请重新运行程序！'
    exit
fi

case $mirrorlist in
 1)
  choose='aliyun'
 ;;
 2)
  choose='tsinghua'
 ;;
 3)
  choose='163'
 ;;
 4)
  choose='ustc'
 ;;
 5)
  choose='four'
 ;;
 6)
  choose='china'
 ;;
 7)
  choose='community'
 ;;
 8)
  choose='32'
 ;;
 9)
  choose='yay'
 ;;
esac

echo "正在备份源文件....."
sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak.list


case $choose in
 aliyun)
    echo 'Server = http://mirrors.aliyun.com/archlinux/$repo/os/$arch'>/etc/pacman.d/mirrorlist
 ;;

 tsinghua)
    echo 'Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxarm/$arch/$repo'>/etc/pacman.d/mirrorlist
 ;;

 163)
    echo 'Server = http://mirrors.163.com/archlinux/$repo/os/$arch'>/etc/pacman.d/mirrorlist
 ;;

 ustc)
    echo 'Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch'>/etc/pacman.d/mirrorlist
 ;;

 four)
    echo 'Server = http://mirrors.aliyun.com/archlinux/$repo/os/$arch
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxarm/$arch/$repo
Server = http://mirrors.163.com/archlinux/$repo/os/$arch
Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch
'>/etc/pacman.d/mirrorlist
	sudo sed -i '1 i\ ' /etc/pacman.d/mirrorlist
    sudo sed -i '2 i\################################################################################' /etc/pacman.d/mirrorlist
    sudo sed -i '3 i\################# Arch Linux mirrorlist generated by HuiShao #################' /etc/pacman.d/mirrorlist
    sudo sed -i '4 i\################################################################################' /etc/pacman.d/mirrorlist
	sudo sed -i '5 i\ ' /etc/pacman.d/mirrorlist
 ;;

 china)

    echo "确定是否具备reflector包"
    echo "*************************************************************"
    echo "
        1.Y
        2.N
         "
    echo "*************************************************************"
    read ref

    if [ $ref -ne 1 ]&&[ $ref -ne 2 ];
    then
    	echo
    	echo '输入有误,请重新运行程序！'
    	exit
    fi

    case $ref in
        1)
            echo '请稍等正在更新......'
            sudo reflector --verbose -c China --latest 12 --sort rate --threads 100 --save /etc/pacman.d/mirrorlist
        ;;
        2)
            sudo pacman -S reflector
            echo '请稍等正在更新......'
            sudo reflector --verbose -c China --latest 12 --sort rate --threads 100 --save /etc/pacman.d/mirrorlist
        ;;
    esac

 ;;

 community)
    echo "选择社区源"
    echo "注意：社区源只能选择一个"
    echo "*************************************************************"
    echo "
        1.官方源
        2.163源
        3.清华大学源
         "
    echo "*************************************************************"
    read comm
    
    if [ $comm -ne 1 ]&&[ $comm -ne 2 ];
    then
    	echo
    	echo '输入有误,请重新运行程序！'
    	exit
    fi

    echo "[archlinuxcn]">>/etc/pacman.conf

    case $comm in
        1)
        echo 'Server = http://repo.archlinuxcn.org/$arch'>>/etc/pacman.conf
        ;;
        2)
        echo 'Server = http://mirrors.163.com/archlinux-cn/$arch'>>/etc/pacman.conf
        ;;
        3)
        echo 'Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch'>>/etc/pacman.conf
        ;;

    esac
 ;;

 32)
    echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist">>/etc/pacman.conf
	echo "已为您开启32位软件源"
 ;;

 yay)
	echo '正在安装yay社区包'
	sudo pacman -S archlinuxcn-keyring
	sudo pacman -S yay
 ;;

esac


echo "正在更新源文件....."
sudo pacman -Syyu
echo '系统全面更新完毕，感谢使用辉少脚本'
