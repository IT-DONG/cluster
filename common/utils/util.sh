#!/bin/sh

#########################################
# @author   wangdong@sina.cn
# @date     2016/02/03
# @desc     get file names to download
#########################################
function log()
{
    local level="$1"
    local msg="$2"

    if [[ -z "${level}" || -z "${msg}" ]]; then
        echo "[$(date '+%F %T')][ERROR] Invalid log level or log message!"
        return 1
    fi

    case "${level^^}" in
       DEBUG|INFO|WARN|ERROR)
        echo "[$(date '+%F %T')][${level^^}] ${msg}"
        ;;

       *)
        echo "[$(date '+%F %T')][ERROR] Invalid log level: ${level}"
        return 1
        ;;
    esac

    return 0
}

function get_dl_files()
{
    local file="$1"
    local pattern="$2"

    if [[ ! -f "${file}" || -z "${pattern}" ]]; then
        return 1
    fi
    
    matches=$(cat ${file} | egrep -v "^(#|ALL_PACKAGES=)" | egrep -i "${pattern}")
    for m in ${matches}; do
        echo ${m#*=}
    done

    return 0
}

function dl_files()
{
    local files="$1"
    local dest_dir="$2"

    if [[ -z "${files}" || -z "${dest_dir}" ]]; then
        log error "URLs to download is empty or destination directory is empty!"
        return 1
    fi

    mkdir -p ${dest_dir}
    if [ $? -ne 0 ]; then
        log error "Cannot create directory: ${dest_dir}"
        return 1
    fi

    for f in ${files}; do
        local f_url=$(eval echo "${f}")
        local f_name=$(basename ${f_url})

        log debug "Downloading ${f_url} to ${dest_dir}"

        if [[ "${f_name}" =~ jdk-[a-zA-Z0-9-]+ ]]; then
            cd ${dest_dir} && wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -c ${f_url} -O ${f_name}
        else
            cd ${dest_dir} && wget --no-check-certificate -c ${f_url} -O ${f_name}
        fi
        if [ $? -ne 0 ]; then
            exit 1
        fi
    done

    return 0
}

function get_unset_vars()
{
    local file="$1"

    if [ -z "${file}" ]; then
        log error "Please input the file to check!"
        return 1
    fi

    if [ ! -f "${file}" ]; then
        log error "${file} doesn't exist!"
        return 1
    fi

    empty_vars=$(cat ${file} | egrep -v "^#" | egrep -i "*=$")
    if [ ! -z "${empty_vars}" ]; then
        log error "In ${file}, please set the variables: ${empty_vars}"
        return 1
    fi

    return 0
}
