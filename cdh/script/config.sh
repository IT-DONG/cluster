#!/bin/sh

###############################################################################
# @author   wangdong@sina.cn
# @date     02/06/2015
# @desc     Configuration for CDH installation
###############################################################################

# The hostname for all nodes
# NODE_HOSTS=(
#                 test.master.com
#                 test.slave1.com
#                 test.slave2.com
#            )
NODE_HOSTS=

# The username to be created for the cluster
USER_NAME=hadoop

# The main directory for all hadoop-related component
# NODE_HOMES=(
#            "/home/${USER_NAME}/cdh"
#            "/home/${USER_NAME}/cdh"
#            "/home/${USER_NAME}/cdh"
#           )
NODE_HOMES=

# It will append to the NODE_HOME above repectively
# NODE_ROOTS=(
#                 "/home/disk1"
#                 "/home/disk1 /home/disk2 /home/disk3"
#                 "/home/disk1 /home/disk2 /home/disk3"
#            )
NODE_ROOTS=

YARN_LOCAL_DIR=hadoop/yarn/local
YARN_LOG_DIR=hadoop/yarn/log
NN_DIR=hadoop/namenode
DN_DIR=hadoop/datanode

# Packages
# HADOOP_NATIVE_PACKAGE_DL_URL=http://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/5.5.1/RPMS/x86_64/hadoop-2.6.0+cdh5.5.1+924-1.cdh5.5.1.p0.15.el6.x86_64.rpm
HADOOP_NATIVE_PACKAGE_DL_URL=

#HADOOP_PACKAGE_DL_URL=http://archive.cloudera.com/cdh5/cdh/5/hadoop-2.6.0-cdh5.4.4.tar.gz
HADOOP_PACKAGE_DL_URL=

#JDK_PACKAGE_DL_URL=http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.tar.gz
JDK_PACKAGE_DL_URL=

# Temporary directory and tool target install directory
PROJECTS_HOME=/home/${USER_NAME}/projects/cluster
INSTALL_HOME=/home/${USER_NAME}/tools
