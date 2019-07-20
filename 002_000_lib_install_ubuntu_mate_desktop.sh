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

function install_ubuntu_mate_desktop {
    local logfile=$(get_log_file_name "${0}" "${BASH_SOURCE}" )

    banner "Install ubuntu-mate-desktop - select LIGHTDM as Display Manager during Installation !"  | tee -a "${logfile}"

    retry "$(cmd "sudo")" apt-get install bindfs -y | tee -a "${logfile}"
    retry "$(cmd "sudo")" apt-get install lightdm -y | tee -a "${logfile}"
    retry "$(cmd "sudo")" apt-get install slick-greeter -y | tee -a "${logfile}"
    retry "$(cmd "sudo")" dpkg-reconfigure lightdm | tee -a "${logfile}"

    retry "$(cmd "sudo")" apt-get install grub2-themes-ubuntu-mate -y | tee -a "${logfile}"
    retry "$(cmd "sudo")" apt-get install ubuntu-mate-core -y | tee -a "${logfile}"
    retry "$(cmd "sudo")" apt-get install ubuntu-mate-artwork -y | tee -a "${logfile}"
    retry "$(cmd "sudo")" apt-get install ubuntu-mate-default-settings -y | tee -a "${logfile}"
    retry "$(cmd "sudo")" apt-get install ubuntu-mate-icon-themes -y | tee -a "${logfile}"
    retry "$(cmd "sudo")" apt-get install ubuntu-mate-wallpapers-complete -y | tee -a "${logfile}"
    retry "$(cmd "sudo")" apt-get install human-theme -y | tee -a "${logfile}"
    retry "$(cmd "sudo")" apt-get install mate-applet-brisk-menu -y | tee -a "${logfile}"
    retry "$(cmd "sudo")" apt-get install mate-system-monitor -y | tee -a "${logfile}"
    retry "$(cmd "sudo")" apt-get install language-pack-gnome-de -y | tee -a "${logfile}"
    retry "$(cmd "sudo")" apt-get install geany -y | tee -a "${logfile}"
    retry "$(cmd "sudo")" apt-get install mc -y | tee -a "${logfile}"
    retry "$(cmd "sudo")" apt-get install meld -y | tee -a "${logfile}"
    retry "$(cmd "sudo")" apt-get purge byobu -y | tee -a "${logfile}"
    retry "$(cmd "sudo")" apt-get purge vim -y | tee -a "${logfile}"
    retry "$(cmd "sudo")" apt-get purge mate-screensaver -y | tee -a "${logfile}"
    retry "$(cmd "sudo")" dpkg-reconfigure lightdm | tee -a "${logfile}"
    $(repair_user_permissions)

}

function replace_netplan_coudinit_conf {
    local logfile=$(get_log_file_name "${0}" "${BASH_SOURCE}" )

    if is_hetzner_virtual_server; then  # @lib_bash/lib_helpers
        banner "replace /etc/netplan/50-cloud-init.yaml, create /etc/netplan/01-network-manager-all.yaml" | tee -a "${logfile}"
        backup_file /etc/netplan/50-cloud-init.yaml  # @lib_bash/lib_helpers
        remove_file /etc/netplan/50-cloud-init.yaml  # @lib_bash/lib_helpers
        "$(cmd "sudo")" cp -f /usr/local/lib_bash_install/shared/config/etc/netplan/01-network-manager-all.yaml /etc/netplan/01-network-manager-all.yaml | tee -a "${logfile}"
    fi
}


function install_ubuntu_mate_desktop_recommended {
    # $1 : swap_size, for instance "8GB"
    local swap_size=$1
    install_essentials
    linux_update
    install_swapfile "${swap_size}"
    disable_hibernate
    install_ubuntu_mate_desktop
    replace_netplan_coudinit_conf
    install_x2go
    linux_update
}


## make it possible to call functions without source include
call_function_from_commandline "${0}" "${@}"
