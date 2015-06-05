#!/bin/bash

# Useage : Open a Wifi AP;
# author : 7sDream
# Data : 2015.3.7

# Need : hostapd & dnsmasq & nmcli is installed , wlan0 suppose AP mode, doesn't connect to any AP now.

# =============================
# Turn down servces
service dnsmasq stop
service hostapd stop

# setup network
nmcli r wifi off
rfkill unblock wlan
killall hostapd
killall dnsmasq

# Open wlan0
ifconfig wlan0 up

# Set wlan0 ip address
ifconfig wlan0 192.168.43.1

# Configure NAT

# Delete NAT rules
iptables -t nat -F

# Add NAT rule
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Enable ip forwoad
sysctl net.ipv4.ip_forward=1


# ========= Open WIFI ========

echo -e "\n===== Open WiFi... =====\n"

dnsmasq -C dnsmasq.conf
hostapd hostapd.conf

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

printf "\nDone!\n"

read -n 1 -p "Press Enter key to exit..."

