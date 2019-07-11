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

    local own_script_name=$(get_own_script_name)
    local logfile="${HOME}"/log_lib_bash_install_"${own_script_name}%.*".log

    retry $(which sudo) apt-get install bindfs -y | tee -a "${logfile}"
    retry $(which sudo) apt-get install lightdm -y | tee -a "${logfile}"
    retry $(which sudo) apt-get install slick-greeter -y | tee -a "${logfile}"
    retry $(which sudo) dpkg-reconfigure lightdm | tee -a "${logfile}"

    retry $(which sudo) apt-get install grub2-themes-ubuntu-mate -y | tee -a "${logfile}"
    retry $(which sudo) apt-get install ubuntu-mate-core -y | tee -a "${logfile}"
    retry $(which sudo) apt-get install ubuntu-mate-artwork -y | tee -a "${logfile}"
    retry $(which sudo) apt-get install ubuntu-mate-default-settings -y | tee -a "${logfile}"
    retry $(which sudo) apt-get install ubuntu-mate-icon-themes -y | tee -a "${logfile}"
    retry $(which sudo) apt-get install ubuntu-mate-wallpapers-complete -y | tee -a "${logfile}"
    retry $(which sudo) apt-get install human-theme -y | tee -a "${logfile}"
    retry $(which sudo) apt-get install mate-applet-brisk-menu -y | tee -a "${logfile}"
    retry $(which sudo) apt-get install mate-system-monitor -y | tee -a "${logfile}"
    retry $(which sudo) apt-get install language-pack-gnome-de -y | tee -a "${logfile}"
    retry $(which sudo) apt-get install geany -y | tee -a "${logfile}"
    retry $(which sudo) apt-get install mc -y | tee -a "${logfile}"
    retry $(which sudo) apt-get install meld -y | tee -a "${logfile}"
    retry $(which sudo) apt-get purge byobu -y | tee -a "${logfile}"
    retry $(which sudo) apt-get purge vim -y | tee -a "${logfile}"
    retry $(which sudo) dpkg-reconfigure lightdm | tee -a "${logfile}"
}

function replace_netplan_coudinit_conf {
    local own_script_name=$(get_own_script_name)
    local logfile="${HOME}"/log_lib_bash_install_"${own_script_name}%.*".log


    if [[ $(get_is_hetzner_virtual_server) == "False" ]]; then  # @lib_bash/lib_helpers
        banner "replace /etc/netplan/50-cloud-init.yaml, create /etc/netplan/01-network-manager-all.yaml" | tee -a "${logfile}"
        backup_file /etc/netplan/50-cloud-init.yaml  # @lib_bash/lib_helpers
        remove_file /etc/netplan/50-cloud-init.yaml  # @lib_bash/lib_helpers
        $(which sudo) cp -f /usr/local/lib_bash_install/shared/config/etc/netplan/01-network-manager-all.yaml /etc/netplan/01-network-manager-all.yaml | tee -a "${logfile}"
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
# Check if the function exists (bash specific)
if [[ ! -z "$1" ]]
    then
        update_myself ${0} ${@}  > /dev/null 2>&1  # suppress messages here, not to spoil up answers from functions
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
