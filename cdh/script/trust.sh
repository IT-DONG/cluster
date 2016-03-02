#!/bin/sh

#########################################
#
# @author   wangdong@sina.cn
# @date     08/13/2015
# @desc     focus on env preparement
#
#########################################


#########################################
# On namenode only, please try to update JAVA_HEAP_MAX=-Xmx4000m in 
# vi /usr/lib/hadoop/libexec/hadoop-check.sh or $SOME_PATH/hadoop-env.sh
# in case that the error "Namenode failed while loading fsimage with GC overhead limit exceeded"
#########################################

. $(dirname ${BASH_SOURCE[0]})/check.sh

CUR_DIR=$(cd $(dirname ${BASH_SOURCE[0]}) 1>/dev/null;pwd)
COMPONENT=$(basename $(cd ${CUR_DIR}/../;pwd))


##########################################################
# Check the whether the variables are configured or not
##########################################################
DEPENDENT_DIRS="${PROJECTS_HOME}/common \
                ${PROJECTS_HOME}/${COMPONENT} \
                ${INSTALL_HOME} \
                /var/run/hadoop-hdfs \
                /home/${USER_NAME}/.ssh"

for ((i=0; $i<${NODE_HOSTS_CNT}; i=$i+1))
do
    if [ $i -eq 0 ]; then
        DEPENDENT_DIRS="${DEPENDENT_DIRS} ${NODE_DIRS[$i]}"
        ssh "root@${NODE_HOSTS[$i]}" "useradd ${USER_NAME}; \
                         if [ \$? -eq 0 ]; then \
                             passwd ${USER_NAME}; \
                         fi; \
                         usermod -a -G root,hadoop ${USER_NAME}; \
                         id ${USER_NAME}; \
                         chmod -R 1777 ${NODE_ROOTS[$i]};\
                         mkdir -p ${DEPENDENT_DIRS} && chown -R ${USER_NAME}:hadoop ${DEPENDENT_DIRS};\
                         "

        if [ ! -f /root/.ssh/id_rsa.pub ]; then
            ssh-keygen -t rsa
        fi

        root_rsa_pub=`cat /root/.ssh/id_rsa.pub`

        if [ ! -f /home/${USER_NAME}/.ssh/id_rsa.pub ]; then
            sudo -u${USER_NAME} ssh-keygen -t rsa
        fi

        hadoop_rsa_pub=`cat /home/${USER_NAME}/.ssh/id_rsa.pub`

        if [ -f /home/${USER_NAME}/.ssh/authorized_keys ]; then
            sed -i "s|${root_rsa_pub}||g" /home/${USER_NAME}/.ssh/authorized_keys
            sed -i "s|${hadoop_rsa_pub}||g" /home/${USER_NAME}/.ssh/authorized_keys
            sed -i "/^$/d" /home/${USER_NAME}/.ssh/authorized_keys
        fi

        echo ${root_rsa_pub} >> /home/${USER_NAME}/.ssh/authorized_keys
        echo ${hadoop_rsa_pub} >> /home/${USER_NAME}/.ssh/authorized_keys
    else
        DEPENDENT_DIRS="${DEPENDENT_DIRS} ${NODE_DIRS[$i]} ${YARN_LOCALS[$i]} ${YARN_LOGS[$i]}"
        ssh "root@${NODE_HOSTS[$i]}" "useradd ${USER_NAME}; \
                         if [ \$? -eq 0 ]; then \
                             passwd ${USER_NAME}; \
                         fi; \
                         usermod -a -G root,hadoop ${USER_NAME}; \
                         id ${USER_NAME}; \
                         chmod -R 1777 ${NODE_ROOTS[$i]};\
                         mkdir -p ${DEPENDENT_DIRS} && chown -R ${USER_NAME}:hadoop ${DEPENDENT_DIRS};\
                         if [ -f /home/${USER_NAME}/.ssh/authorized_keys ]; then\
                             sed -i 's|${root_rsa_pub}||g' /home/${USER_NAME}/.ssh/authorized_keys;\
                             sed -i 's|${hadoop_rsa_pub}||g' /home/${USER_NAME}/.ssh/authorized_keys;\
                             sed -i '/^$/d' /home/${USER_NAME}/.ssh/authorized_keys;\
                         fi;\
                         echo ${root_rsa_pub} >> /home/${USER_NAME}/.ssh/authorized_keys;\
                         echo ${hadoop_rsa_pub} >> /home/${USER_NAME}/.ssh/authorized_keys;\
                         "
    fi
done
