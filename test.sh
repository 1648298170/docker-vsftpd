docker run -d -v /home/bioeasy/vsftpd:/home/vsftpd \
-p 20:20 -p 21:21 -p 21100-21110:21100-21110 \
-e PASV_ADDRESS=172.16.20.5 -e PASV_MIN_PORT=21100 -e PASV_MAX_PORT=21110 \
--name vsftpd --privileged=true --restart=always fauria/vsftpd


sudo docker run -i -t -d -p 3001:80 --restart=always \
    -v /app/onlyoffice/DocumentServer/logs:/var/log/onlyoffice  \
    -v /app/onlyoffice/DocumentServer/data:/var/www/onlyoffice/Data  \
    -v /app/onlyoffice/DocumentServer/lib:/var/lib/onlyoffice \
    -v /app/onlyoffice/DocumentServer/db:/var/lib/postgresql --name onlyoffice -e JWT_SECRET=hmXnSRFCdS1ZGx22QgKMgL8o2oHwsEa0  onlyoffice/documentserver:latest



cat > yyy << EOF
    local_root=/home/vsftpd/shenlan
    write_enable=YES
    anon_umask=022
    anon_world_readable_only=NO
    anon_upload_enable=YES
    anon_mkdir_write_enable=YES
    anon_other_write_enable=YES
EOF 

[root@eb500ba24a55 pam.d]# cat vsftpd
#%PAM-1.0
#本地用户登录认证
auth    required        pam_userdb.so   db=/etc/vsftpd/virtual_users
account required        pam_userdb.so   db=/etc/vsftpd/virtual_users

#虚拟用户登录验证
session    optional     pam_keyinit.so    force revoke
auth       required     pam_listfile.so item=user sense=deny file=/etc/vsftpd/ftpusers onerr=succeed
auth       required     pam_shells.so
auth       include      password-auth
account    include      password-auth
session    required     pam_loginuid.so
session    include      password-auth