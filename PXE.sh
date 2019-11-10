#!/bin/bash
#PXE网络装机本地配置脚本
#by:NSD1909.spp
#
#
#备用获取本机方案bjip=`ifconfig -a|grep -o -e 'inet [0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}'|grep -v "127.0.0"|awk '{print $2}'` 
bjip=`hostname -i`
dhcpcfg=/etc/dhcp/dhcpd.conf
#上面是获取本机IP
test -e /dev/cdrom && mount /dev/cdrom /mnt ||echo "没有检测到ISO挂载光盘,byebye";exit
test -e /mnt/isolinux || umount /mnt && mount /dev/cdrom /mnt
sleep 1
echo "-------------现在安装web服务---"
yum -y install httpd
mkdir /var/www/html/centos
echo "-------------现在将光盘内容持载到web服务下---"
sleep 1
mount /dev/cdrom /var/www/html/centos
test -e /var/www/html/centos/isolinux && echo "web目录下挂载成功" || echo "web下光盘挂载失败"
sleep 1
echo '-------------现在安装dhcp----'
sleep 2
yum -y install dhcp

echo '-------------现在配置dhcp----'
sleep 2
sed -i '1,$d' /etc/dhcp/dhcpd.conf #dhcp 配置文件内容清空
echo 请输入子网划分的IP默认为 ${bjip%.*}.0 网段
read -p "输入如果网段地址如果是默认值请直接回车按enter:" wand
test -z $wand && wand=`${bjip%.*}.0`
echo 请输入子网掩码默认值为 255.255.255.0
read -p "输入子网掩码,默认直接回车按enter:" ntmk
test -z $ntmk && ${ntmk:-255.255.255.0} 
echo "subnet $wand netmask $ntmk;{" >> $dhcpcfg
sleep 0.5
echo "请设置默认客户机IP网段默认为"
sleep 0.5
echo "${bjip%.*}.100-${bjip%.*}.200"
sleep 0.5
echo "请输入起始ip末位范围1-255,要确保本机的$bjip 不在你的范围内"
sleep 0.5
read -p "输入起始IP末位,默认为100直接回车:" staip
sleep 0.5
test -z $staip && ${staip:-200}
read -p "输入终止IP末位,默认为200直接回车:" endip
sleep 0.5
test -z $endip && ${staip:-200}
echo "  range ${bjip%.*}.$staip ${bjip%.*}.$endip;" >> $dhcpcfg
sleep 0.5
echo "请设置DNS解析地址默认为本机IP$bjip"
sleep 0.5
read -p "请输入格式如192.168.4.7 默认请直接回车" dnsip
test -z $dnsip && dnsip=`hostname -i`
echo "  option domain-name-server $dnsip" >> $dhcpcfg
sleep 0.5
echo "请设置客户机选择默认项等待时间默认为20秒"
sleep 0.5
read -p "请输入秒数默认为20秒直接回车:" second1
test -z $second && ${second1:-20}
sleep 0.5
echo "  default-lease-time $second1;" >> $dhcpcfg
sleep 0.5
echo "请输入最客户机租用IP最大时间默认为7200秒"
read -p "请输入秒数,如果默认值请直接回车:" second2
test -z $second2 && ${second2:-7200}
echo "  max-lease-time $second2;" >> $dhcpcfg
sleep 0.5
echo "请指定客户机访问系统ISO镜像的主机IP默认为本机IP$bjip"
read -p "请输入IP地址默认请直接回车:" isoip
test -z $isoip && isoip=`hostname -i`
echo "  next-server $isoip;" >> $dhcpcfg
sleep 0.5
echo '  filename "pxelinux.0";'>> $dhcpcfg
echo '' >> $dhcpcfg
sleep 0.5
echo "" >> $dhcpcfg
sleep 0.5
echo '}' >> $dhcpcfg
sleep 0.5
echo "指定网卡引导文件为pxelinux.0 已经写入配置"
sleep 0.5
echo "---------------现在安装TFTP服务----"
yum -y install tftp-server
sleep 1
echo "---------------重启服务TFTP----"
systemctl restart ftfp
sleep 1
echo"---------------现在安装syslinux----"
sleep 1
yum -y install syslinux
sleep 1
cp /usr/share/syslinux/pxelinux.0 /var/lib/tftpboot/
test -e /var/lib/tftpboot/pxelinux.0 && echo "pxelinux.0 已经复制成功" || echo "pxelinux.0复制失败"
echo "--------------现在部署pxelinux.0文件----"
sleep 1
echo "--------------正在建立菜单目录----"
mkdir /var/lib/tftpboot/pxelinux.cfg
test -e /var/lib/tftpboot/pxelinux.cfg && echo "-------创建成功-----" || echo "创建失败"
sleep 0.5
cp /mnt/isolinux/isolinux.cfg /var/lib/tftpboot/pxelinux.default 
test -e /var/lib/tftpboot/pxelinux.default && echo "-----------pxelinux.default创建成功---------" || echo "/mnt/isolinux/isolinux.cfg 没有复制成功"
sleep 0.5
cp /mnt/isolinux/vesamenu.c32 /var/lib/tftpboot/
test -e /var/lib/tftpboot/vesamenu.c32 && echo "-----------图形模块复制成功---------" || echo "图形模块vesamenu.c32 复制失败"
sleep 1
cp /mnt/isolinux/splash.png /var/lib/tftpboot/
test -e /var/lib/tftpboot/splash.png && echo "---------前景图片复制成功---------" || echo "前景图片复制失败"
sleep 1
cp /mnt/isolinux/vmlinuz /var/lib/tftpboot/
test -e /var/lib/tftpboot/vmlinuz && "-----------启动内核复制成功------------" || echo "启动内核复制失败"
sleep 1
cp /mnt/isolinux/initrd.img /var/lib/tftpboot/ 
test -e  /var/lib/tftpboot/initrd.img && echo "-----------驱动程序复制成功-----------" ||echo "驱动程序复制失败"
sleep 1
echo "------------现在编辑菜单配置文件------------"
sleep 1
listcfg=/var/lib/tftpboot/pxelinux.cfg/default
sed -i '11s/7/7shell/1' $listcfg
sed -i '63,$d' $listcfg
echo "  menu default" >> $listcfg
echo "  kernel vmlinuz" >>$listcfg
echo "  append initrd=initrd.img" >>$listcfg
echo "------------配置内容写入完毕------------"
sleep 1
echo "------------接下来进行无人值守程序安装-----------"
sleep 1
#--------------------------------------------------------------
yum -y install system-config-kickstart
sleep 1
echo "正在指向光盘的内容仓库,标识为[development]"
sed -i '1s/local_repo/development/1' /etc/yum.repos.d/local.repo
#-----------------------------------------------------------------
touch /var/www/html/ks.cfg
rqfile=/var/www/html/ks.cfg

echo "install" >>$rqfile
sleep 0.2
echo "keyboard 'us'" >>$rqfile
sleep 0.2
echo "rootpw --iscrypted $1$KbkI4NAm$X9wP0rtbYGT2uspTUAP39." >>$rqfile
sleep 0.2
echo "url --url=\"http://$bjip/centos\""  >>$rqfile
sleep 0.2
echo "lang en_US" >>$rqfile
sleep 0.2
echo "auth  --useshadow  --passalgo=sha512" >>$rqfile
sleep 0.2
echo "graphical" >>$rqfile
sleep 0.2
echo "firstboot --disable" >>$rqfile
sleep 0.2
echo "selinux --disabled" >>$rqfile
sleep 0.2
echo "" >>$rqfile
sleep 0.2
echo "firewall --disabled" >>$rqfile
sleep 0.2
echo "network  --bootproto=dhcp --device=eth0" >>$rqfile
sleep 0.2
echo "reboot" >>$rqfile
sleep 0.2
echo "timezone Asia/Shanghai" >>$rqfile
sleep 0.2
echo "bootloader --location=mbr" >>$rqfile
sleep 0.2
echo "clearpart --all --initlabel" >>$rqfile
sleep 0.2
echo "part / --fstype=\"xfs\" --grow --size=1" >>$rqfile
sleep 0.2
echo "%post --interpreter=/bin/bash" >>$rqfile
sleep 0.2
echo "echo \"sytem shell OK \"" >>$rqfile
sleep 0.2
echo "%end" >>$rqfile
sleep 0.2
echo "%packages" >>$rqfile
sleep 0.2
echo "@base" >>$rqfile
sleep 0.2
echo "%end" >>$rqfile
sleep 0.2
echo "" >>$rqfile
sleep 2
echo "现在正在重启服务httpd"
sleep 1
system restart httpd

echo "现在正在重启服务dhcpd"
sleep 1
system restart dhcpd

echo "现在正在重启服务tftp"
sleep 1
systemctl restart tftp

echo "PXE 主机设置成功,请打开同一局域网主机,进行测试"

