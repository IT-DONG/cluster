#!/bin/sh

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
ZOOKEEPER_PACKAGE=${ZOOKEEPER_PACKAGE_DL_URL##*/}

ALL_PACKAGES=$(get_dl_files "${CUR_DIR}/config.sh" "tar\.gz|\.jar|\.rpm")

PACKAGES_DL_DIR="$(cd ${CUR_DIR} 1>/dev/null;pwd;cd - 1>/dev/null)/../tools/"
