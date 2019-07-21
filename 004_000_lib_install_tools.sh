#!/bin/bash


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


function install_diverse_tools {
    local logfile=$(get_log_file_name "${0}" "${BASH_SOURCE}" )
    banner "install needed tools : build-essential, mc, geany, meld, synaptic, x2goclient"  | tee -a "${logfile}"

    uninstall_package_if_present "whoopsie" | tee -a "${logfile}"
    uninstall_package_if_present "libwhoopsie0" | tee -a "${logfile}"
    uninstall_package_if_present "libwhoopsie-preferences0" | tee -a "${logfile}"
    uninstall_package_if_present "apport" | tee -a "${logfile}"
    uninstall_package_if_present "enchant" | tee -a "${logfile}"
    uninstall_package_if_present "gedit" | tee -a "${logfile}"
    uninstall_package_if_present "gedit-common" | tee -a "${logfile}"
    uninstall_package_if_present "pluma-common" | tee -a "${logfile}"
    uninstall_package_if_present "tilda" | tee -a "${logfile}"
    uninstall_package_if_present "vim" | tee -a "${logfile}"

    install_package_if_not_present "net_tools" | tee -a "${logfile}"
    install_package_if_not_present "git" | tee -a "${logfile}"
    install_package_if_not_present "build-essential" | tee -a "${logfile}"
    install_package_if_not_present "mc" | tee -a "${logfile}"
    install_package_if_not_present "geany" | tee -a "${logfile}"
    install_package_if_not_present "meld" | tee -a "${logfile}"
    install_package_if_not_present "synaptic" | tee -a "${logfile}"
    install_package_if_not_present "x2goclient" | tee -a "${logfile}"
    install_package_if_not_present "keepass2" | tee -a "${logfile}"
    install_package_if_not_present "ssh-askpass-gnome"  | tee -a "${logfile}"    # we need that if no tty is present to ask for sudo password # todo: add SUDO_ASKPASS=ssh-askpass in /etc/environment,
                                                                                 # todo : export NO_AT_BRIDGE=1  # get rid of (ssh-askpass:25930): dbind-WARNING **: 18:46:12.019: Couldn't register with accessibility bus: Did not receive a reply.
}


function install_chrome {
    local logfile=$(get_log_file_name "${0}" "${BASH_SOURCE}" )
    banner "Install google chrome" | tee -a "${logfile}"
    retry "$(cmd "sudo")" apt-get install fonts-liberation -y | tee -a "${logfile}"
    retry "$(cmd "sudo")" apt-get install xdg-utils -y | tee -a "${logfile}"
    retry "$(cmd "sudo")" wget -nv -c https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb | tee -a "${logfile}"
    retry "$(cmd "sudo")" dpkg -i google-chrome-stable_current_amd64.deb | tee -a "${logfile}"
    "$(cmd "sudo")" rm -f ./google-chrome-stable_current_amd64.deb | tee -a "${logfile}"
}


function install_chrome_remote_desktop {
    local logfile=$(get_log_file_name "${0}" "${BASH_SOURCE}" )
    banner "Install google chrome remote desktop" | tee -a "${logfile}"
    retry "$(cmd "sudo")" apt-get install xvfb -y | tee -a "${logfile}"
    retry "$(cmd "sudo")" apt-get install xbase-clients -y | tee -a "${logfile}"
    retry "$(cmd "sudo")" apt-get install python-psutil -y | tee -a "${logfile}"
    retry "$(cmd "sudo")" wget -nv -c https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb | tee -a "${logfile}"
    retry "$(cmd "sudo")" dpkg -i chrome-remote-desktop_current_amd64.deb | tee -a "${logfile}"
    "$(cmd "sudo")" rm -f ./chrome-remote-desktop_current_amd64.deb | tee -a "${logfile}"
    replace_or_add_lines_containing_string_in_file "/etc/environment" "CHROME_REMOTE_DESKTOP_DEFAULT_DESKTOP_SIZES" "CHROME_REMOTE_DESKTOP_DEFAULT_DESKTOP_SIZES=\"5120x1600\"" "#"
}


function fallback_to_mono_bionic_version {
    echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | "$(cmd "sudo")" tee /etc/apt/sources.list.d/mono-official-stable.list
    "$(cmd "sudo")" apt-get update
}


function install_mono_complete {
        clr_green "Install mono complete"
        retry "$(cmd "sudo")" apt-get install gnupg ca-certificates
        retry "$(cmd "sudo")" apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
        echo "deb https://download.mono-project.com/repo/ubuntu stable-${linux_release_name} main" | "$(cmd "sudo")" tee /etc/apt/sources.list.d/mono-official-stable.list
        "$(cmd "sudo")" apt-get update || fallback_to_mono_bionic_version
        retry "$(cmd "sudo")" apt-get install mono-devel -y
        retry "$(cmd "sudo")" apt-get install mono-dbg -y
        retry "$(cmd "sudo")" apt-get install mono-xsp4 -y
        linux_update
}

## make it possible to call functions without source include
call_function_from_commandline "${0}" "${@}"
