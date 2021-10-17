#!/bin/bash

sudo_askpass="$(command -v ssh-askpass)"
export SUDO_ASKPASS="${sudo_askpass}"
export NO_AT_BRIDGE=1  # get rid of (ssh-askpass:25930): dbind-WARNING **: 18:46:12.019: Couldn't register with accessibility bus: Did not receive a reply.

# call the update script if not sourced
if [[ "${0}" == "${BASH_SOURCE[0]}" ]] && [[ -d "${BASH_SOURCE%/*}" ]]; then "${BASH_SOURCE%/*}"/install_or_update.sh else "${PWD}"/install_or_update.sh ; fi

function install_essentials {
    # update / upgrade linux and clean / autoremove
    clr_bold clr_green "Installiere Essentielles am Host"
    install_package_if_not_present "net-tools" "True"
    install_package_if_not_present "git" "True"
    install_package_if_not_present "dialog" "True"
    install_package_if_not_present "p7zip-full" "True"
    install_package_if_not_present "python3-pip" "True"
    install_package_if_not_present "ssh-askpass" "True"
    install_package_if_not_present "curl" "True"
    uninstall_package_if_present "whoopsie" "True"
    uninstall_package_if_present "libwhoopsie0" "True"
    uninstall_package_if_present "libwhoopsie-preferences0" "True"
    uninstall_package_if_present "apport" "True"
}

function install_swapfile {
    # $1=size, e.g. "8GB"
    local swap_size="${1}"
    banner "Install ${swap_size} Swapfile"
    "$(cmd "sudo")" swapoff -a
    "$(cmd "sudo")" rm /swapfile
    "$(cmd "sudo")" rm /var/cache/swap/swap0
    "$(cmd "sudo")" mkdir -p /var/cache/swap
    "$(cmd "sudo")" fallocate -l "${swap_size}" /var/cache/swap/swap0
    "$(cmd "sudo")" chmod 0600 /var/cache/swap/swap0
    "$(cmd "sudo")" mkswap /var/cache/swap/swap0
    "$(cmd "sudo")" swapon /var/cache/swap/swap0
    # todo - eintragen in fstab
}

function disable_hibernate {
    banner "Disable Hibernate"
    "$(cmd "sudo")" systemctl mask sleep.target
    "$(cmd "sudo")" systemctl mask suspend.target
    "$(cmd "sudo")" systemctl mask hibernate.target
    "$(cmd "sudo")" systemctl mask hybrid-sleep.target
}

function install_x2go {
    banner "Install x2go Server"
    retry "$(cmd "sudo")" add-apt-repository ppa:x2go/stable -y
    retry "$(cmd "sudo")" apt-get update
    retry "$(cmd "sudo")" apt-get install x2goserver -y
    retry "$(cmd "sudo")" apt-get install x2goserver-xsession -y
    retry "$(cmd "sudo")" apt-get install x2goclient -y
}


## make it possible to call functions without source include
call_function_from_commandline "${0}" "${@}"
