#!/bin/bash

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

function install_and_update_language_packs {
    # $1: language_code, like "de_AT" or "de_DE"
    # install language pack and install language files for applications
    # returns Error 100 if reboot is needed (in variable $?)
    local language_code="${1}"
    local language_code_short=$( echo "${language_code}" | cut -d "_" -f 1 )
    local reboot_needed="False"
    local language_support=""
    local language_support_list=""


    if [[ "$(get_is_package_installed language-pack-de)" == "False" ]]; then
        retry $(which sudo) apt-get install language-pack-de -y
        reboot_needed="True"
    fi
    if [[ "$(get_is_package_installed language-pack-de-base)" == "False" ]]; then
        retry $(which sudo) apt-get install language-pack-de-base -y
        reboot_needed="True"
    fi
    if [[ "$(get_is_package_installed manpages-de)" == "False" ]]; then
        retry $(which sudo) apt-get install manpages-de -y
        reboot_needed="True"
    fi
    if [[ "$(get_is_package_installed language-pack-gnome-de)" == "False" ]]; then
        retry $(which sudo) apt-get install language-pack-gnome-de -y
        reboot_needed="True"
    fi

    $(which sudo) locale-gen "${language_code}"
    $(which sudo) locale-gen "${language_code}.UTF-8"
    $(which sudo) update-locale LANG="${language_code}.UTF-8" LANGUAGE="${language_code}"

    language_support_list=$(check-language-support -l "${language_code_short}")
    while IFS=$'\n' read -ra language_support_array; do
      for language_support in "${language_support_array[@]}"; do
          if [[ "$(get_is_package_installed ${language_support})" == "False" ]]; then
            retry $(which sudo) apt-get install ${language_support} -y
            reboot_needed="True"
          fi
      done
    done <<< "${language_support_list}"

    if [[ ${reboot_needed} == "True" ]]; then
        return 100
    else
        return 0
    fi
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
