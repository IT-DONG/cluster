#!/bin/sh

#########################################
#
# @author   wangdong@sina.cn
# @date     08/24/2015
# @desc     to install impala
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

#--------------------------- install mvn -------------------------
tar zxvf ${MVN_PACKAGE_VER} -C ${INSTALL_HOME} 1>/dev/null

flag="#####Maven#####"
matched_lines=(`cat ${ENV_FILE} |grep -i -n "${flag}" | tr -d "[a-zA-Z #:]"`)
[ ${#matched_lines[@]} -eq 2 ] && sed -i "${matched_lines[0]},${matched_lines[1]}d" ${ENV_FILE}

echo "${flag}" >> ${ENV_FILE}
echo "export PATH=\${INSTALL_HOME}/${MVN_PACKAGE_DIR}/bin:\${PATH}" >> ${ENV_FILE}
echo "${flag}" >> ${ENV_FILE}
source ${ENV_FILE}

#--------------------------- install llvm -------------------------
tar xvf ${LLVM_PACKAGE_VER} 1>/dev/null
cd ${LLVM_PACKAGE_DIR}/tools/
svn co http://llvm.org/svn/llvm-project/cfe/tags/RELEASE_33/final/ clang
cd ../projects/
svn co http://llvm.org/svn/llvm-project/compiler-rt/tags/RELEASE_33/final
cd ..
./configure --with-pic --prefix=${INSTALL_HOME}/${LLVM_PACKAGE_DIR}
make -j4 REQUIRES_RTTI=1 && make install

[ $? -ne 0 ] && exit 1

flag="#####LLVM#####"
matched_lines=(`cat ${ENV_FILE} |grep -i -n "${flag}" | tr -d "[a-zA-Z #:]"`)
[ ${#matched_lines[@]} -eq 2 ] && sed -i "${matched_lines[0]},${matched_lines[1]}d" ${ENV_FILE}

echo "${flag}" >> ${ENV_FILE}
echo "export LLVM_HOME=\${INSTALL_HOME}/${LLVM_PACKAGE_DIR}" >> ${ENV_FILE}
echo "export PATH=\${LLVM_HOME}/bin:\$PATH" >> ${ENV_FILE}
echo "export LD_LIBRARY_PATH=\${LLVM_HOME}/lib:\${LD_LIBRARY_PATH}" >> ${ENV_FILE}
echo "${flag}" >> ${ENV_FILE}
source ${ENV_FILE}

#--------------------------- install impala -------------------------
cd "${TOOLS_DIR}"
tar -zxvf ${IMPALA_PACKAGE_VER} -C ${INSTALL_HOME} 1>/dev/null
cd ${INSTALL_HOME}/${IMPALA_PACKAGE_DIR}
mkdir -p logs

# Update the cmake file since there is something wrong
sed -i "s|-lboost_date_time.*|-lboost_date_time-mt|g" be/CMakeLists.txt

./buildall.sh -noclean -skiptests -build_shared_libs

[ $? -ne 0 ] && exit 1

k="# limitations under the License"
v="\nsource impala-config.sh >/dev/null"
sed -i "/${k}/a\\${v}" bin/impala-shell.sh

k="CLASSPATH="
v="\$IMPALA_HOME/fe/target/impala-frontend-0.1-SNAPSHOT.jar:\\"
sed -i "/^${k}/a\\${v}\\" bin/set-classpath.sh

v="\${HADOOP_HOME}/etc/hadoop:\\"
sed -i "/^${k}/a\\${v}\\" bin/set-classpath.sh

if [ ${NODE_IDX} -eq 0 ]; then
    v="\${HIVE_HOME}/conf:\\"
    sed -i "/^${k}/a\\${v}\\" bin/set-classpath.sh
fi

flag="#####Impala#####"
matched_lines=(`cat ${ENV_FILE} |grep -i -n "${flag}" | tr -d "[a-zA-Z #:]"`)
[ ${#matched_lines[@]} -eq 2 ] && sed -i "${matched_lines[0]},${matched_lines[1]}d" ${ENV_FILE}

echo "${flag}" >> ${ENV_FILE}
echo "export IMPALA_HOME=\${INSTALL_HOME}/${IMPALA_PACKAGE_DIR}" >> ${ENV_FILE}
echo "export PATH=\${IMPALA_HOME}/bin:\$PATH" >> ${ENV_FILE}
echo "alias impala-shell='impala-shell.sh'" >> ${ENV_FILE}
echo "${flag}" >> ${ENV_FILE}
source ${ENV_FILE}
