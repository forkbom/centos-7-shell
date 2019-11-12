#!/bin/bash
#PXE网络装机本地配置脚本
#by:NSD1909.spp
#
#
#备用获取本机方案bjip=`ifconfig -a|grep -o -e 'inet [0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}'|grep -v "127.0.0"|awk '{print $2}'` 
bjip=`hostname -i`
dhcpcfg=/etc/dhcp/dhcpd.conf
#上面是获取本机IP
#test -e /dev/cdrom && mount /dev/cdrom /mnt 
if test -e /dev/cdrom;then
	mount /dev/cdrom /mnt
else
	echo "没有检测到有虚拟机挂载的光盘设备脚本将退出,请关机后手机添加硬件CDROM设备"
	exit
fi
	
wait
test -e /mnt/isolinux || umount /mnt && mount /dev/cdrom /mnt
if test -e /mnt/isolinux;then
	echo "已经将光盘内容挂载到/mnt目录下"
else
	umount /mnt/
	wait
	mount /dev/cdrom /mnt/
fi
wait
echo "-------------现在安装web服务---"
yum -y install httpd
mkdir /var/www/html/centos
echo "-------------现在将光盘内容持载到web服务下---"
wait
mount /dev/cdrom /var/www/html/centos
test -e /var/www/html/centos/isolinux && echo "web目录下挂载成功" || echo "web下光盘挂载失败"
wait
echo '-------------现在安装dhcp----'
wait
yum -y install dhcp

echo '-------------现在配置dhcp----'
wait
sed -i '1,$d' /etc/dhcp/dhcpd.conf #dhcp 配置文件内容清空
echo 请输入子网划分的IP默认为 ${bjip%.*}.0 网段
read -p "输入如果网段地址如果是默认值请直接回车按enter:" wand
test -z $wand && wand="${bjip%.*}.0"
echo 请输入子网掩码默认值为 255.255.255.0
read -p "输入子网掩码,默认直接回车按enter:" ntmk
test -z $ntmk && ntmk=255.255.255.0
echo "subnet $wand netmask $ntmk {" >> $dhcpcfg
wait
echo "请设置默认客户机IP网段默认为"
wait 
echo "${bjip%.*}.100-${bjip%.*}.200"
wait
echo "请输入起始ip末位范围1-255,要确保本机的$bjip 不在你的范围内"
wait
read -p "输入起始IP末位,默认为100直接回车:" staip
wait
test -z $staip && staip=100
read -p "输入终止IP末位,默认为200直接回车:" endip
wait
test -z $endip && endip=200
echo "  range ${bjip%.*}.$staip ${bjip%.*}.$endip;" >> $dhcpcfg
wait
echo "请设置DNS解析地址默认为本机IP$bjip"
wait
read -p "请输入格式如192.168.4.7 默认请直接回车" dnsip
test -z $dnsip && dnsip=`hostname -i`
echo "  option domain-name-servers $dnsip;" >> $dhcpcfg
wait
echo  "请输入网关默认地址为${bjip%.*}.254"
read -p "请输入网关地址格式如192.168.4.254 默认请直接回车" getway
wait
test  -z $getway && getway=192.168.4.254 
wait
echo "  option routers $getway;" >> $dhcpcfg
wait
echo "请设置客户机选择默认项等待时间默认为20秒"
wait
read -p "请输入秒数默认为20秒直接回车:" second1
test -z $second1 && second1=20
wait
echo "  default-lease-time $second1;" >> $dhcpcfg
wait
echo "请输入最客户机租用IP最大时间默认为7200秒"
read -p "请输入秒数,如果默认值请直接回车:" second2
test -z $second2 && second2=7200
echo "  max-lease-time $second2;" >> $dhcpcfg
wait
echo "请指定客户机访问系统ISO镜像的主机IP默认为本机IP$bjip"
read -p "请输入IP地址默认请直接回车:" isoip
test -z $isoip && isoip=`hostname -i`
echo "  next-server $isoip;" >> $dhcpcfg
wait
echo '}' >> $dhcpcfg
wait
echo "指定网卡引导文件为pxelinux.0 已经写入配置"
wait
echo "---------------现在安装TFTP服务----"
yum -y install tftp-server
wait
echo "---------------重启服务TFTP----"
systemctl restart ftfp
wait
echo"---------------现在安装syslinux----"
wait
yum -y install syslinux
wait
cp /usr/share/syslinux/pxelinux.0 /var/lib/tftpboot/
test -e /var/lib/tftpboot/pxelinux.0 && echo "pxelinux.0 已经复制成功" || echo "pxelinux.0复制失败"
echo "--------------现在部署pxelinux.0文件----"
wait
echo "--------------正在建立菜单目录----"
mkdir /var/lib/tftpboot/pxelinux.cfg
test -e /var/lib/tftpboot/pxelinux.cfg && echo "-------创建成功-----" || echo "创建失败"
wait
cp /mnt/isolinux/isolinux.cfg /var/lib/tftpboot/pxelinux.cfg/default 
test -e /var/lib/tftpboot/pxelinux.default && echo "-----------pxelinux.default创建成功---------" || echo "/mnt/isolinux/isolinux.cfg 没有复制成功"
wait
cp /mnt/isolinux/vesamenu.c32 /var/lib/tftpboot/
test -e /var/lib/tftpboot/vesamenu.c32 && echo "-----------图形模块复制成功---------" || echo "图形模块vesamenu.c32 复制失败"
wait
cp /mnt/isolinux/splash.png /var/lib/tftpboot/
test -e /var/lib/tftpboot/splash.png && echo "---------前景图片复制成功---------" || echo "前景图片复制失败"
wait
cp /mnt/isolinux/vmlinuz /var/lib/tftpboot/
test -e /var/lib/tftpboot/vmlinuz && echo "-----------启动内核复制成功------------" || echo "启动内核复制失败"
wait
cp /mnt/isolinux/initrd.img /var/lib/tftpboot/ 
test -e  /var/lib/tftpboot/initrd.img && echo "-----------驱动程序复制成功-----------" ||echo "驱动程序复制失败"
wait
sed -i '7a \ \ filename  "pxelinux.0";' $dhcpcfg 
echo "------------现在编辑菜单配置文件------------"
wait
listcfg=/var/lib/tftpboot/pxelinux.cfg/default
sed -i '11s/7/7shell/1' $listcfg #无法读取 没有目录
sed -i '63,$d' $listcfg  #无法读取没有目录
echo "  menu default" >> $listcfg
echo "  kernel vmlinuz" >>$listcfg
echo "  append initrd=initrd.img ks=http://$bjip/ks.cfg" >>$listcfg
echo "------------配置内容写入完毕------------"
wait
echo "------------接下来进行无人值守程序安装-----------"
wait
#--------------------------------------------------------------
yum -y install system-config-kickstart
wait
echo "正在指向光盘的内容仓库,标识为[development]"
sed -i '1s/local_repo/development/1' /etc/yum.repos.d/local.repo
#-----------------------------------------------------------------
touch /var/www/html/ks.cfg
rqfile=/var/www/html/ks.cfg
wait
cat> $rqfile <<EOF
#platform=x86, AMD64, or Intel EM64T
#version=DEVEL
# Install OS instead of upgrade
install
# Keyboard layouts
keyboard 'us'
# Root password
rootpw --iscrypted \$1\$EnIAcw.7\$KXAg1ULvbWENk71PM3Mfa.
# Use network installation
url --url="http://$bjip/centos"
# System language
lang en_US
# System authorization information
auth  --useshadow  --passalgo=sha512
# Use graphical install
graphical
firstboot --disable
# SELinux configuration
selinux --disabled

# Firewall configuration
firewall --disabled
# Network information
network  --bootproto=dhcp --device=eth0
# Reboot after installation
reboot
# System timezone
timezone Asia/Shanghai
# System bootloader configuration
bootloader --location=mbr
# Clear the Master Boot Record
zerombr
# Partition clearing information
clearpart --all --initlabel
# Disk partitioning information
part / --fstype="xfs" --grow --size=1

%packages
@base

%end
EOF
echo "现在正在重启服务httpd"
wait
systemctl restart httpd

echo "现在正在重启服务dhcpd"
wait
systemctl restart dhcpd

echo "现在正在重启服务tftp"
wait
systemctl restart tftp

echo "PXE 主机设置成功,请打开同一局域网主机,进行测试"
echo "默认root 密码为123"
sleep 5
