#!/bin/sh

###############################################################################
# @author   wangdong@sina.cn
# @date     02/06/2015
# @desc     Configuration for hive installation
###############################################################################

# The URL to down the hive installation package, NOTE that hive version should be against the same version of hadoop
# configured in the ../../cdh/scripts/configs.h
# HIVE_PACKAGE_DL_URL=http://archive.cloudera.com/cdh5/cdh/5/hive-1.1.0-cdh5.5.1.tar.gz
HIVE_PACKAGE_DL_URL=

# MySQL Driver for hive
# MYSQL_CONNECTOR_URL=http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.38.tar.gz
MYSQL_CONNECTOR_URL=

# HDFS path for Hive storage
# HIVE_ROOT=/path/for/hive/dw
HIVE_ROOT=

# MySQL HOST
# MYSQL_HOST=hostname
MYSQL_HOST=

# MySQL root password
# MYSQL_ROOT_PWD=test
MYSQL_ROOT_PWD=

# Hive meta database name
# HIVE_META_DATABASE=hive_metastore
HIVE_META_DATABASE=

# User name for Hive to connect MySQL
# HIVE_META_USER=hive
HIVE_META_USER=

# Password for MYSQL_CONNECTOR_URL to connect MySQL
# HIVE_META_USER_PWD=hadoophive
HIVE_META_USER_PWD=

# In ${HIVE_HOME}/scripts/metastore/upgrade/mysql/, choose hive schema sql for the installed hive version
# HIVE_META_SQL=hive-schema-1.1.0.mysql.sql
HIVE_META_SQL=
