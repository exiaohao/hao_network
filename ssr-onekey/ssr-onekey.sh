#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
workdir=$(cd $(dirname $0); pwd)

#安装目录
ssrdir=/home/ssr/
mkdir -p ${ssrdir}

#判断是否root权限
function rootness(){
    if [[ $EUID -ne 0 ]]; then
        echo "Error:This script must be run as root!" 1>&2
        exit 1
    fi
}
rootness

# Disable selinux
function disable_selinux(){
if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    setenforce 0
fi
}
disable_selinux

# Check OS
function checkos(){
    if [ -f /etc/redhat-release ];then
        OS=CentOS
    elif [ ! -z "`cat /etc/issue | grep bian`" ];then
        OS=Debian
    elif [ ! -z "`cat /etc/issue | grep Ubuntu`" ];then
        OS=Ubuntu
    else
        echo "Not support OS, Please reinstall OS and retry!"
        exit 1
    fi
}
checkos

# Get version
function getversion(){
    if [[ -s /etc/redhat-release ]];then
        grep -oE  "[0-9.]+" /etc/redhat-release
    else    
        grep -oE  "[0-9.]+" /etc/issue
    fi    
}

# CentOS version
function centosversion(){
    local code=$1
    local version="`getversion`"
    local main_ver=${version%%.*}
    if [ $main_ver == $code ];then
        return 0
    else
        return 1
    fi        
}

#安装依赖库
if [ "$OS" == 'CentOS' ]; then
	yum install -y wget unzip openssl-devel gcc swig python python-devel python-setuptools autoconf libtool libevent git ntpdate
	yum install -y m2crypto automake make curl curl-devel zlib-devel perl perl-devel cpio expat-devel gettext-devel
else
	apt-get -y update
	apt-get -y install python python-dev python-pip python-m2crypto curl wget unzip gcc swig automake make perl cpio build-essential git ntpdate
fi
#<<'debugignore'
#安装chacha20的依赖库
##wget -N --no-check-certificate https://raw.githubusercontent.com/91yun/shadowsocks_install/master/libsodium-1.0.12.tar.gz
#本地已下载
tar zfvx libsodium-1.0.12.tar.gz
cd libsodium-1.0.12
./configure
make && make install
echo "include ld.so.conf.d/*.conf" > /etc/ld.so.conf
echo "/lib" >> /etc/ld.so.conf
echo "/usr/lib64" >> /etc/ld.so.conf
echo "/usr/local/lib" >> /etc/ld.so.conf
ldconfig
#cd /root/
rm -r "${workdir}/libsodium-1.0.12"
##rm -rf libsodium-1.0.12.tar.gz libsodium-1.0.12
#debugignore

#安装ssr
#git clone https://github.com/91yun/shadowsocksr-1.git ${ssrdir}
#已下载到本地
unzip -o -d ${ssrdir}  "${workdir}/shadowsocksr-1.zip" 
cd ${ssrdir}
bash setup_cymysql.sh
bash initcfg.sh
sed -i "s/'sspanelv2'/'mudbjson'/g" ${ssrdir}userapiconfig.py
myip=`curl myip.ipip.net | awk -F "：" '{print $2}' | awk '{print $1}'`
sed -i "s/127.0.0.1/$myip/g" ${ssrdir}userapiconfig.py

#下载服务文件，添加到系统服务，并随机启动
if [ "$OS" == 'CentOS' ]; then
	#if ! wget --no-check-certificate https://raw.githubusercontent.com/91yun/shadowsocks_install/master/ssr -O /etc/init.d/ssr; then
    if ! cp "${workdir}/ssr" /etc/init.d/ssr; then
		echo "Failed to download ssr chkconfig file!"
		exit 1
	fi
else
	#if ! wget --no-check-certificate https://raw.githubusercontent.com/91yun/shadowsocks_install/master/ssr-debian -O /etc/init.d/ssr; then
    if ! cp "${workdir}/ssr-debian" /etc/init.d/ssr; then
		echo "Failed to download ssr chkconfig file!"
		exit 1
	fi
fi

sed -i "s@BIN=.*@BIN=$ssrdir@g" /etc/init.d/ssr

cp /etc/init.d/ssr /bin/


chmod +x /etc/init.d/ssr
chmod +x /bin/ssr
if [ "$OS" == 'CentOS' ]; then
	chkconfig --add ssr
	chkconfig ssr on
else
	update-rc.d -f ssr defaults
fi

#下载定制脚本到目录
#if ! wget --no-check-certificate https://raw.githubusercontent.com/91yun/shadowsocks_install/master/ssr.sh -O ${ssrdir}ssr.sh; then
if ! cp "${workdir}/ssr.sh" ${ssrdir}ssr.sh; then
	echo "Failed to download ssr script file!"
	exit 1
fi
sed -i "s@ssrdir=.*@ssrdir=$ssrdir@g" ${ssrdir}ssr.sh


#启动定制脚本开始添加用户
ssr start
ssr adduser
ssr restart
