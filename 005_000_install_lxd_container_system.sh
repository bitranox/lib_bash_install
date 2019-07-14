#!/bin/bash

export bitranox_debug="True"

function update_myself {
    /usr/local/lib_bash_install/install_or_update.sh "${@}" || exit 0              # exit old instance after updates
}

update_myself ${0} ${@}  > /dev/null 2>&1  # suppress messages here, not to spoil up answers from functions when called verbatim


function include_dependencies {
    source /usr/local/lib_bash/lib_color.sh
    source /usr/local/lib_bash/lib_retry.sh
    source /usr/local/lib_bash/lib_helpers.sh
    source /usr/local/lib_bash_install/900_000_lib_install_basics.sh
}

include_dependencies


function install_lxd_container_system {
    local logfile=$(get_log_file_name "${0}" "${BASH_SOURCE}" )
    banner "snap Install LXD"  | tee -a "${logfile}"
    # install snap
    retry $(which sudo) apt-get install snap -y  | tee -a "${logfile}"
    # install lxd
    retry $(which sudo) snap install lxd  | tee -a "${logfile}"
}


function add_user_to_lxd_group {
    # $1: user_name
    local user_name="${1}"
    local logfile=$(get_log_file_name "${0}" "${BASH_SOURCE}" )
    banner "Adding Current User ${user_name} to lxd group"  | tee -a "${logfile}"
    # add current user to lxd group
    $(which sudo) usermod --append --groups lxd "${user_name}" | tee -a "${logfile}"
    # join the group for this session - not as root !
    # init LXD - not as root !
}


## make it possible to call functions without source include
# Check if the function exists (bash specific)
if [[ ! -z "$1" ]]
    then
        if declare -f "${1}" > /dev/null
        then
          # call arguments verbatim
          "$@"
        else
          # Show a helpful error
          function_name="${1}"
          library_name="${0}"
          fail "\"${function_name}\" is not a known function name of \"${library_name}\""
        fi
	fi

