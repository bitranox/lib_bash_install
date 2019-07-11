#!/bin/bash

function update_myself {
    /usr/local/lib_bash_install/install_or_update.sh "${@}" || exit 0              # exit old instance after updates
}

function include_dependencies {
    source /usr/local/lib_bash/lib_color.sh
    source /usr/local/lib_bash/lib_retry.sh
    source /usr/local/lib_bash/lib_helpers.sh
    source /usr/local/lib_bash_install/900_000_lib_install_basics.sh
}

include_dependencies

function install_ubuntu_mate_desktop {
    banner "Install ubuntu-mate-desktop - select LIGHTDM as Display Manager during Installation !"

    retry $(which sudo) apt-get install lightdm -y
    retry $(which sudo) apt-get install slick-greeter -y
    retry $(which sudo) dpkg-reconfigure lightdm

    retry $(which sudo) apt-get install grub2-themes-ubuntu-mate -y
    retry $(which sudo) apt-get install ubuntu-mate-core -y
    retry $(which sudo) apt-get install ubuntu-mate-artwork -y
    retry $(which sudo) apt-get install ubuntu-mate-default-settings -y
    retry $(which sudo) apt-get install ubuntu-mate-icon-themes -y
    retry $(which sudo) apt-get install ubuntu-mate-wallpapers-complete -y
    retry $(which sudo) apt-get install human-theme -y
    retry $(which sudo) apt-get install mate-applet-brisk-menu -y
    retry $(which sudo) apt-get install mate-system-monitor -y
    retry $(which sudo) apt-get install language-pack-gnome-de -y
    retry $(which sudo) apt-get install geany -y
    retry $(which sudo) apt-get install mc -y
    retry $(which sudo) apt-get install meld -y
    retry $(which sudo) apt-get purge byobu -y
    retry $(which sudo) apt-get purge vim -y
    retry $(which sudo) dpkg-reconfigure lightdm
}

function replace_netplan_coudinit_conf {
    banner "replace /etc/netplan/50-cloud-init.yaml, create /etc/netplan/01-network-manager-all.yaml"
    backup_file /etc/netplan/50-cloud-init.yaml  # @lib_bash/lib_helpers
    remove_file /etc/netplan/50-cloud-init.yaml  # @lib_bash/lib_helpers
    $(which sudo) cp -f /usr/local/lib_bash_install/shared/config/etc/netplan/01-network-manager-all.yaml /etc/netplan/01-network-manager-all.yaml
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
# Check if the function exists (bash specific)
if [[ ! -z "$1" ]]
    then
        if declare -f "${1}" > /dev/null
        then
          # call arguments verbatim
          update_myself ${0} ${@}  # pass own script name and parameters
          "$@"
        else
          # Show a helpful error
          function_name="${1}"
          library_name="${0}"
          fail "\"${function_name}\" is not a known function name of \"${library_name}\""
        fi
	fi
