#!/bin/bash

export bitranox_debug="True"


function update_myself {
    /usr/local/lib_bash_install/install_or_update.sh "${@}" || exit 0              # exit old instance after updates
}


if [[ -z "${@}" ]]; then
    update_myself ${0}
else
    update_myself ${0} ${@}  > /dev/null 2>&1  # suppress messages here, not to spoil up answers from functions  when called verbatim
fi


function include_dependencies {
    source /usr/local/lib_bash/lib_color.sh
    source /usr/local/lib_bash/lib_retry.sh
    source /usr/local/lib_bash/lib_helpers.sh
}

include_dependencies  # we need to do that via a function to have local scope of my_dir

function install_dialog {
    if [[ "$(get_is_package_installed dialog)" == "False" ]]; then
        retry $(which sudo) apt-get install dialog -y > /dev/null 2>&1
    fi
}

function install_git {
    if [[ "$(get_is_package_installed git)" == "False" ]]; then
        retry $(which sudo) apt-get install git -y > /dev/null 2>&1
    fi
}

function install_net_tools {
    if [[ "$(get_is_package_installed net-tools)" == "False" ]]; then
        retry $(which sudo) apt-get install net-tools -y > /dev/null 2>&1
    fi
}

function uninstall_whoopsie {
    if [[ "$(get_is_package_installed whoopsie)" == "True" ]]; then
        retry $(which sudo) apt-get purge whoopsie -y > /dev/null 2>&1
    fi
    if [[ "$(get_is_package_installed libwhoopsie0)" == "True" ]]; then
        retry $(which sudo) apt-get purge libwhoopsie0 -y > /dev/null 2>&1
    fi
    if [[ "$(get_is_package_installed libwhoopsie-preferences0)" == "True" ]]; then
        retry $(which sudo) apt-get purge libwhoopsie-preferences0 -y > /dev/null 2>&1
    fi
}

function uninstall_apport {
    if [[ "$(get_is_package_installed apport)" == "True" ]]; then
        retry $(which sudo) apt-get purge apport -y > /dev/null 2>&1
    fi
}


function install_essentials {
    # update / upgrade linux and clean / autoremove
    clr_bold clr_green "Installiere Essentielles am Host, entferne Apport und Whoopsie"
    install_net_tools
    install_git
    install_dialog
    uninstall_whoopsie
    uninstall_apport
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
