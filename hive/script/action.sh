#!/bin/sh

#########################################
#
# @author   wangdong@sina.cn
# @date     08/13/2015
# @desc     to install CDH env
#
#########################################

. $(dirname ${BASH_SOURCE[0]})/../../cdh/script/check.sh
. $(dirname ${BASH_SOURCE[0]})/check.sh

CUR_DIR="$(cd $(dirname ${BASH_SOURCE[0]}) 1>/dev/null;pwd)"

ENV_FILE=/home/${USER_NAME}/.bash_profile
source ${ENV_FILE}

# Install JDK
TOOLS_DIR="${CUR_DIR}/../tools/"
cd "${TOOLS_DIR}"

# Create neccessary directory
hadoop fs -mkdir -p ${HIVE_ROOT}

# Extract hive tar file and import related ENV var
tar -zxvf ${HIVE_PACKAGE} 1>/dev/null -C ${INSTALL_HOME}
if [ $? -ne 0 ]; then
    log error "Fail to extract ${HIVE_PACKAGE}!"
    exit 1
fi

HIVE_PACKAGE_DIR=$(tar -tf $(basename ${HIVE_PACKAGE}) | head -n 1 | tr -d "/")

flag="#####Hive#####"
matched_lines=(`cat ${ENV_FILE} |grep -i -n "${flag}" | tr -d "[a-zA-Z #:]"`)
[ ${#matched_lines[@]} -eq 2 ] && sed -i "${matched_lines[0]},${matched_lines[1]}d" ${ENV_FILE}

echo "${flag}" >> ${ENV_FILE}
echo "export HIVE_HOME=\${INSTALL_HOME}/${HIVE_PACKAGE_DIR}" >> ${ENV_FILE}
echo 'export CLASSPATH=${HIVE_HOME}/lib:${CLASSPATH}' >> ${ENV_FILE}
echo 'export PATH=${HIVE_HOME}/bin:${PATH}' >> ${ENV_FILE}
echo "${flag}" >> ${ENV_FILE}
source ${ENV_FILE}

# Update hive-site.xml
/bin/cp -f ${CUR_DIR}/../conf/hive-site.xml.template ${HIVE_HOME}/conf/hive-site.xml
k="<name>javax.jdo.option.ConnectionURL<\/name>"
v="<value>jdbc:mysql://${NODE_HOSTS[0]}/${HIVE_META_DATABASE}</value>"
sed -i "/${k}$/{n;s|.*|${v}|g}" ${HIVE_HOME}/conf/hive-site.xml

k="<name>hive.metastore.warehouse.dir<\/name>"
v="<value>${HIVE_ROOT}</value>"
sed -i "/${k}$/{n;s|.*|${v}|g}" ${HIVE_HOME}/conf/hive-site.xml

k="<name>hive.metastore.uris<\/name>"
v="<value>thrift://${NODE_HOSTS[0]}:9083</value>"
sed -i "/${k}$/{n;s|.*|${v}|g}" ${HIVE_HOME}/conf/hive-site.xml

k="<name>javax.jdo.option.ConnectionUserName<\/name>"
v="<value>${HIVE_META_USER}</value>"
sed -i "/${k}$/{n;s|.*|${v}|g}" ${HIVE_HOME}/conf/hive-site.xml

k="<name>javax.jdo.option.ConnectionPassword<\/name>"
v="<value>${HIVE_META_USER_PWD}</value>"
sed -i "/${k}$/{n;s|.*|${v}|g}" ${HIVE_HOME}/conf/hive-site.xml

k="<name>hive.zookeeper.quorum<\/name>"
v="<value>`echo ${NODE_HOSTS[@]} | sed 's| |,|g'`</value>"
sed -i "/${k}$/{n;s|.*|${v}|g}" ${HIVE_HOME}/conf/hive-site.xml

# Update hive-env.sh
/bin/cp -f ${CUR_DIR}/../conf/hive-env.sh.template ${HIVE_HOME}/conf/hive-env.sh
k="# HADOOP_HOME"
v="HADOOP_HOME=${HADOOP_HOME}"
sed -i "/^${k}/{n;s|.*|${v}|g}" ${HIVE_HOME}/conf/hive-env.sh

k="# export HIVE_CONF_DIR="
v="export HIVE_CONF_DIR=${HIVE_HOME}/conf"
sed -i "/^${k}/{n;s|.*|${v}|g}" ${HIVE_HOME}/conf/hive-env.sh

k="# export HIVE_AUX_JARS_PATH="
v="export HIVE_AUX_JARS_PATH=${HIVE_HOME}/lib"
sed -i "/^${k}/{n;s|.*|${v}|g}" ${HIVE_HOME}/conf/hive-env.sh

# Update hive log
/bin/cp -f ${HIVE_HOME}/conf/hive-log4j.properties.template ${HIVE_HOME}/conf/hive-log4j.properties
k="hive.log.dir=.*"
v="hive.log.dir=${HIVE_HOME}/logs/\${usr.name}"
sed -i "s|^${k}|${v}|g" ${HIVE_HOME}/conf/hive-log4j.properties

/bin/cp -f ${CUR_DIR}/../tools/${MYSQL_CONNECTOR_JAR} ${HIVE_HOME}/lib
