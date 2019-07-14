#!/bin/bash


export bitranox_debug="True"


function update_myself {
    /usr/local/lib_bash_install/install_or_update.sh "${@}" || exit 0              # exit old instance after updates
}


update_myself ${0} ${@}  > /dev/null 2>&1  # suppress messages here, not to spoil up answers from functions when called verbatim


function include_dependencies {
    source /usr/local/lib_bash/lib_color.sh
    source /usr/local/lib_bash/lib_retry.sh
    source /usr/local/lib_bash/lib_helpers.sh
    source /usr/local/lib_bash_install/900_000_lib_install_basics.sh
}

function remove_unnecessary {
    local logfile=$(get_log_file_name "${0}" "${BASH_SOURCE}" )
    banner "remove_unnecessary"   | tee -a "${logfile}"

    ### remove Canonical Reporting
    $(which sudo) apt-get purge whoopsie -y  | tee -a "${logfile}"
    $(which sudo) apt-get purge libwhoopsie0 -y  | tee -a "${logfile}"
    $(which sudo) apt-get purge libwhoopsie-preferences0 -y  | tee -a "${logfile}"
    $(which sudo) apt-get purge apport -y  | tee -a "${logfile}"
    ### Bluetooth
    $(which sudo) apt-get purge blueman -y  | tee -a "${logfile}"
    $(which sudo) apt-get purge bluez -y  | tee -a "${logfile}"
    $(which sudo) apt-get purge bluez-cups -y  | tee -a "${logfile}"
    $(which sudo) apt-get purge bluez-obexd -y  | tee -a "${logfile}"
    # CD Brenner
    $(which sudo) apt-get purge brasero -y  | tee -a "${logfile}"
    $(which sudo) apt-get purge brasero-cdrkit -y  | tee -a "${logfile}"
    $(which sudo) apt-get purge brasero-common -y  | tee -a "${logfile}"
    $(which sudo) apt-get purge cdrdao -y  | tee -a "${logfile}"
    $(which sudo) apt-get purge dvd+rw-tools -y  | tee -a "${logfile}"
    $(which sudo) apt-get purge dvdauthor -y  | tee -a "${logfile}"
    $(which sudo) apt-get purge growisofs -y  | tee -a "${logfile}"
    $(which sudo) apt-get purge libburn4 -y  | tee -a "${logfile}"
    # Musik
    $(which sudo) apt-get purge rhythmbox -y  | tee -a "${logfile}"
    $(which sudo) apt-get purge rhythmbox-data -y  | tee -a "${logfile}"
    # Braille für Blinde
    $(which sudo) apt-get purge brltty -y  | tee -a "${logfile}"
    $(which sudo) apt-get purge libbrlapi0.6 -y  | tee -a "${logfile}"
    $(which sudo) apt-get purge xzoom -y  | tee -a "${logfile}"
    # Webcam
    $(which sudo) apt-get purge cheese -y  | tee -a "${logfile}"
    $(which sudo) apt-get purge cheese-common -y  | tee -a "${logfile}"
    # Taschenrechner
    $(which sudo) apt-get purge dc -y  | tee -a "${logfile}"
    # editoren / Terminals
    $(which sudo) apt-get purge enchant -y  | tee -a "${logfile}"
    $(which sudo) apt-get purge gedit -y  | tee -a "${logfile}"
    $(which sudo) apt-get purge gedit-common -y  | tee -a "${logfile}"
    $(which sudo) apt-get purge pluma-common -y  | tee -a "${logfile}"
    $(which sudo) apt-get purge tilda -y  | tee -a "${logfile}"
    $(which sudo) apt-get purge vim -y  | tee -a "${logfile}"
    # Bildbetrachter / Scanner
    $(which sudo) apt-get purge eog -y  | tee -a "${logfile}"
    $(which sudo) apt-get purge shotwell-common -y  | tee -a "${logfile}"
    $(which sudo) apt-get purge simple-scan -y  | tee -a "${logfile}"
    # Sprachausgabe
    $(which sudo) apt-get purge espeak-ng-data -y  | tee -a "${logfile}"
    # Dateibetrachter
    $(which sudo) apt-get purge evince-common -y  | tee -a "${logfile}"
    # video
    $(which sudo) apt-get purge ffmpegthumbnailer -y  | tee -a "${logfile}"
    # gdm3 Gnome Display Manager
    $(which sudo) apt-get purge gdm3 -y  | tee -a "${logfile}"
    # Bildbearbeitung
    $(which sudo) apt-get purge imagemagick-6.q16 -y  | tee -a "${logfile}"
    # Libre Office
    $(which sudo) apt-get purge libreoffice-common -y  | tee -a "${logfile}"
    $(which sudo) apt-get purge ure -y  | tee -a "${logfile}"
    # Dateimanager
    $(which sudo) apt-get purge nautilus -y  | tee -a "${logfile}"
    $(which sudo) apt-get purge nautilus-data -y  | tee -a "${logfile}"
    $(which sudo) apt-get purge nautilus-extension-gnome-terminal -y  | tee -a "${logfile}"
    $(which sudo) apt-get purge nautilus-sendto -y  | tee -a "${logfile}"
    # Bildschirmtastatur
    $(which sudo) apt-get purge onboard -y  | tee -a "${logfile}"
    $(which sudo) apt-get purge onboard-common -y  | tee -a "${logfile}"
    # Dock
    $(which sudo) apt-get purge plank -y  | tee -a "${logfile}"
    # thunderbird
    $(which sudo) apt-get purge thunderbird -y  | tee -a "${logfile}"
    $(which sudo) apt-get purge transmission-common -y  | tee -a "${logfile}"
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
