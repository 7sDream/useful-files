#!/bin/bash

# Useage : Open a Wifi AP;
# author : 7sDream
# Data : 2014.07.13

# Need : hostapd & dnsamsq is installed , wlan0 suppose AP mode, doesn't connect to any AP now.

# =============================

# Define configure file path
HOSTAPD_CONF_PATH="/etc/hostapd.conf"
DNSAMSQ_CONF_PATH="/etc/dnsmasq.conf"

# Turn down servces
service dnsmasq stop
service hostapd stop

# Backup configure files
mv "$HOSTAPD_CONF_PATH" "${HOSTAPD_CONF_PATH}.old"
mv "$DNSAMSQ_CONF_PATH" "${DNSAMSQ_CONF_PATH}.old"

# Read WiFi Setting
read -p "Please your AP name : " apName
read -p "Please your AP password : " apPwd

# Modify hostapd configure file
echo "# Define interface" > "$HOSTAPD_CONF_PATH"
echo "interface=wlan0" >> "$HOSTAPD_CONF_PATH"
echo "# Select driver" >> "$HOSTAPD_CONF_PATH"
echo "driver=nl80211" >> "$HOSTAPD_CONF_PATH"
echo "# Set access point name" >> "$HOSTAPD_CONF_PATH"
echo "ssid=$apName" >> "$HOSTAPD_CONF_PATH"
echo "# Set access point harware mode to 802.11g" >> "$HOSTAPD_CONF_PATH"
echo "hw_mode=g" >> "$HOSTAPD_CONF_PATH"
echo "# Set WIFI channel (can be easily changed)" >> "$HOSTAPD_CONF_PATH"
echo "channel=6" >> "$HOSTAPD_CONF_PATH"
echo "# Enable WPA2 only (1 for WPA, 2 for WPA2, 3 for WPA + WPA2)" >> "$HOSTAPD_CONF_PATH"
echo "wpa=3" >> "$HOSTAPD_CONF_PATH"
echo "wpa_passphrase=$apPwd" >> "$HOSTAPD_CONF_PATH"

# Modify dnsamsq configure file
echo "interface=wlan0" > "$DNSAMSQ_CONF_PATH"
echo "bind-interfaces" >> "$DNSAMSQ_CONF_PATH"
echo "dhcp-range=192.168.43.2,192.168.43.10" >> "$DNSAMSQ_CONF_PATH"
echo "dhcp-option=option:router,192.168.43.1" >> "$DNSAMSQ_CONF_PATH" 

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

# start services
service dnsmasq start
service hostapd start

# ========= Open WIFI ========

echo -e "\n===== Open WiFi... =====\n"

hostapd "$HOSTAPD_CONF_PATH"

echo -e "\nWiFi Stop, Cleaning......\n"

# ========= WIFI Stop ========

# Stop services
service dnsmasq stop
service hostapd stop

# Delete NAT Setting
iptables -t nat -F

# Disable ip forward
sysctl net.ipv4.ip_forward=0

# Restore configure files
rm "$HOSTAPD_CONF_PATH"
rm "$DNSAMSQ_CONF_PATH"
mv "${HOSTAPD_CONF_PATH}.old" "$HOSTAPD_CONF_PATH"
mv "${DNSAMSQ_CONF_PATH}.old" "$DNSAMSQ_CONF_PATH"

printf "\nDone!\n"

read -n 1 -p "Press any key to exit..."