#!/bin/bash

export bitranox_debug="True"

function install_or_update_lib_bash {
    if [[ -f "/usr/local/lib_bash/install_or_update.sh" ]]; then
        source /usr/local/lib_bash/lib_color.sh
        if [[ "${bitranox_debug}" == "True" ]]; then clr_blue "lib_bash_install\install_or_update.sh@install_or_update_lib_bash: lib_bash already installed, calling /usr/local/lib_bash/install_or_update.sh"; fi
        $(command -v sudo 2>/dev/null) /usr/local/lib_bash/install_or_update.sh
    else
        if [[ "${bitranox_debug}" == "True" ]]; then echo "lib_bash_install\install_or_update.sh@install_or_update_lib_bash: installing lib_bash"; fi
        $(command -v sudo 2>/dev/null) rm -fR /usr/local/lib_bash
        $(command -v sudo 2>/dev/null) git clone https://github.com/bitranox/lib_bash.git /usr/local/lib_bash > /dev/null 2>&1
        $(command -v sudo 2>/dev/null) chmod -R 0755 /usr/local/lib_bash
        $(command -v sudo 2>/dev/null) chmod -R +x /usr/local/lib_bash/*.sh
        $(command -v sudo 2>/dev/null) chown -R root /usr/local/lib_bash || $(command -v sudo 2>/dev/null) chown -R ${USER} /usr/local/lib_bash  || echo "giving up set owner" # there is no user root on travis
        $(command -v sudo 2>/dev/null) chgrp -R root /usr/local/lib_bash || $(command -v sudo 2>/dev/null) chgrp -R ${USER} /usr/local/lib_bash  || echo "giving up set group" # there is no user root on travis
    fi
}

install_or_update_lib_bash

function include_dependencies {
    source /usr/local/lib_bash/lib_color.sh
    source /usr/local/lib_bash/lib_retry.sh
    source /usr/local/lib_bash/lib_helpers.sh
}

include_dependencies


function set_lib_bash_install_permissions {
    $(get_sudo) chmod -R 0755 /usr/local/lib_bash_install
    $(get_sudo) chmod -R +x /usr/local/lib_bash_install/*.sh
    $(get_sudo) chown -R root /usr/local/lib_bash_install || $(get_sudo) chown -R ${USER} /usr/local/lib_bash_install || echo "giving up set owner" # there is no user root on travis
    $(get_sudo) chgrp -R root /usr/local/lib_bash_install || $(get_sudo) chgrp -R ${USER} /usr/local/lib_bash_install || echo "giving up set group" # there is no user root on travis
}

function is_lib_bash_install_installed {
        if [[ -f "/usr/local/lib_bash_install/install_or_update.sh" ]]; then
            return 0
        else
            return 1
        fi
}


function is_lib_bash_install_up_to_date {
    local git_remote_hash=$(git --no-pager ls-remote --quiet https://github.com/bitranox/lib_bash_install.git | grep HEAD | awk '{print $1;}' )
    local git_local_hash=$( $(get_sudo) cat /usr/local/lib_bash_install/.git/refs/heads/master)
    if [[ "${git_remote_hash}" == "${git_local_hash}" ]]; then
        return 0
    else
        return 1
    fi
}

function install_lib_bash_install {
    clr_green "installing lib_bash_install"
    $(get_sudo) rm -fR /usr/local/lib_bash_install
    $(get_sudo) git clone https://github.com/bitranox/lib_bash_install.git /usr/local/lib_bash_install > /dev/null 2>&1
    set_lib_bash_install_permissions
}


function update_lib_bash_install {
    if [[ "${bitranox_debug}" == "True" ]]; then clr_blue "lib_bash_install\install_or_update.sh@update_lib_bash_install: updating lib_bash_install"; fi
    (
        # create a subshell to preserve current directory
        cd /usr/local/lib_bash_install
        $(get_sudo) git fetch --all  > /dev/null 2>&1
        $(get_sudo) git reset --hard origin/master  > /dev/null 2>&1
        set_lib_bash_install_permissions
    )
    if [[ "${bitranox_debug}" == "True" ]]; then clr_blue "lib_bash_install\install_or_update.sh@update_lib_bash_install: lib_bash_install update complete"; fi
}


function tests {
	clr_green "no tests in ${0}"
}


if is_lib_bash_install_installed; then
    if is_lib_bash_install_up_to_date; then
        if [[ "${bitranox_debug}" == "True" ]]; then clr_blue "lib_bash_install\install_or_update.sh@main: lib_bash_install is not up to date"; fi
        update_lib_bash_install
        if [[ "${bitranox_debug}" == "True" ]]; then clr_blue "lib_bash_install\install_or_update.sh@main: call restart_calling_script ${@}"; fi
        restart_calling_script  "${@}"
        if [[ "${bitranox_debug}" == "True" ]]; then clr_blue "lib_bash_install\install_or_update.sh@main: call restart_calling_script ${@} returned ${?}"; fi
    else
        if [[ "${bitranox_debug}" == "True" ]]; then clr_blue "lib_bash_install\install_or_update.sh@main: lib_bash_install is up to date"; fi
    fi

else
    install_lib_bash_install
fi
