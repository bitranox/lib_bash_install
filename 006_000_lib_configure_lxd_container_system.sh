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

function lxd_init {
    local logfile=$(get_log_file_name "${0}" "${BASH_SOURCE}" )
    banner "LXD Init" | tee -a "${logfile}"
    "$(get_sudo)" lxd init --auto --storage-backend dir    | tee -a "${logfile}"
}

function set_uids {
    local logfile=$(get_log_file_name "${0}" "${BASH_SOURCE}" )
    banner "set_uids" | tee -a "${logfile}"
    # subuid, subgid auf den Hauptbenutzer (1000) setzen
    "$(get_sudo)" sh -c "echo \"root:1000:1\nlxd:100000:1000000000\nroot:100000:1000000000\n\" > /etc/subuid"
    "$(get_sudo)" sh -c "echo \"root:1000:1\nlxd:100000:1000000000\nroot:100000:1000000000\n\" > /etc/subgid"
    "$(get_sudo)" snap restart lxd  | tee -a "${logfile}"
}

function create_shared_directory {
    local logfile=$(get_log_file_name "${0}" "${BASH_SOURCE}" )
    banner "create_shared_directory" | tee -a "${logfile}"
    # shared Verzeichnis anlegen und der Gruppe LXD zuordnen
    "$(get_sudo)" mkdir -p /media/lxc-shared | tee -a "${logfile}"
    "$(get_sudo)" chmod -R 0777 /media/lxc-shared | tee -a "${logfile}"
    "$(get_sudo)" chgrp -R lxd /media/lxc-shared | tee -a "${logfile}"

}

function configure_lxd_bridge_zone {
    # $1: zone_name = "lxd"
    # LXC Network dns einschalten - die container sind dann unter der domäne ".lxc" erreichbar
    local logfile=$(get_log_file_name "${0}" "${BASH_SOURCE}" )
    banner "configure_lxd_bridge_zone to ${1}" | tee -a "${logfile}"

    local zone_name="${1}"
    echo -e "auth-zone=${zone_name}\ndns-loop-detect" | lxc network set lxdbr0 raw.dnsmasq -  | tee -a "${logfile}"
    "$(get_sudo)" snap restart lxd  | tee -a "${logfile}"
}


function extend_default_profile {
    local logfile=$(get_log_file_name "${0}" "${BASH_SOURCE}" )
    banner "extend_default_profile" | tee -a "${logfile}"

    # Device zu Profile hinzufügen
    lxc profile device add default lxc-shared disk source=/media/lxc-shared path=/media/lxc-shared  | tee -a "${logfile}"
    lxc profile set default raw.idmap "both 1000 1000"  | tee -a "${logfile}"
}

function tests {
	clr_green "no tests in ${0}"
}

## make it possible to call functions without source include
call_function_from_commandline "${0}" "${@}"
