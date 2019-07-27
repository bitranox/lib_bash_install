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

function remove_unnecessary {
    banner "remove_unnecessary"

    ### remove Canonical Reporting
    uninstall_package_if_present "whoopsie"
    uninstall_package_if_present "libwhoopsie0"
    uninstall_package_if_present "libwhoopsie-preferences0"
    uninstall_package_if_present "apport"
    ### Bluetooth
    uninstall_package_if_present "blueman"
    uninstall_package_if_present "bluez"
    uninstall_package_if_present "bluez-cups"
    uninstall_package_if_present "bluez-obexd"
    # CD Brenner
    uninstall_package_if_present "brasero"
    uninstall_package_if_present "brasero-cdrkit"
    uninstall_package_if_present "brasero-common"
    uninstall_package_if_present "cdrdao"
    uninstall_package_if_present "dvd+rw-tools"
    uninstall_package_if_present "dvdauthor"
    uninstall_package_if_present "growisofs"
    uninstall_package_if_present "libburn4"
    # Musik
    uninstall_package_if_present "rhythmbox"
    uninstall_package_if_present "rhythmbox-data"
    # Braille für Blinde
    uninstall_package_if_present "brltty"
    uninstall_package_if_present "libbrlapi0.6"
    uninstall_package_if_present "xzoom"
    # Webcam
    uninstall_package_if_present "cheese"
    uninstall_package_if_present "cheese-common"
    # Taschenrechner
    uninstall_package_if_present "dc"
    # editoren / Terminals
    uninstall_package_if_present "enchant"
    uninstall_package_if_present "gedit"
    uninstall_package_if_present "gedit-common"
    uninstall_package_if_present "pluma-common"
    uninstall_package_if_present "tilda"
    uninstall_package_if_present "vim"
    # Bildbetrachter / Scanner
    uninstall_package_if_present "eog"
    uninstall_package_if_present "shotwell-common"
    uninstall_package_if_present "simple-scan"
    # Sprachausgabe
    uninstall_package_if_present "espeak-ng-data"
    # Dateibetrachter
    uninstall_package_if_present "evince-common"
    # video
    uninstall_package_if_present "ffmpegthumbnailer"
    # gdm3 Gnome Display Manager
    uninstall_package_if_present "gdm3"
    # Bildbearbeitung
    uninstall_package_if_present "imagemagick-6.q16"
    uninstall_package_if_present "imagemagick"
    # Libre Office
    uninstall_package_if_present "libreoffice-common"
    uninstall_package_if_present "ure"
    # Dateimanager
    uninstall_package_if_present "nautilus"
    uninstall_package_if_present "nautilus-data"
    uninstall_package_if_present "nautilus-extension-gnome-terminal"
    uninstall_package_if_present "nautilus-sendto"
    # Bildschirmtastatur
    uninstall_package_if_present "onboard"
    uninstall_package_if_present "onboard-common"
    # Dock
    uninstall_package_if_present "plank"
    # thunderbird
    uninstall_package_if_present "thunderbird"
    # peer-to-peer
    uninstall_package_if_present "transmission-common"
}


## make it possible to call functions without source include
call_function_from_commandline "${0}" "${@}"
