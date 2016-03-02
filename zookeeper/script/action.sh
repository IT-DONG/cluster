#!/bin/sh

#########################################
#
# @author   wangdong@sina.cn
# @date     08/23/2015
# @desc     to install zookeeper
#
#########################################

. $(dirname ${BASH_SOURCE[0]})/../../cdh/script/check.sh
. $(dirname ${BASH_SOURCE[0]})/check.sh

CUR_DIR=$(cd $(dirname ${BASH_SOURCE[0]}) 1>/dev/null;pwd)

NODE_IDX="$1"
if [ -z "${NODE_IDX}" ]; then
    echo "[ERROR] Please pass the node index with a integer!"
    exit 1
fi

if [ ${NODE_IDX} -ge ${NODE_HOSTS_CNT} ]; then
    echo "[ERROR] The node index is out of range(${NODE_IDX}>=${NODE_HOSTS_CNT})"
    exit 1
fi

ENV_FILE=/home/${USER_NAME}/.bash_profile
source ${ENV_FILE}

TOOLS_DIR="${CUR_DIR}/../tools/"
cd "${TOOLS_DIR}"

# Extract tar file and import related ENV var
tar -zxvf ${ZOOKEEPER_PACKAGE} 1>/dev/null -C ${INSTALL_HOME}
if [ $? -ne 0 ]; then
    log error "Fail to extract ${ZOOKEEPER_PACKAGE}!"
    exit 1
fi

ZOOKEEPER_PACKAGE_DIR=$(tar -tf $(basename ${HIVE_PACKAGE}) | head -n 1 | tr -d "/")

flag="#####Zookeeper#####"
matched_lines=(`cat ${ENV_FILE} |grep -i -n "${flag}" | tr -d "[a-zA-Z #:]"`)
[ ${#matched_lines[@]} -eq 2 ] && sed -i "${matched_lines[0]},${matched_lines[1]}d" ${ENV_FILE}

echo "${flag}" >> ${ENV_FILE}
echo "export ZOOKEEPER_HOME=\${INSTALL_HOME}/${ZOOKEEPER_PACKAGE_DIR}" >> ${ENV_FILE}
echo 'export PATH=${ZOOKEEPER_HOME}/bin:${PATH}' >> ${ENV_FILE}
echo "${flag}" >> ${ENV_FILE}
source ${ENV_FILE}

# Update zoo.cfg
/bin/cp -f ${ZOOKEEPER_HOME}/conf/zoo_sample.cfg ${ZOOKEEPER_HOME}/conf/zoo.cfg
echo "" >> ${ZOOKEEPER_HOME}/conf/zoo.cfg

k="#maxClientCnxns="
v="maxClientCnxns=60"
sed -i "/^${k}/{n;s|.*|${v}|g}" ${ZOOKEEPER_HOME}/conf/zoo.cfg

k="#autopurge.snapRetainCount="
v="autopurge.snapRetainCount=3"
sed -i "/^${k}/{n;s|.*|${v}|g}" ${ZOOKEEPER_HOME}/conf/zoo.cfg

k="#autopurge.purgeInterval="
v="autopurge.purgeInterval=12"
sed -i "/^${k}/{n;s|.*|${v}|g}" ${ZOOKEEPER_HOME}/conf/zoo.cfg

mkdir -p ${NODE_HOMES[${NODE_IDX}]}/zookeeper

k="dataDir=.*"
v="dataDir=${NODE_HOMES[${NODE_IDX}]}/zookeeper"
sed -i "s|^${k}|${v}|g" ${ZOOKEEPER_HOME}/conf/zoo.cfg

echo $((NODE_IDX+1)) > ${NODE_HOMES[${NODE_IDX}]}/zookeeper/myid

echo "" >> ${ZOOKEEPER_HOME}/conf/zoo.cfg
echo "dataLogDir=${NODE_HOMES[${NODE_IDX}]}/zookeeper" >> ${ZOOKEEPER_HOME}/conf/zoo.cfg

echo "" >> ${ZOOKEEPER_HOME}/conf/zoo.cfg
for ((i=0; $i<${NODE_HOSTS_CNT}; i=$i+1))
do
    echo "server.$((i+1))=${NODE_HOSTS[$i]}:${COMMUNICATE_PORT}:${ELECT_PORT}" >> ${ZOOKEEPER_HOME}/conf/zoo.cfg
done
