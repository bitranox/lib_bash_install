#!/bin/bash

export bitranox_debug="True"


function include_dependencies {
    source /usr/local/lib_bash/lib_color.sh
    source /usr/local/lib_bash/lib_retry.sh
    source /usr/local/lib_bash/lib_helpers.sh
}

include_dependencies  # we need to do that via a function to have local scope of my_dir


function install_package_if_not_present {
    #$1: package
    local package="${1}"
    if [[ "$(get_is_package_installed ${package})" == "False" ]]; then
        retry $(which sudo) apt-get install ${package} -y > /dev/null 2>&1
    fi
}


function uninstall_package_if_present {
    #$1: package
    local package="${1}"
    if [[ "$(get_is_package_installed ${package})" == "True" ]]; then
        retry $(which sudo) apt-get purge ${package} -y > /dev/null 2>&1
    fi
}


function install_essentials {
    # update / upgrade linux and clean / autoremove
    clr_bold clr_green "Installiere Essentielles am Host, entferne Apport und Whoopsie"
    install_package_if_not_present "net_tools"
    install_package_if_not_present "git"
    install_package_if_not_present "dialog"
    install_package_if_not_present "p7zip-full"
    install_package_if_not_present "python3-pip"
    uninstall_package_if_present "whoopsie"
    uninstall_package_if_present "libwhoopsie0"
    uninstall_package_if_present "libwhoopsie-preferences0"
    uninstall_package_if_present "apport"
}

function install_swapfile {
    # $1=size, e.g. "8GB"
    local swap_size="${1}"
    banner "Install ${swap_size} Swapfile"
    $(which sudo) swapoff -a
    $(which sudo) rm /swapfile
    $(which sudo) mkdir -p /var/cache/swap
    $(which sudo) fallocate -l "${swap_size}" /var/cache/swap/swap0
    $(which sudo) chmod 0600 /var/cache/swap/swap0
    $(which sudo) mkswap /var/cache/swap/swap0
    $(which sudo) swapon /var/cache/swap/swap0
}

function disable_hibernate {
    banner "Disable Hibernate"
    $(which sudo) systemctl mask sleep.target
    $(which sudo) systemctl mask suspend.target
    $(which sudo) systemctl mask hibernate.target
    $(which sudo) systemctl mask hybrid-sleep.target
}

function install_x2go {
    banner "Install x2go Server"
    retry $(which sudo) add-apt-repository ppa:x2go/stable -y
    retry $(which sudo) apt-get update
    retry $(which sudo) apt-get install x2goserver -y
    retry $(which sudo) apt-get install x2goserver-xsession -y
    retry $(which sudo) apt-get install x2goclient -y
}



## make it possible to call functions without source include
call_function_from_commandline "${0}" "${1}" "${@}"
