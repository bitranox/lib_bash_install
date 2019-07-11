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

function install_diverse_tools {
    local logfile=$(get_log_file_name "${0}" "${BASH_SOURCE}" )
    banner "install needed tools : build-essential, mc, geany, meld, synaptic, x2goclient"  | tee -a "${logfile}"

    ### remove Canonical Reporting
    $(which sudo) apt-get purge whoopsie -y | tee -a "${logfile}"
    $(which sudo) apt-get purge libwhoopsie0 -y | tee -a "${logfile}"
    $(which sudo) apt-get purge libwhoopsie-preferences0 -y | tee -a "${logfile}"
    $(which sudo) apt-get purge apport -y | tee -a "${logfile}"
    # essential
    retry $(which sudo) apt-get install net-tools -y | tee -a "${logfile}"
    retry $(which sudo) apt-get install git -y | tee -a "${logfile}"
    # build-essential
    retry $(which sudo) apt-get install build-essential -y | tee -a "${logfile}"
    # midnight commander
    retry $(which sudo) apt-get install mc -y | tee -a "${logfile}"
    # geany Editor
    retry $(which sudo) apt-get purge enchant -y | tee -a "${logfile}"
    retry $(which sudo) apt-get purge gedit -y | tee -a "${logfile}"
    retry $(which sudo) apt-get purge gedit-common -y | tee -a "${logfile}"
    retry $(which sudo) apt-get purge pluma-common -y | tee -a "${logfile}"
    retry $(which sudo) apt-get purge tilda -y | tee -a "${logfile}"
    retry $(which sudo) apt-get purge vim -y | tee -a "${logfile}"
    retry $(which sudo) apt-get install geany -y | tee -a "${logfile}"
    # Meld Vergleichstool
    retry $(which sudo) apt-get install meld -y | tee -a "${logfile}"
    # Paketverwaltung
    retry $(which sudo) apt-get install synaptic -y | tee -a "${logfile}"
    # x2go client
    retry $(which sudo) apt-get install x2goclient -y | tee -a "${logfile}"
}



function install_chrome {
    local logfile=$(get_log_file_name "${0}" "${BASH_SOURCE}" )
    banner "Install google chrome" | tee -a "${logfile}"
    retry $(which sudo) apt-get install fonts-liberation -y | tee -a "${logfile}"
    retry $(which sudo) apt-get install xdg-utils -y | tee -a "${logfile}"
    retry $(which sudo) wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb | tee -a "${logfile}"
    retry $(which sudo) dpkg -i google-chrome-stable_current_amd64.deb | tee -a "${logfile}"
    $(which sudo) rm -f ./google-chrome-stable_current_amd64.deb | tee -a "${logfile}"
}

function install_chrome_remote_desktop {
    local logfile=$(get_log_file_name "${0}" "${BASH_SOURCE}" )
    banner "Install google chrome remote desktop" | tee -a "${logfile}"
    retry $(which sudo) apt-get install xvfb -y | tee -a "${logfile}"
    retry $(which sudo) apt-get install xbase-clients -y | tee -a "${logfile}"
    retry $(which sudo) apt-get install python-psutil -y | tee -a "${logfile}"
    retry $(which sudo) wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb | tee -a "${logfile}"
    retry $(which sudo) dpkg -i chrome-remote-desktop_current_amd64.deb | tee -a "${logfile}"
    $(which sudo) rm -f ./chrome-remote-desktop_current_amd64.deb | tee -a "${logfile}"
    replace_or_add_lines_containing_string_in_file "/etc/environment" "CHROME_REMOTE_DESKTOP_DEFAULT_DESKTOP_SIZES" "CHROME_REMOTE_DESKTOP_DEFAULT_DESKTOP_SIZES=\"5120x1600\""
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
