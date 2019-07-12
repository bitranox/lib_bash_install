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

include_dependencies


function configure_lxd_dns_systemd_resolved_depricated {
    # systemd-resolved für domain .lxc von Bridge IP abfragen - DNSMASQ darf NICHT installiert sein !
    local bridge_ip=$(ifconfig lxdbr0 | grep 'inet' | head -n 1 | tail -n 1 | awk '{print $2}')
    $(which sudo) mkdir -p /etc/systemd/resolved.conf.d
    $(which sudo) sh -c "echo \"[Resolve]\nDNS=$bridge_ip\nDomains=lxd\n\" > /etc/systemd/resolved.conf.d/lxdbr0.conf"
    $(which sudo) service systemd-resolved restart
    $(which sudo) service network-manager restart
    $(which sudo) snap restart lxd
}



#1 dnsmasq
$(which sudo) apt-get install dnsmasq

#2 /etc/hosts - to have loopback when DNS is not working
backupfile /etc/hosts
# adding loopback interface, just in case DNS is not working
ADD 127.0.10.0  $(hostname).localdomain $(hostname -f) $(hostname)

#3 /etc/systemd/resolved.conf

ADD DNSStubListener=no

#4 switch off and disable systemd-resolved
sudo service systemd-resolved stop
sudo systemctl disable systemd-resolved

#4b configure Network-manager
/etc/NetworkManager/NetworkManager.conf

[main]
dns=none    # prevents to create a new /etc/resolv.conf


#5 save the link to /var/run/systemd/resolve/stub-resolv.conf
$(which sudo) cp /etc/resolv.conf /etc/resolv.conf.lnk.original
$(which sudo) cp /var/run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

#6 save the link to /var/run/systemd/resolve/stub-resolv.conf
delete comments
delete lines with nameserver .....

add lines :
# additional nameservers to have DNS when DNSMASQ is not working
# domain lxc - we need to test that
nameserver 127.0.0.1 # dnsmasq
nameserver 1.1.1.1 # fallback if dnsmasq not working
nameserver 1.0.0.1 # fallback if dnsmasq not working
nameserver 9.9.9.9 # fallback if dnsmasq not working

###### ab diesem Zeitpunkt geht das Nameservice wieder !

#7 configure DNSMASQ


server=/lxc/<bridge_IP>
# PTR Queries: ???
server=/3.168.192.in-addr.arpa/<bridge_IP> # 3.168.192 is the reverse of 192.168.3.0/24 Subnet - the adress of the bridge !

???? add line dnssec  (check if working)






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


