#!/bin/bash

# function include_dependencies {
#     my_dir="$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )"  # this gives the full path, even for sourced scripts
#     source "${my_dir}/lib_color.sh"
#     source "${my_dir}/lib_helpers.sh"
#
# }
#
# include_dependencies  # we need to do that via a function to have local scope of my_dir

function install_or_update_lib_bash {
    if [[ -f "/usr/local/lib_bash/install_or_update.sh" ]]; then
        # $(which sudo) /usr/local/lib_bash/install_or_update.sh
        echo "lib_bash already installed"
    else
        $(which sudo) rm -fR /usr/local/lib_bash
        $(which sudo) git clone https://github.com/bitranox/lib_bash.git /usr/local/lib_bash > /dev/null 2>&1
        $(which sudo) chmod -R 0755 /usr/local/lib_bash
        $(which sudo) chmod -R +x /usr/local/lib_bash/*.sh
        $(which sudo) chown -R root /usr/local/lib_bash || $(which sudo) chown -R ${USER} /usr/local/lib_bash  || echo "giving up set owner" # there is no user root on travis
        $(which sudo) chgrp -R root /usr/local/lib_bash || $(which sudo) chgrp -R ${USER} /usr/local/lib_bash  || echo "giving up set group" # there is no user root on travis
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
    $(which sudo) chmod -R 0755 /usr/local/lib_bash_install
    $(which sudo) chmod -R +x /usr/local/lib_bash_install/*.sh
    $(which sudo) chown -R root /usr/local/lib_bash_install || $(which sudo) chown -R ${USER} /usr/local/lib_bash_install || echo "giving up set owner" # there is no user root on travis
    $(which sudo) chgrp -R root /usr/local/lib_bash_install || $(which sudo) chgrp -R ${USER} /usr/local/lib_bash_install || echo "giving up set group" # there is no user root on travis
}

function is_lib_bash_install_installed {
        if [[ -f "/usr/local/lib_bash_install/install_or_update.sh" ]]; then
            echo "True"
        else
            echo "False"
        fi
}


function is_lib_bash_install_to_update {
    local git_remote_hash=$(git --no-pager ls-remote --quiet https://github.com/bitranox/lib_bash_install.git | grep HEAD | awk '{print $1;}' )
    local git_local_hash=$( $(which sudo) cat /usr/local/lib_bash_install/.git/refs/heads/master)
    if [[ "${git_remote_hash}" == "${git_local_hash}" ]]; then
        echo "False"
    else
        echo "True"
    fi
}

function install_lib_bash_install {
    clr_green "installing lib_bash_install"
    $(which sudo) rm -fR /usr/local/lib_bash_install
    $(which sudo) git clone https://github.com/bitranox/lib_bash_install.git /usr/local/lib_bash_install > /dev/null 2>&1
    set_lib_bash_install_permissions
}


function update_lib_bash_install {
    if [[ $(is_lib_bash_install_to_update) == "True" ]]; then
        clr_green "lib_bash_install needs to update"
        (
            # create a subshell to preserve current directory
            cd /usr/local/lib_bash_install
            $(which sudo) git fetch --all  > /dev/null 2>&1
            $(which sudo) git reset --hard origin/master  > /dev/null 2>&1
            set_lib_bash_install_permissions
        )
        clr_green "lib_bash_install update complete"
    else
        clr_green "lib_bash_install is up to date"
    fi
}

function restart_calling_script {
    local caller_command=("$@")
    if [ ${#caller_command[@]} -eq 0 ]; then
        # no parameters passed
        exit 0
    else
        # parameters passed, running the new Version of the calling script
        "${caller_command[@]}"
        # exit this old instance with error code 100
        exit 100
    fi

}

if [[ $(is_lib_bash_install_installed) == "True" ]]; then
    update_lib_bash_install
    restart_calling_script  "${@}"  # needs caller name and parameters
else
    install_lib_bash_install
fi
