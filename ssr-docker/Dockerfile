FROM ubuntu:16.04

WORKDIR /opt
ADD . /opt

RUN sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

RUN apt-get -y update
RUN apt-get -y install tzdata python python-dev python-pip python-m2crypto curl wget unzip gcc swig automake make perl cpio build-essential git ntpdate

RUN echo "Asia/Shanghai" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

RUN tar zfvx libsodium-1.0.12.tar.gz
WORKDIR /opt/libsodium-1.0.12
RUN ./configure
RUN ./make && ./make install
