#!/usr/bin/env bash

# Useage: Open a Wifi AP in debian based system;
# author: 7sDream

# Depends :
#   - hostapd & dnsmasq & nmcli is installed
#   - A network card suppose AP mode, and doesn't connect to any AP now.

# Changelog:
#   - 2015.3.7:
#       Fitst version, basic functional.
#   - 2016.2.28:
#       Chang SheBang.
#       User can interactively change interface, ssid and password without edit conf files.

# =============================

# Make sure run as SU
(( EUID != 0 )) && exec sudo -- "$0" "$@"

cd "$(dirname $0)"

# Get network card names
read -a interfaces <<< $(ip link show | sed -rn 's/^[0-9]+: (\w+):.*/\1/p')
interfaces_length=${#interfaces[@]}

# Print network card list
for ((i = 0; i < ${interfaces_length} ; i++)); do
    echo "$i: ${interfaces[$i]}"
done;

# ===== Get two network card name from user input =====
function getIndex() {
    # $1 for max length
    # $2 for interfaces description

    re_num=^[0-9]+$ # number regex
    index=-1        # user input var

    # Make sure input is an int, and don't over range
    until [[ $index =~ $re_num ]] && [ 0 -le $index ] && [ $index -le $1 ]; do
        read -p "Input index of your $2 interfaces name: " index
    done

    return $index
}

getIndex ${interfaces_length} "wireless"
wlan_interfaces_name=${interfaces[$?]}

getIndex ${interfaces_length} "ethernet"
eth_interfaces_name=${interfaces[$?]}

# ===== Set AP name =====

ssid=''

until [[ ${#ssid} -gt 0 ]]; do
    read -p "Input your wifi AP name: " ssid
done

# ===== Set password =====
password=''

until [[ ${#password} -ge 8 ]]; do
    read -p "Input your wifi AP password (8 char at least): " password
done

# ====== Gen configure file =====
sed "s/%wlan_interface%/${wlan_interfaces_name}/" dnsmasq.conf > dnsmasq.conf.true
sed -e "s/%wlan_interface%/${wlan_interfaces_name}/" -e "s/%password%/${password}/" -e "s/%ssid%/${ssid}/" hostapd.conf > hostapd.conf.true

# Turn down servces
service dnsmasq stop
service hostapd stop

# setup network
nmcli r wifi off
rfkill unblock wlan
killall hostapd
killall dnsmasq

# Open wlan
ifconfig $wlan_interfaces_name up

# Set wlan ip address
ifconfig $wlan_interfaces_name 192.168.43.1

# Configure NAT

# Delete NAT rules
iptables -t nat -F

# Add NAT rule
iptables -t nat -A POSTROUTING -o $eth_interfaces_name -j MASQUERADE

# Enable ip forwoad
sysctl net.ipv4.ip_forward=1

# ========= Open WIFI ========

echo -e "\n===== Open WiFi... =====\n"

dnsmasq -C dnsmasq.conf.true
hostapd hostapd.conf.true

echo -e "\nWiFi Stop, Cleaning......\n"

# ========= WIFI Stop ========

# Stop services
service dnsmasq stop
service hostapd stop

# Delete NAT Setting
iptables -t nat -F

# Disable ip forward
sysctl net.ipv4.ip_forward=0
nmcli r wifi on
killall hostapd
killall dnsmasq

# Delete temp configure files
rm dnsmasq.conf.true
rm hostapd.conf.true

printf "\nDone!\n"

read -n 1 -p "Press Enter key to exit..."
