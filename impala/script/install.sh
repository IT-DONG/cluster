#!/bin/sh

#########################################
#
# @author   wangdong@sina.cn
# @date     08/13/2015
# @desc     focus on env preparement
#
#########################################

. $(dirname ${BASH_SOURCE[0]})/../../cdh/script/check.sh

CUR_DIR=$(cd $(dirname ${BASH_SOURCE[0]}) 1>/dev/null;pwd)
COMPONENT=$(basename $(cd ${CUR_DIR}/../;pwd))

for ((i=0; $i<${NODE_HOSTS_CNT}; i=$i+1))
do
    ssh ${USER_NAME}@${NODE_HOSTS[$i]} "mkdir -p ${PROJECTS_HOME}/${COMPONENT}"
    scp -r ${CUR_DIR}/../../${COMPONENT}/* ${USER_NAME}@${NODE_HOSTS[$i]}:${PROJECTS_HOME}/${COMPONENT}

    ssh root@${NODE_HOSTS[$i]} "sh ${PROJECTS_HOME}/${COMPONENT}/script/dependencies.sh ${i}"

    # Since it will take long time to build llvm, impala, thus make the building process backend
    nohup ssh ${USER_NAME}@${NODE_HOSTS[$i]} "sh ${PROJECTS_HOME}/${COMPONENT}/script/action.sh ${i}" 1>nohup.${NODE_HOSTS[$i]}.out 2>&1 &
done
