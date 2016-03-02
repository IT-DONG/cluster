#!/bin/sh

#########################################
#
# @author   wangdong@sina.cn
# @date     08/13/2015
# @desc     to install CDH env
#
#########################################

. $(dirname ${BASH_SOURCE[0]})/check.sh

CUR_DIR="$(cd $(dirname ${BASH_SOURCE[0]}) 1>/dev/null;pwd)"

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
if [ ! -f ${ENV_FILE} ]; then
    touch ${ENV_FILE}
fi

source ${ENV_FILE}

flag="#####Common#####"
matched_lines=(`cat ${ENV_FILE} |grep -i -n "${flag}" | tr -d "[a-zA-Z #:]"`)
[ ${#matched_lines[@]} -eq 2 ] && sed -i "${matched_lines[0]},${matched_lines[1]}d" ${ENV_FILE}

echo "${flag}" >> ${ENV_FILE}
echo "alias jps='/usr/bin/jps'" >> ${ENV_FILE}
echo "alias findc=\"sh \$HOME/projects/cluster/common/utils/findbycontent.sh\"" >> ${ENV_FILE}
echo "export LANG='en_US.UTF-8'" >> ${ENV_FILE}
echo "export INSTALL_HOME=${INSTALL_HOME}" >> ${ENV_FILE}
echo "${flag}" >> ${ENV_FILE}
source ${ENV_FILE}

# Install JDK
TOOLS_DIR="${CUR_DIR}/../tools/"
cd "${TOOLS_DIR}"

tar -zxvf ${JDK_PACKAGE} 1>/dev/null -C ${INSTALL_HOME}
[ $? -ne 0 ] && echo "[$(date '+%F %T')][ERROR]Fail to extract ${JDK_PACKAGE}!" && exit 1

JDK_PACKAGE_DIR=$(tar -tf $(basename ${JDK_PACKAGE}) | head -n 1 | tr -d "/")

flag="#####JDK#####"
matched_lines=(`cat ${ENV_FILE} |grep -i -n "${flag}" | tr -d "[a-zA-Z #:]"`)
[ ${#matched_lines[@]} -eq 2 ] && sed -i "${matched_lines[0]},${matched_lines[1]}d" ${ENV_FILE}

echo "${flag}" >> ${ENV_FILE}
echo "export JAVA_HOME=\${INSTALL_HOME}/${JDK_PACKAGE_DIR}" >> ${ENV_FILE}
echo 'export CLASSPATH=${JAVA_HOME}/lib:${CLASSPATH}' >> ${ENV_FILE}
echo 'export PATH=${JAVA_HOME}/bin:${PATH}' >> ${ENV_FILE}
echo "${flag}" >> ${ENV_FILE}
source ${ENV_FILE}

# Intall CDH
tar -zxvf ${HADOOP_PACKAGE} 1>/dev/null -C ${INSTALL_HOME}
[ $? -ne 0 ] && echo "[$(date '+%F %T')][ERROR]Fail to extract ${HADOOP_PACKAGE}!" && exit 1

HADOOP_PACKAGE_DIR=$(tar -tf $(basename ${HADOOP_PACKAGE}) | head -n 1 | tr -d "/")

flag="#####CDH#####"
matched_lines=(`cat ${ENV_FILE} |grep -i -n "${flag}" | tr -d "[a-zA-Z #:]"`)
[ ${#matched_lines[@]} -eq 2 ] && sed -i "${matched_lines[0]},${matched_lines[1]}d" ${ENV_FILE}

echo "${flag}" >> ${ENV_FILE}
echo "export HADOOP_HOME=\${INSTALL_HOME}/${HADOOP_PACKAGE_DIR}" >> ${ENV_FILE}
echo 'export PATH=${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${PATH}' >> ${ENV_FILE}
echo 'export CLASSPATH=${HADOOP_HOME}/lib/native:${CLASSPATH}' >> ${ENV_FILE}
echo "${flag}" >> ${ENV_FILE}
source ${ENV_FILE}

# X64 libs
rpm2cpio ${HADOOP_NATIVE_PACKAGE} | cpio -udiv  1>/dev/null
/bin/cp -f ${CUR_DIR}/../tools/usr/lib/hadoop/lib/native/* ${HADOOP_HOME}/lib/native/

# Change the hadoop *.xml files and push them to each node of the cluster
/bin/cp -f ${CUR_DIR}/../conf/core-site.xml.template ${HADOOP_HOME}/etc/hadoop/core-site.xml
/bin/cp -f ${CUR_DIR}/../conf/mapred-site.xml.template ${HADOOP_HOME}/etc/hadoop/mapred-site.xml
/bin/cp -f ${CUR_DIR}/../conf/yarn-site.xml.template ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
/bin/cp -f ${CUR_DIR}/../conf/hdfs-site.xml.template ${HADOOP_HOME}/etc/hadoop/hdfs-site.xml
/bin/cp -f ${CUR_DIR}/../conf/.vimrc ~/

echo ${NODE_HOSTS[@]} | sed "s| |\n|g" | sed "1d" > ${HADOOP_HOME}/etc/hadoop/slaves

k="<name>fs.defaultFS<\/name>"
v="<value>hdfs://${NODE_HOSTS[0]}:8020</value>"
sed -i "/${k}/{n;s|.*|${v}|g}" ${HADOOP_HOME}/etc/hadoop/core-site.xml

k="<name>mapreduce.jobhistory.address<\/name>"
v="<value>${NODE_HOSTS[0]}:10020</value>"
sed -i "/${k}/{n;s|.*|${v}|g}" ${HADOOP_HOME}/etc/hadoop/mapred-site.xml
k="<name>mapreduce.jobhistory.webapp.address<\/name>"
v="<value>${NODE_HOSTS[0]}:8081</value>"
sed -i "/${k}/{n;s|.*|${v}|g}" ${HADOOP_HOME}/etc/hadoop/mapred-site.xml

k="<name>yarn.resourcemanager.hostname<\/name>"
v="<value>${NODE_HOSTS[0]}</value>"
sed -i "/${k}/{n;s|.*|${v}|g}" ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
k="<name>yarn.nodemanager.local-dirs<\/name>"
v="<value>${YARN_LOCALS_PREFIX[1]}</value>"
sed -i "/${k}/{n;s|.*|${v}|g}" ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
k="<name>yarn.nodemanager.log-dirs<\/name>"
v="<value>${YARN_LOGS_PREFIX[1]}</value>"
sed -i "/${k}/{n;s|.*|${v}|g}" ${HADOOP_HOME}/etc/hadoop/yarn-site.xml

k="<name>dfs.namenode.name.dir<\/name>"
v="<value>${NODE_DIRS_PREFIX[0]}</value>"
sed -i "/${k}/{n;s|.*|${v}|g}" ${HADOOP_HOME}/etc/hadoop/hdfs-site.xml
k="<name>dfs.datanode.data.dir<\/name>"
v="<value>${NODE_DIRS_PREFIX[1]}</value>"
sed -i "/${k}/{n;s|.*|${v}|g}" ${HADOOP_HOME}/etc/hadoop/hdfs-site.xml

k="export JAVA_HOME=.*"
v="export JAVA_HOME=${INSTALL_HOME}/${JDK_PACKAGE_DIR}"
sed -i "s|${k}|${v}|g" ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh 

source ${ENV_FILE}
