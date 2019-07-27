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
        install_package_if_not_present "mono-devel"
        install_package_if_not_present "mono-dbg"
        install_package_if_not_present "mono-xsp4"
        linux_update
}


function install_diverse_tools {
    banner "install needed tools : build-essential, mc, geany, meld, synaptic, x2goclient"

    uninstall_package_if_present "whoopsie"
    uninstall_package_if_present "libwhoopsie0"
    uninstall_package_if_present "libwhoopsie-preferences0"
    uninstall_package_if_present "apport"
    uninstall_package_if_present "enchant"
    uninstall_package_if_present "gedit"
    uninstall_package_if_present "gedit-common"
    uninstall_package_if_present "pluma-common"
    uninstall_package_if_present "tilda"
    uninstall_package_if_present "vim"

    install_package_if_not_present "net-tools"
    install_package_if_not_present "git"
    install_package_if_not_present "build-essential"
    install_package_if_not_present "mc"
    install_package_if_not_present "geany"
    install_package_if_not_present "meld"
    install_package_if_not_present "synaptic"
    install_package_if_not_present "x2goclient"
    install_mono_complete
    install_package_if_not_present "keepass2"
    install_package_if_not_present "ssh-askpass-gnome"                           # we need that if no tty is present to ask for sudo password # todo: add SUDO_ASKPASS=ssh-askpass in /etc/environment,
                                                                                 # todo : export NO_AT_BRIDGE=1  # get rid of (ssh-askpass:25930): dbind-WARNING **: 18:46:12.019: Couldn't register with accessibility bus: Did not receive a reply.
    # todo google drive + logos (links) dazu
}


function install_chrome {
    local logfile=$(get_log_file_name "${0}" "${BASH_SOURCE}" )
    banner "Install google chrome" | tee -a "${logfile}"
    install_package_if_not_present "fonts-liberation"
    install_package_if_not_present "xdg-utils"
    retry "$(cmd "sudo")" wget -nv -c https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb | tee -a "${logfile}"
    retry "$(cmd "sudo")" dpkg -i google-chrome-stable_current_amd64.deb | tee -a "${logfile}"
    "$(cmd "sudo")" rm -f ./google-chrome-stable_current_amd64.deb | tee -a "${logfile}"
}


function install_chrome_remote_desktop {
    local logfile=$(get_log_file_name "${0}" "${BASH_SOURCE}" )
    banner "Install google chrome remote desktop" | tee -a "${logfile}"
    install_package_if_not_present "xvfb"
    install_package_if_not_present "xbase-clients"
    install_package_if_not_present "python-psutil"
    retry "$(cmd "sudo")" wget -nv -c https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb | tee -a "${logfile}"
    retry "$(cmd "sudo")" dpkg -i chrome-remote-desktop_current_amd64.deb | tee -a "${logfile}"
    "$(cmd "sudo")" rm -f ./chrome-remote-desktop_current_amd64.deb | tee -a "${logfile}"
    replace_or_add_lines_containing_string_in_file "/etc/environment" "CHROME_REMOTE_DESKTOP_DEFAULT_DESKTOP_SIZES" "CHROME_REMOTE_DESKTOP_DEFAULT_DESKTOP_SIZES=\"5120x1600\"" "#"
}


## make it possible to call functions without source include
call_function_from_commandline "${0}" "${@}"
