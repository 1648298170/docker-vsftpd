FROM debian:11

# 用户id
ARG USER_ID=14
# 用户组id
ARG GROUP_ID=100

# 切换apt镜像源
# 设置为中国国内源
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
RUN sed -i 's/security.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

RUN apt-get update
RUN apt-get install -y sudo systemctl

#安装vsftpd,pam,db4
RUN sudo apt-get install -y vsftpd libpam-pwdfile db-util
RUN echo ">>>>>>>vsftpd is successfully installed<<<<<<<<"

# 添加 ftp 用户
RUN usermod -u ${USER_ID} ftp
# 添加 ftp 用户组
RUN groupmod -g ${GROUP_ID} ftp

# 设置为国内时间
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 安装中文字体需要包
RUN apt-get install -y fontconfig
RUN apt-get install -y xfonts-utils

# 复制 vsftpd 配置文件
COPY vsftpd.conf /etc/vsftpd/
# 复制 vsftpd 数据文件
COPY vsftpd_virtual /etc/pam.d/

# 复制入口脚本
COPY run-vsftpd.sh /usr/sbin/
# 给启动文件赋予可执行权限 rwx-r-x-r-x
RUN chmod 755 /usr/sbin/run-vsftpd.sh

RUN mkdir -p /home/vsftpd/
RUN chmod -R a+x /home/vsftpd/
RUN chown -R ftp:ftp /home/vsftpd/

# 暴露 FTP 服务的端口
EXPOSE 20 21

RUN echo ">>>>>>>Finished<<<<<<<<"
# 设置容器启动命令
CMD ["/usr/sbin/run-vsftpd.sh"]
