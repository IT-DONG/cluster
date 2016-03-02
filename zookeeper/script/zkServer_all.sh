#!/bin/sh

. $(dirname ${BASH_SOURCE[0]})/../../cdh/script/check.sh

CUR_DIR=$(cd $(dirname ${BASH_SOURCE[0]}) 1>/dev/null;pwd)

ENV_FILE=/home/${USER_NAME}/.bash_profile
source ${ENV_FILE}

action="$1"

if [ -z "${action}" ] || [[ "${action^^}" != "START" && "${action^^}" != "STOP" && "${action^^}" != "RESTART" && "${action^^}" != "STATUS" ]]; then
    echo "[ERROR] The action type is invalid, please input start/stop/restart/status!"
    exit 1
fi

if [ "${action^^}" == "STATUS" ]; then
    for ((i=0; $i<${NODE_HOSTS_CNT}; i=$i+1))
    do
        echo ${NODE_HOSTS[$i]}
        ssh ${USER_NAME}@${NODE_HOSTS[$i]} "source ~/.bash_profile; zkServer.sh status;"
        echo "---------------------------"
    done
else
    # Stop all zk instances first whatever action is
    for ((i=0; $i<${NODE_HOSTS_CNT}; i=$i+1))
    do
        ssh ${USER_NAME}@${NODE_HOSTS[$i]} "source ~/.bash_profile; zkServer.sh stop;"
    done

    # Start zk instances
    for ((i=0; $i<${NODE_HOSTS_CNT}; i=$i+1))
    do
        if [[ ${action^^} == "START" || ${action^^} == "RESTART" ]]; then
            ssh ${USER_NAME}@${NODE_HOSTS[$i]} "source ~/.bash_profile; zkServer.sh start;"
        fi
    done
fi
