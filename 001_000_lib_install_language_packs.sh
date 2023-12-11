#!/bin/bash

export bitranox_debug="True"

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

    banner "update and install language packs" | tee -a "${logfile}"

    if ! is_package_installed "language-pack-${language_code_short}"; then reboot_needed="True"; fi
    install_package_if_not_present "language-pack-${language_code_short}"

    if ! is_package_installed "language-pack-${language_code_short}-base"; then reboot_needed="True"; fi
    install_package_if_not_present "language-pack-${language_code_short}-base" "False"

    if ! is_package_installed "manpages-${language_code_short}"; then reboot_needed="True"; fi
    install_package_if_not_present "manpages-${language_code_short}" "False"

    if ! is_package_installed "language-pack-gnome-${language_code_short}"; then reboot_needed="True"; fi
    install_package_if_not_present "language-pack-gnome-${language_code_short}" "False"

    "$(cmd "sudo")" locale-gen "${language_code}"
    "$(cmd "sudo")" locale-gen "${language_code}.UTF-8"
    "$(cmd "sudo")" update-locale LANG="${language_code}.UTF-8" LANGUAGE="${language_code}"

    language_support_list=$(check-language-support -l "${language_code_short}")
    while IFS=$'\n' read -ra language_support_array; do
      for language_support in "${language_support_array[@]}"; do
          if ! is_package_installed "${language_support}"; then reboot_needed="True"; fi
          install_package_if_not_present "${language_support}" "False"
      done
    done <<< "${language_support_list}"

    if [[ ${reboot_needed} == "True" ]]; then
        return 100
    else
        return 0
    fi
}

## make it possible to call functions without source include
call_function_from_commandline "${0}" "${@}"
