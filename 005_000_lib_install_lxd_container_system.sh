#!/bin/bash

sudo_askpass="$(command -v ssh-askpass)"
export SUDO_ASKPASS="${sudo_askpass}"
export NO_AT_BRIDGE=1  # get rid of (ssh-askpass:25930): dbind-WARNING **: 18:46:12.019: Couldn't register with accessibility bus: Did not receive a reply.

# call the update script if not sourced
if [[ "${0}" == "${BASH_SOURCE[0]}" ]] && [[ -d "${BASH_SOURCE%/*}" ]]; then "${BASH_SOURCE%/*}"/install_or_update.sh else "${PWD}"/install_or_update.sh ; fi


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
    retry "$(cmd "sudo")" apt-get install snap -y  | tee -a "${logfile}"
    # install lxd
    retry "$(cmd "sudo")" snap install lxd  | tee -a "${logfile}"
}


function add_user_to_lxd_group {
    # $1: user_name
    local user_name="${1}"
    local logfile=$(get_log_file_name "${0}" "${BASH_SOURCE}" )
    banner "Adding Current User ${user_name} to lxd group"  | tee -a "${logfile}"
    # add current user to lxd group
    "$(cmd "sudo")" usermod --append --groups lxd "${user_name}" | tee -a "${logfile}"
    # join the group for this session - not as root !
    # init LXD - not as root !
}


## make it possible to call functions without source include
call_function_from_commandline "${0}" "${@}"
