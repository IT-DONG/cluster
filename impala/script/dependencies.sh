#!/bin/sh

#########################################
#
# @author   wangdong@sina.cn
# @date     08/27/2015
# @desc     to install boost, cmake, and etc.
#           with root account
#
#########################################

. $(dirname ${BASH_SOURCE[0]})/../../cdh/script/check.sh
. $(dirname ${BASH_SOURCE[0]})/check.sh

CUR_DIR=$(cd $(dirname ${BASH_SOURCE[0]}) 1>/dev/null;pwd)

ENV_FILE=$HOME/.bash_profile
source ${ENV_FILE}

if [ `whoami` != "root" ]; then
    echo "[ERROR] Please use root account to install the following dependencies!"
    exit 1
fi

# Install dependencies, remove Boost which is <=1.41
yum groupinstall "Development Tools"

yum -y install git ant libevent-devel automake libtool flex bison gcc-c++ openssl-devel make cmake doxygen.x86_64 glib-devel python-devel bzip2-devel svn libevent-devel krb5-workstation openldap-devel db4-devel python-setuptools python-pip cyrus-sasl* postgresql postgresql-server ant-nodeps lzo-devel lzop

easy_install pip

pip install allpairs pytest pytest-xdist paramiko texttable prettytable sqlparse psutil==0.7.1 pywebhdfs gitpython jenkinsapi sasl

# Install Boost(version>=1.42)
old_boost_libs=`rpm -qa | egrep "boost.*1\.4[01]"`
if [[ ! -z "${old_boost_libs}" || ! -d /usr/include/boost/ || `ls /usr/lib64/libboost_* | wc -l` -eq 0 || `ls /usr/include/boost/ | wc -l` -eq 0 ]]; then
    rpm -e ${old_boost_libs}

    TOOLS_DIR="${CUR_DIR}/../tools/"
    cd "${TOOLS_DIR}"

    tar -zxvf ${BOOST_PACKAGE_VER} 1>/dev/null

    cd ${BOOST_PACKAGE_DIR}

    sh ./bootstrap.sh
    ./bjam --libdir=/usr/lib64 --includedir=/usr/include threading=multi --layout=tagged install cxxflags=-fPIC

    #./bootstrap.sh --prefix=path/to/installation/prefix
    #./b2 --toolset=gcc threading=multi --layout=tagged --build-type=complete --with-regex --with-system --with-thread --with-filesystem --with-date_time install
fi
