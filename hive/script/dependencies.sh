#!/bin/sh

#########################################
#
# @author   wangdong@sina.cn
# @date     2016/02/06
# @desc     focus on hive dependencies
#
#########################################

. $(dirname ${BASH_SOURCE[0]})/../../cdh/script/check.sh
. $(dirname ${BASH_SOURCE[0]})/check.sh

CUR_DIR=$(cd $(dirname ${BASH_SOURCE[0]}) 1>/dev/null;pwd)

###############################################################################
# 1. Check whether we can connect MySQL or not
###############################################################################
mysql -u${HIVE_META_USER} -p${HIVE_META_USER_PWD} -h${MYSQL_HOST} -e"show databases;"
if [ $? -ne 0 ]; then
    mysql -uroot -p${MYSQL_ROOT_PWD} -h${MYSQL_HOST} -e"show databases;"
    if [ $? -eq 0 ]; then
        #echo "DROP DATABASE ${HIVE_META_DATABASE};CREATE DATABASE IF NOT EXISTS ${HIVE_META_DATABASE};" > ${CUR_DIR}/metastore.sql
        echo "CREATE DATABASE IF NOT EXISTS ${HIVE_META_DATABASE};" > ${CUR_DIR}/metastore.sql
        echo "USE ${HIVE_META_DATABASE};" >> ${CUR_DIR}/metastore.sql
        echo "SOURCE ${HIVE_META_SQL}" >> ${CUR_DIR}/metastore.sql
        echo "DROP USER '${HIVE_META_USER}'@'localhost';" >> ${CUR_DIR}/metastore.sql
        echo "DROP USER '${HIVE_META_USER}'@'%';" >> ${CUR_DIR}/metastore.sql
        echo "FLUSH PRIVILEGES;" >> ${CUR_DIR}/metastore.sql
        echo "CREATE USER '${HIVE_META_USER}'@'%' IDENTIFIED BY '${HIVE_META_USER_PWD}';" >> ${CUR_DIR}/metastore.sql
        echo "CREATE USER '${HIVE_META_USER}'@'localhost' IDENTIFIED BY '${HIVE_META_USER_PWD}';" >> ${CUR_DIR}/metastore.sql
        echo "GRANT ALL ON ${HIVE_META_DATABASE}.* TO '${HIVE_META_USER}'@'%';" >> ${CUR_DIR}/metastore.sql
        echo "GRANT ALL ON ${HIVE_META_DATABASE}.* TO '${HIVE_META_USER}'@'localhost';" >> ${CUR_DIR}/metastore.sql
        echo "FLUSH PRIVILEGES;" >> ${CUR_DIR}/metastore.sql
        echo "SET SESSION binlog_format = 'MIXED';" >> ${CUR_DIR}/metastore.sql
        echo "SET GLOBAL binlog_format = 'MIXED';" >> ${CUR_DIR}/metastore.sql

        cd ${HIVE_HOME}/scripts/metastore/upgrade/mysql/
        mysql -uroot -p${MYSQL_ROOT_PWD} < ${CUR_DIR}/metastore.sql 
        if [ $? -ne 0 ]; then
            log error "Fail to create hive schema on ${MYSQL_HOST} with root!"
            exit 1
        fi
    else
        log error "Cannot connect to ${MYSQL_HOST} with root!"
        exit 1
    fi
fi

###############################################################################
# 2. Download the installation packages
###############################################################################
dl_files "${ALL_PACKAGES}" "${PACKAGES_DL_DIR}"
if [ $? -ne 0 ]; then
    log error "Fail to download ${ALL_PACKAGES}"
    exit 1
fi
