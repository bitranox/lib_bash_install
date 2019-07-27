#!/bin/bash

sudo_askpass="$(command -v ssh-askpass)"
export SUDO_ASKPASS="${sudo_askpass}"
export NO_AT_BRIDGE=1  # get rid of (ssh-askpass:25930): dbind-WARNING **: 18:46:12.019: Couldn't register with accessibility bus: Did not receive a reply.


function set_lib_bash_permissions {
    local user
    user="$(printenv USER)"
    $(command -v sudo 2>/dev/null) chmod -R 0755 "/usr/local/lib_bash"
    $(command -v sudo 2>/dev/null) chmod -R +x /usr/local/lib_bash/*.sh
    $(command -v sudo 2>/dev/null) chown -R root /usr/local/lib_bash || "$(command -v sudo 2>/dev/null)" chown -R "${user}" /usr/local/lib_bash || echo "giving up set owner" # there is no user root on travis
    $(command -v sudo 2>/dev/null) chgrp -R root /usr/local/lib_bash || "$(command -v sudo 2>/dev/null)" chgrp -R "${user}" /usr/local/lib_bash || echo "giving up set group" # there is no user root on travis
}


function install_lib_bash {
    echo "installing lib_bash"
    $(command -v sudo 2>/dev/null) rm -fR /usr/local/lib_bash
    $(command -v sudo 2>/dev/null) git clone https://github.com/bitranox/lib_bash.git /usr/local/lib_bash > /dev/null 2>&1
    set_lib_bash_permissions
}


function install_or_update_lib_bash {
    if [[ -f "/usr/local/lib_bash/install_or_update.sh" ]]; then
        # file exists - so update
        $(command -v sudo 2>/dev/null) /usr/local/lib_bash/install_or_update.sh
    else
        install_lib_bash

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
    "$(cmd "sudo")" chmod -R 0755 /usr/local/lib_bash_install
    "$(cmd "sudo")" chmod -R +x /usr/local/lib_bash_install/*.sh
    "$(cmd "sudo")" chown -R root /usr/local/lib_bash_install || "$(cmd "sudo")" chown -R ${USER} /usr/local/lib_bash_install || echo "giving up set owner" # there is no user root on travis
    "$(cmd "sudo")" chgrp -R root /usr/local/lib_bash_install || "$(cmd "sudo")" chgrp -R ${USER} /usr/local/lib_bash_install || echo "giving up set group" # there is no user root on travis
}

function is_lib_bash_install_installed {
        if [[ -f "/usr/local/lib_bash_install/install_or_update.sh" ]]; then
            return 0
        else
            return 1
        fi
}


function is_lib_bash_install_up_to_date {
    local git_remote_hash git_local_hash
    git_remote_hash=$(git --no-pager ls-remote --quiet https://github.com/bitranox/lib_bash_install.git | grep HEAD | awk '{print $1;}' )
    git_local_hash=$(cat /usr/local/lib_bash_install/.git/refs/heads/master)
    if [[ "${git_remote_hash}" == "${git_local_hash}" ]]; then
        return 0
    else
        return 1
    fi
}

function install_lib_bash_install {
    clr_green "installing lib_bash_install"
    "$(cmd "sudo")" rm -fR /usr/local/lib_bash_install
    "$(cmd "sudo")" git clone https://github.com/bitranox/lib_bash_install.git /usr/local/lib_bash_install > /dev/null 2>&1
    set_lib_bash_install_permissions
}


function update_lib_bash_install {
    (
        # create a subshell to preserve current directory
        cd /usr/local/lib_bash_install
        "$(cmd "sudo")" git fetch --all  > /dev/null 2>&1
        "$(cmd "sudo")" git reset --hard origin/master  > /dev/null 2>&1
        set_lib_bash_install_permissions
    )
}



if [[ "${0}" == "${BASH_SOURCE[0]}" ]]; then    # if the script is not sourced
    if ! is_lib_bash_install_installed; then install_lib_bash_install ; fi   # if it is just downloaded but not installed at the right place !!!

    if ! is_lib_bash_install_up_to_date; then
        update_lib_bash_install
        source "$(readlink -f "${BASH_SOURCE[0]}")"      # source ourself
        exit 0                                           # exit the old instance
    fi

fi
