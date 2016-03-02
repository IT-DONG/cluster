#!/bin/sh

#########################################
#
# @author   wangdong@sina.cn
# @date     08/24/2015
# @desc     to install Spark
#
#########################################

. $(dirname ${BASH_SOURCE[0]})/../../cdh/script/check.sh
. $(dirname ${BASH_SOURCE[0]})/check.sh

CUR_DIR=$(cd $(dirname ${BASH_SOURCE[0]}) 1>/dev/null;pwd)

ENV_FILE=/home/${USER_NAME}/.bash_profile
source ${ENV_FILE}

# Create directory
mkdir -p /tmp/spark-events

# Install Spark
TOOLS_DIR="${CUR_DIR}/../tools/"
cd "${TOOLS_DIR}"

tar -zxvf ${SPARK_PACKAGE} 1>/dev/null -C ${INSTALL_HOME}
if [ $? -ne 0 ]; then
    log error "Fail to extract ${SPARK_PACKAGE}!"
    exit 1
fi

SPARK_PACKAGE_DIR=$(tar -tf $(basename ${HIVE_PACKAGE}) | head -n 1 | tr -d "/")

flag="#####Spark#####"
matched_lines=(`cat ${ENV_FILE} |grep -i -n "${flag}" | tr -d "[a-zA-Z #:]"`)
[ ${#matched_lines[@]} -eq 2 ] && sed -i "${matched_lines[0]},${matched_lines[1]}d" ${ENV_FILE}

echo "${flag}" >> ${ENV_FILE}
echo "export SPARK_HOME=\${INSTALL_HOME}/${SPARK_PACKAGE_DIR}" >> ${ENV_FILE}
echo 'export CLASSPATH=${SPARK_HOME}/lib:${CLASSPATH}' >> ${ENV_FILE}
echo 'export PATH=${SPARK_HOME}/bin:${SPARK_HOME}/sbin:${PATH}' >> ${ENV_FILE}
echo "${flag}" >> ${ENV_FILE}
source ${ENV_FILE}

/bin/cp -f ${SPARK_HOME}/conf/spark-defaults.conf.template ${SPARK_HOME}/conf/spark-defaults.conf
/bin/cp -f ${SPARK_HOME}/conf/spark-env.sh.template ${SPARK_HOME}/conf/spark-env.sh
/bin/cp -f ${SPARK_HOME}/conf/slaves.template ${SPARK_HOME}/conf/slaves

echo "export HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop" >> ${SPARK_HOME}/conf/spark-env.sh
echo "export YARN_CONF_DIR=${HADOOP_HOME}/etc/hadoop" >> ${SPARK_HOME}/conf/spark-env.sh
echo "export SPARK_MASTER=${NODE_HOSTS[0]}" >> ${SPARK_HOME}/conf/spark-env.sh
echo "export SPARK_MASTER_PORT=${SPARK_MASTER_PORT}" >> ${SPARK_HOME}/conf/spark-env.sh
echo "export SPARK_MASTER_OPTS+=' -Dspark.deploy.defaultCores=${SPARK_WORKER_CORES}'" >> ${SPARK_HOME}/conf/spark-env.sh
echo "export SPARK_MASTER_WEBUI_PORT=${SPARK_MASTER_WEBUI_PORT}" >> ${SPARK_HOME}/conf/spark-env.sh
echo "export SPARK_WORKER_WEBUI_PORT=${SPARK_WORKER_WEBUI_PORT}" >> ${SPARK_HOME}/conf/spark-env.sh
echo "export SPARK_WORKER_INSTANCES=${SPARK_WORKER_INSTANCES}" >> ${SPARK_HOME}/conf/spark-env.sh
echo "export SPARK_WORKER_CORES=${SPARK_WORKER_CORES}" >> ${SPARK_HOME}/conf/spark-env.sh
echo "export SPARK_WORKER_MEMORY=${SPARK_WORKER_MEMORY}" >> ${SPARK_HOME}/conf/spark-env.sh
echo "export SPARK_EXECUTOR_MEMORY=${SPARK_EXECUTOR_MEMORY}" >> ${SPARK_HOME}/conf/spark-env.sh
echo "export SPARK_DRIVER_MEMORY=${SPARK_DRIVER_MEMORY}" >> ${SPARK_HOME}/conf/spark-env.sh

echo ${NODE_HOSTS[@]} | sed "s| |\n|g" | sed "1d" > ${SPARK_HOME}/conf/slaves

echo "spark.master            spark://${NODE_HOSTS[0]}:${SPARK_MASTER_PORT}" >> ${SPARK_HOME}/conf/spark-defaults.conf
echo "spark.eventLog.enabled  true" >> ${SPARK_HOME}/conf/spark-defaults.conf
echo "spark.serializer        org.apache.spark.serializer.KryoSerializer" >> ${SPARK_HOME}/conf/spark-defaults.conf

# Copy hive-site.xml to $SPARK_HOME/conf
/bin/cp -f ${CUR_DIR}/../conf/hive-site.xml ${SPARK_HOME}/conf/
