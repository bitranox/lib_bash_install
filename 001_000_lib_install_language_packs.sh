#!/bin/bash

export bitranox_debug="True"

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

include_dependencies

function install_language_packs {
    # $1: language_code, like "de_AT" or "de_DE"
    # install language pack and install language files for applications
    # returns Error 100 if reboot is needed (in variable $?)
    local language_code="${1}"
    local language_code_short=$( echo "${language_code}" | cut -d "_" -f 1 )
    local reboot_needed="False"
    local language_support=""
    local language_support_list=""
    local logfile=$(get_log_file_name "${0}" "${BASH_SOURCE}" )

    banner "update and install language packs"   | tee -a "${logfile}"

    if [[ "$(get_is_package_installed language-pack-${language_code_short})" == "False" ]]; then
        retry $(get_sudo) apt-get install language-pack-${language_code_short} -y | tee -a "${logfile}"
        reboot_needed="True"
    fi
    if [[ "$(get_is_package_installed language-pack-${language_code_short}-base)" == "False" ]]; then
        retry $(get_sudo) apt-get install language-pack-${language_code_short}-base -y  | tee -a "${logfile}"
        reboot_needed="True"
    fi
    if [[ "$(get_is_package_installed manpages-${language_code_short})" == "False" ]]; then
        retry $(get_sudo) apt-get install manpages-${language_code_short} -y  | tee -a "${logfile}"
        reboot_needed="True"
    fi
    if [[ "$(get_is_package_installed language-pack-gnome-${language_code_short})" == "False" ]]; then
        retry $(get_sudo) apt-get install language-pack-gnome-${language_code_short} -y  | tee -a "${logfile}"
        reboot_needed="True"
    fi

    $(get_sudo) locale-gen "${language_code}" | tee -a "${logfile}"
    $(get_sudo) locale-gen "${language_code}.UTF-8" | tee -a "${logfile}"
    $(get_sudo) update-locale LANG="${language_code}.UTF-8" LANGUAGE="${language_code}" | tee -a "${logfile}"

    language_support_list=$(check-language-support -l "${language_code_short}")
    while IFS=$'\n' read -ra language_support_array; do
      for language_support in "${language_support_array[@]}"; do
          if [[ "$(get_is_package_installed ${language_support})" == "False" ]]; then
            retry $(get_sudo) apt-get install ${language_support} -y  | tee -a "${logfile}"
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

function tests {
	clr_green "no tests in ${0}"
}


## make it possible to call functions without source include
call_function_from_commandline "${0}" "${@}"
