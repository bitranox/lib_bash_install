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
    if ! is_package_installed "${package}"; then
        retry "$(cmd "sudo")" apt-get install ${package} -y > /dev/null 2>&1
    fi
}


function uninstall_package_if_present {
    #$1: package
    local package="${1}"
    if is_package_installed ${package}; then
        retry "$(cmd "sudo")" apt-get purge ${package} -y > /dev/null 2>&1
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
    install_package_if_not_present "ssh-askpass"      # we need that if no tty is present to ask for sudo password # todo: add SUDO_ASKPASS=ssh-askpass in /etc/environment,
                                                      # todo : export NO_AT_BRIDGE=1  # get rid of (ssh-askpass:25930): dbind-WARNING **: 18:46:12.019: Couldn't register with accessibility bus: Did not receive a reply.

    uninstall_package_if_present "whoopsie"
    uninstall_package_if_present "libwhoopsie0"
    uninstall_package_if_present "libwhoopsie-preferences0"
    uninstall_package_if_present "apport"
}

function install_swapfile {
    # $1=size, e.g. "8GB"
    local swap_size="${1}"
    banner "Install ${swap_size} Swapfile"
    "$(cmd "sudo")" swapoff -a
    "$(cmd "sudo")" rm /swapfile
    "$(cmd "sudo")" mkdir -p /var/cache/swap
    "$(cmd "sudo")" fallocate -l "${swap_size}" /var/cache/swap/swap0
    "$(cmd "sudo")" chmod 0600 /var/cache/swap/swap0
    "$(cmd "sudo")" mkswap /var/cache/swap/swap0
    "$(cmd "sudo")" swapon /var/cache/swap/swap0
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

function tests {
	clr_green "no tests in ${0}"
}


## make it possible to call functions without source include
call_function_from_commandline "${0}" "${@}"
