#!/bin/sh

function find_by_content()
{
    if [[ $# -lt 3 || $# -gt 4 || -z "$1" || -z "$2" || -z "$3" ]]; then
        echo "Invalid parameters, please input the target directory, filename pattern, pattern, replace content IN ORDER!"
        echo 'Usage: '
        echo '       findc "." "*.sh" "test_*_content"'
        echo '       or findc "." "*.sh" "test_*_content" "replace_content"'
        return 1
    fi

    local target_dir="$1"
    local filename_pattern="$2"
    local content_pattern="$3"
    local replace_content="$4"

    if [ $# -eq 4 ]; then
        read -p "Are you sure to replace ALL '${content_pattern}' with '${replace_content}'?(Y/N)" -t 30 -n 1 choice
        choice=${choice^^}
        echo ""

        if [ "${choice}" != "Y" ]; then
            exit 0
        fi
    fi

    if [ ! -d "${target_dir}" ]; then
        echo "The directory specified doesn't exist, please check it!"
        return 1
    fi

    for f in `find ${target_dir} -name "${filename_pattern}" -type f`
    do
        [[ ! -e "${f}" || -d "${f}" ]] && continue

        local match_content=`cat -n ${f} | grep "${content_pattern}"`
        if [ ! -z "${match_content}" ]; then
            if [ $# -eq 4 ]; then
                #match_content=$(echo ${match_content} | tr -d "\t")
                #line_no=${match_content%% *}
                            
                #[ -z "${line_no}" ] && exit 1
                
                sed -i "s|${content_pattern}|${replace_content}|g" ${f}
                [ $? -ne 0 ] && exit 1
            fi

            echo "FILE: ${f}"
            echo "${match_content}"
            echo ""
        fi
    done
}

find_by_content "$@"
