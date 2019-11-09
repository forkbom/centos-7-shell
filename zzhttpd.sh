#!/bin/bash
#安装vsftpd利用sed 来修改vsftpd配置文件
yum -y install vsftpd
sed -i 's/#anon_upl/anon_upl/' /etc/vsftpd/vsftpd.conf
#sed '/#anon_u/s/#//' /etc/vsftpd/vsftpd.conf
systemctl restart vsftpd
systemctl enable vsftpd
chmod o+w /var/ftp/pub
