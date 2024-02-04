#!/bin/bash

# 给中文字体执行权限，给予索引，更新缓存
chmod -R 755 /usr/share/fonts/Chinese
mkfontscale
mkfontdir
fc-cache

FTP_USER='admin'
FTP_PASS='admin123'

chmod -R a+x /etc/vsftpd
chmod -R a+x /etc/pam.d
chmod -R a+x /var/log/vsftpd

# If no env var for FTP_USER has been specified, use 'admin':
if [ "$FTP_USER" = "**String**" ]; then
    export FTP_USER='admin'
    useradd -c ${FTP_USER} -d /home/vsftpd -m -g ftp  -s /bin/bash -u 100 ${FTP_USER}
fi

# If no env var has been specified, generate a random password for FTP_USER:
if [ "$FTP_PASS" = "**Random**" ]; then
    # export FTP_PASS=`cat /dev/urandom | tr -dc A-Z-a-z-0-9 | head -c${1:-16}`
    export FTP_PASS="admin123"
fi

echo -e "${FTP_USER}\n${FTP_PASS}" > /etc/vsftpd/virtual_users.txt
/usr/bin/db_load -T -t hash -f /etc/vsftpd/virtual_users.txt /etc/vsftpd/virtual_users.db

Get log file path
export LOG_FILE=`grep xferlog_file /etc/vsftpd/vsftpd.conf|cut -d= -f2`

stdout server info:
if [ ! $LOG_STDOUT ]; then
cat << EOB
	*************************************************
	*                                               *
	*    Docker image: fauria/vsftpd                *
	*    https://github.com/fauria/docker-vsftpd    *
	*                                               *
	*************************************************

	SERVER SETTINGS
	---------------
	· FTP User: $FTP_USER
	· FTP Password: $FTP_PASS
	· Log file: $LOG_FILE
	· Redirect vsftpd log to STDOUT: No.
EOB
else
    /usr/bin/ln -sf /dev/stdout $LOG_FILE
fi

# chown -R ftp:ftp /home/vsftpd/

# Set passive mode parameters:
if [ "$PASV_ADDRESS" = "**IPv4**" ]; then
    export PASV_ADDRESS=$(/sbin/ip route|awk '/default/ { print $3 }')
    echo "pasv_address=${PASV_ADDRESS}" >> /etc/vsftpd/vsftpd.conf
fi

Run vsftpd:
&>/dev/null /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
# /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf