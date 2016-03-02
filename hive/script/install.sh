#!/bin/sh

###############################################################################
#
# @author   wangdong@sina.cn
# @date     08/13/2015
# @desc     focus on env preparement
#
###############################################################################

. $(dirname ${BASH_SOURCE[0]})/../../cdh/script/check.sh
. $(dirname ${BASH_SOURCE[0]})/check.sh
. $(dirname ${BASH_SOURCE[0]})/dependencies.sh

CUR_DIR=$(cd $(dirname ${BASH_SOURCE[0]}) 1>/dev/null;pwd)
COMPONENT=$(basename $(cd ${CUR_DIR}/../ 1>/dev/null;pwd))

for ((i=0; $i<${NODE_HOSTS_CNT}; i=$i+1))
do
    if [ $i -gt 0 ]; then
        continue
    fi

    ssh ${USER_NAME}@${NODE_HOSTS[$i]} "mkdir -p ${PROJECTS_HOME}/${COMPONENT}"
    scp -r ${CUR_DIR}/../../${COMPONENT}/* ${USER_NAME}@${NODE_HOSTS[$i]}:${PROJECTS_HOME}/${COMPONENT}
    ssh ${USER_NAME}@${NODE_HOSTS[$i]} "sh ${PROJECTS_HOME}/${COMPONENT}/script/action.sh ${i}"
    if [ $? -ne 0 ]; then
        log error "Fail to execute action.sh on ${NODE_HOSTS[$i]}"
        exit 1
    fi
done
