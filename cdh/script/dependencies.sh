#!/bin/sh

#########################################
#
# @author   wangdong@sina.cn
# @date     2016/02/06
# @desc     focus on cdh dependencies
#
#########################################

. $(dirname ${BASH_SOURCE[0]})/check.sh

###############################################################################
# 1. Download the installation packages
###############################################################################
dl_files "${ALL_PACKAGES}" "${PACKAGES_DL_DIR}"
if [ $? -ne 0 ]; then
    log error "Fail to download ${ALL_PACKAGES}"
    exit 1
fi
