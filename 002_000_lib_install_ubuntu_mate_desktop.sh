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

function install_ubuntu_mate_desktop {
    local logfile=$(get_log_file_name "${0}" "${BASH_SOURCE}" )

    banner "Install ubuntu-mate-desktop - select LIGHTDM as Display Manager during Installation !"  | tee -a "${logfile}"

    install_package_if_not_present "bindfs"
    install_package_if_not_present "lightdm"
    if [[ "$(get_linux_release_number_major)" -ge 18 ]]; then
        install_package_if_not_present "slick-greeter"  # fails at xenial and below
    fi
    install_package_if_not_present "lightdm"
    install_package_if_not_present "grub2-themes-ubuntu-mate"
    install_package_if_not_present "ubuntu-mate-core"
    install_package_if_not_present "ubuntu-mate-artwork"
    install_package_if_not_present "ubuntu-mate-default-settings"
    install_package_if_not_present "ubuntu-mate-icon-themes"
    install_package_if_not_present "ubuntu-mate-wallpapers-complete"
    install_package_if_not_present "human-theme"
    install_package_if_not_present "mate-applet-brisk-menu"
    install_package_if_not_present "mate-system-monitor"
    install_package_if_not_present "language-pack-gnome-de"
    install_package_if_not_present "geany"
    install_package_if_not_present "mc"
    install_package_if_not_present "meld"
    uninstall_package_if_present "byobu"
    uninstall_package_if_present "vim"
    uninstall_package_if_present "mate-screensaver"
    retry "$(cmd "sudo")" dpkg-reconfigure lightdm
    $(repair_user_permissions)

}

function replace_netplan_coudinit_conf {
    local logfile=$(get_log_file_name "${0}" "${BASH_SOURCE}" )

    if is_hetzner_virtual_server; then  # @lib_bash/lib_helpers
        banner "replace /etc/netplan/50-cloud-init.yaml, create /etc/netplan/01-network-manager-all.yaml"
        backup_file /etc/netplan/50-cloud-init.yaml  # @lib_bash/lib_helpers
        remove_file /etc/netplan/50-cloud-init.yaml  # @lib_bash/lib_helpers
        "$(cmd "sudo")" cp -f /usr/local/lib_bash_install/shared/config/etc/netplan/01-network-manager-all.yaml /etc/netplan/01-network-manager-all.yaml
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
