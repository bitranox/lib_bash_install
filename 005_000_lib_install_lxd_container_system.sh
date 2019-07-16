#!/bin/bash

export bitranox_debug="True"

function update_myself {
    /usr/local/lib_bash_install/install_or_update.sh "${@}" || exit 0              # exit old instance after updates
}

update_myself ${0}


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
    retry "$(get_sudo)" apt-get install snap -y  | tee -a "${logfile}"
    # install lxd
    retry "$(get_sudo)" snap install lxd  | tee -a "${logfile}"
}


function add_user_to_lxd_group {
    # $1: user_name
    local user_name="${1}"
    local logfile=$(get_log_file_name "${0}" "${BASH_SOURCE}" )
    banner "Adding Current User ${user_name} to lxd group"  | tee -a "${logfile}"
    # add current user to lxd group
    "$(get_sudo)" usermod --append --groups lxd "${user_name}" | tee -a "${logfile}"
    # join the group for this session - not as root !
    # init LXD - not as root !
}

function tests {
	clr_green "no tests in ${0}"
}


## make it possible to call functions without source include
call_function_from_commandline "${0}" "${@}"
