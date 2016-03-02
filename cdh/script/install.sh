#!/bin/sh

###############################################################################
#
# @author   wangdong@sina.cn
# @date     08/13/2015
# @desc     focus on env preparement
#
###############################################################################


###############################################################################
# On namenode only, please try to update JAVA_HEAP_MAX=-Xmx4000m in 
# vi /usr/lib/hadoop/libexec/hadoop-config.sh or $SOME_PATH/hadoop-env.sh
# in case that the error "Namenode failed while loading fsimage with GC overhead limit exceeded"
###############################################################################

. $(dirname ${BASH_SOURCE[0]})/check.sh
. $(dirname ${BASH_SOURCE[0]})/dependencies.sh

CUR_DIR=$(cd $(dirname ${BASH_SOURCE[0]}) 1>/dev/null;pwd)
COMPONENT=$(basename $(cd ${CUR_DIR}/../ 1>/dev/null;pwd))

for ((i=0; $i<${NODE_HOSTS_CNT}; i=$i+1))
do
    scp -r ${CUR_DIR}/../../common/* ${USER_NAME}@${NODE_HOSTS[$i]}:${PROJECTS_HOME}/common
    scp -r ${CUR_DIR}/../../${COMPONENT}/* ${USER_NAME}@${NODE_HOSTS[$i]}:${PROJECTS_HOME}/${COMPONENT}
    sudo -u${USER_NAME} ssh ${USER_NAME}@${NODE_HOSTS[$i]} "sh ${PROJECTS_HOME}/${COMPONENT}/script/action.sh ${i}"
    if [ $? -ne 0 ]; then
        log error "Fail to execute action.sh on ${NODE_HOSTS[$i]}"
        exit 1
    fi
done
