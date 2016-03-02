#!/bin/sh

#########################################
#
# @author   wangdong@sina.cn
# @date     08/29/2015
# @desc     trust from hadoop to root on
#           each node
#
#########################################

. $(dirname ${BASH_SOURCE[0]})/../../cdh/script/check.sh

CUR_DIR=$(cd $(dirname ${BASH_SOURCE[0]}) 1>/dev/null;pwd)

action="$1"
upper_action=${action^^}
if [ -z "${action}" ] || [[ "${upper_action}" != "GRANT" && "${upper_action}" != "REVOKE" ]]; then
    echo "[ERROR] Invalid action, please input 'grant' or 'revoke'"
    exit 1
fi

ssh_pub="/home/${USER_NAME}/.ssh/id_rsa.pub"
if [ ! -f ${ssh_pub} ]; then
    echo "[ERROR] No such file '${ssh_pub}'"
    exit 1
fi

hadoop_rsa_pub="`cat ${ssh_pub}`"
cmds="mkdir -p /root/.ssh;\
      sed -i 's|${hadoop_rsa_pub}||g' /root/.ssh/authorized_keys;\
      sed -i '/^$/d' /root/.ssh/authorized_keys;"

if [ "${upper_action}" == "GRANT" ]; then
    cmds="${cmds};echo '${hadoop_rsa_pub}' >> /root/.ssh/authorized_keys;"
fi

for ((i=0; $i<${NODE_HOSTS_CNT}; i=$i+1))
do
    ssh root@${NODE_HOSTS[$i]} "${cmds}"
done
