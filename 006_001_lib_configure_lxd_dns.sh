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


function configure_lxd_dns_systemd_resolved_depricated {
    # systemd-resolved für domain .lxc von Bridge IP abfragen - DNSMASQ darf NICHT installiert sein !
    local bridge_ip=$(ifconfig lxdbr0 | grep 'inet' | head -n 1 | tail -n 1 | awk '{print $2}')
    "$(cmd "sudo")" mkdir -p /etc/systemd/resolved.conf.d
    "$(cmd "sudo")" sh -c "echo \"[Resolve]\nDNS=$bridge_ip\nDomains=lxd\n\" > /etc/systemd/resolved.conf.d/lxdbr0.conf"
    "$(cmd "sudo")" service systemd-resolved restart
    "$(cmd "sudo")" service network-manager restart
    "$(cmd "sudo")" snap restart lxd
}


function sub_configure_etc_hosts {
    backup_file "/etc/hosts"
    local line_to_add="127.0.10.0  $(hostname).localdomain $(hostname -f) $(hostname)  # adding loopback interface, just in case DNS is not working "
    replace_or_add_lines_containing_string_in_file "/etc/hosts" "$(hostname)" "${line_to_add}" "#"
}

function sub_disable_systemd_resolved {
    local logfile=$(get_log_file_name "${0}" "${BASH_SOURCE}" )
    backup_file "/etc/systemd/resolved.conf"
    local line_to_add="DNSStubListener=no  # preventing systemd-resolved to create a new /etc/resolv.conf"
    replace_or_add_lines_containing_string_in_file "/etc/systemd/resolved.conf" "DNSStubListener=" "${line_to_add}" "#"
    "$(cmd "sudo")" sudo service systemd-resolved stop  | tee -a "${logfile}"
    "$(cmd "sudo")" sudo systemctl disable systemd-resolved  | tee -a "${logfile}"

}

function sub_configure_network_manager {
    local logfile=$(get_log_file_name "${0}" "${BASH_SOURCE}" )
    backup_file "/etc/NetworkManager/NetworkManager.conf"
    local line_to_add="[main]${IFS}dns=none${IFS}"
    replace_or_add_lines_containing_string_in_file "/etc/NetworkManager/NetworkManager.conf" "/[main/]" "${line_to_add}" "#"
}



function configure_dnsmasq {
    local logfile=$(get_log_file_name "${0}" "${BASH_SOURCE}" )
    banner "configure dnsmasq" | tee -a "${logfile}"
    "$(cmd "sudo")" apt-get install dnsmasq | tee -a "${logfile}"
    sub_configure_etc_hosts
    sub_disable_systemd_resolved


}

function todo {
    #5 save the link to /var/run/systemd/resolve/stub-resolv.conf
    # "$(cmd "sudo")" cp /etc/resolv.conf /etc/resolv.conf.lnk.original
    # "$(cmd "sudo")" cp /var/run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

    #6 save the link to /var/run/systemd/resolve/stub-resolv.conf
    # delete comments
    # delete lines with nameserver .....

    # add lines :
    # additional nameservers to have DNS when DNSMASQ is not working
    # search  lxc - we need to test that --> das funktioniert, machen wir aber über dnsmasq wenn geht
    # nameserver 127.0.0.1 # dnsmasq
    # nameserver 1.1.1.1 # fallback if dnsmasq not working
    # nameserver 1.0.0.1 # fallback if dnsmasq not working
    # nameserver 9.9.9.9 # fallback if dnsmasq not working

     ###### ab diesem Zeitpunkt geht das Nameservice wieder !

    #7 configure DNSMASQ


    # server=/lxd/<bridge_IP>
    # PTR Queries: ???
    # server=/3.168.192.in-addr.arpa/<bridge_IP> # 3.168.192 is the reverse of 192.168.3.0/24 Subnet - the adress of the bridge !

    # ???? add line dnssec  (check if working)
    echo "todo"
}

function tests {
	clr_green "no tests in ${0}"
}


## make it possible to call functions without source include
call_function_from_commandline "${0}" "${@}"
