#!/bin/sh

#########################################
#
# @author   wangdong@sina.cn
# @date     08/13/2015
# @desc     focus on env preparement
#
#########################################

. $(dirname ${BASH_SOURCE[0]})/../../cdh/script/check.sh
. $(dirname ${BASH_SOURCE[0]})/check.sh
. $(dirname ${BASH_SOURCE[0]})/dependencies.sh

CUR_DIR=$(cd $(dirname ${BASH_SOURCE[0]}) 1>/dev/null;pwd)
COMPONENT=$(basename $(cd ${CUR_DIR}/../ 1>/dev/null;pwd))

ENV_FILE=/home/${USER_NAME}/.bash_profile
source ${ENV_FILE}

for ((i=0; $i<${NODE_HOSTS_CNT}; i=$i+1))
do
    # Copy hive configuration files for SparkSQL with Hive
    /bin/cp -f ${HIVE_HOME}/conf/hive-site.xml ${CUR_DIR}/../conf/

    ssh ${USER_NAME}@${NODE_HOSTS[$i]} "mkdir -p ${PROJECTS_HOME}/${COMPONENT}"
    scp -r ${CUR_DIR}/../../${COMPONENT}/* ${USER_NAME}@${NODE_HOSTS[$i]}:${PROJECTS_HOME}/${COMPONENT}
    ssh ${USER_NAME}@${NODE_HOSTS[$i]} "sh ${PROJECTS_HOME}/${COMPONENT}/script/action.sh ${i}"
done
