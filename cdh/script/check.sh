#!/bin/sh

###############################################################################
# @author   wangdong@sina.cn
# @date     02/06/2015
# @desc     Configuration for CDH installation
###############################################################################

. $(dirname ${BASH_SOURCE[0]})/config.sh
. $(dirname ${BASH_SOURCE[0]})/../../common/utils/util.sh

CUR_DIR=$(cd $(dirname ${BASH_SOURCE[0]}) 1>/dev/null;pwd)

###############################################################################
# Validation section
###############################################################################
get_unset_vars "${CUR_DIR}/config.sh"
[ $? -ne 0 ] && exit 1

###############################################################################
# Calculation section
###############################################################################
NODE_HOSTS_CNT=${#NODE_HOSTS[@]}

NODE_HOMES_CNT=${#NODE_HOMES[@]}

NODE_ROOTS_CNT=${#NODE_ROOTS[@]}

HADOOP_NATIVE_PACKAGE=${HADOOP_NATIVE_PACKAGE_DL_URL##*/}

HADOOP_PACKAGE=${HADOOP_PACKAGE_DL_URL##*/}

JDK_PACKAGE=${JDK_PACKAGE_DL_URL##*/}

NODE_DIRS=()
NODE_DIRS_PREFIX=()
YARN_LOCALS=()
YARN_LOCALS_PREFIX=()
YARN_LOGS=()
YARN_LOGS_PREFIX=()
for ((i=0; $i<${NODE_ROOTS_CNT}; i=$i+1))
do
    node_dir=""
    node_dir_prefix=""
    yarn_local=""
    yarn_local_prefix=""
    yarn_log=""
    yarn_log_prefix=""
    if [ $i -eq 0 ]; then
        node_dir=$(echo ${NODE_ROOTS[$i]} | sed "s|[ ]+| |g" | sed "s|$|/${NN_DIR}|g" | sed "s| |/${NN_DIR} |g")
        node_dir_prefix=$(echo ${node_dir} | sed "s|^|file://|g" | sed "s| |,file://|g")
    else
        node_dir=$(echo ${NODE_ROOTS[$i]} | sed "s|[ ]+| |g" | sed "s|$|/${DN_DIR}|g" | sed "s| |/${DN_DIR} |g")
        node_dir_prefix=$(echo ${node_dir} | sed "s|^|file://|g" | sed "s| |,file://|g")

        yarn_local=$(echo ${NODE_ROOTS[$i]} | sed "s|[ ]+| |g" | sed "s|$|/${YARN_LOCAL_DIR}|g" | sed "s| |/${YARN_LOCAL_DIR} |g")
        yarn_local_prefix=$(echo ${yarn_local} | sed "s|^|file://|g" | sed "s| |,file://|g")
        yarn_log=$(echo ${NODE_ROOTS[$i]} | sed "s|[ ]+| |g" | sed "s|$|/${YARN_LOG_DIR}|g" | sed "s| |/${YARN_LOG_DIR} |g")
        yarn_log_prefix=$(echo ${yarn_log} | sed "s|^|file://|g" | sed "s| |,file://|g")
    fi

    NODE_DIRS[$i]="${node_dir}"
    YARN_LOCALS[$i]="${yarn_local}"
    YARN_LOGS[$i]="${yarn_log}"

    NODE_DIRS_PREFIX[$i]="${node_dir_prefix}"
    YARN_LOCALS_PREFIX[$i]="${yarn_local_prefix}"
    YARN_LOGS_PREFIX[$i]="${yarn_log_prefix}"
done

ALL_PACKAGES=$(get_dl_files "${CUR_DIR}/config.sh" "tar\.gz|\.jar|\.rpm")

PACKAGES_DL_DIR="$(cd ${CUR_DIR} 1>/dev/null;pwd;cd - 1>/dev/null)/../tools/"

#echo ${NODE_HOSTS[@]} | sed "s| |\n|g" | sed "1d" | sed "s|^|file:///|g" | tr '\n' ','
#echo ${#NODE_DIRS[@]}
#echo ${NODE_DIRS[@]}
#echo ${#YARN_LOCALS[@]}
#echo ${YARN_LOCALS[@]}
#echo ${#YARN_LOGS[@]}
#echo ${YARN_LOGS[@]}
#
#echo ${#NODE_DIRS_PREFIX[@]}
#echo ${NODE_DIRS_PREFIX[@]}
#echo ${#YARN_LOCALS_PREFIX[@]}
#echo ${YARN_LOCALS_PREFIX[@]}
#echo ${#YARN_LOGS_PREFIX[@]}
#echo ${YARN_LOGS_PREFIX[@]}
