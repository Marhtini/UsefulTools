#!/bin/bash
# by Marhtini
# autoproxy script, for transparent proxy
# sets all required iptable rules
# run this on the proxy server

# TODO: Will need to add persistance after reboot
# TODO: this might require iptables-persistant.
# TODO: Input Validation, Forwarding to different ports

echo "-= AutoProxy by Marhtini =-"
if [ "$(whoami)" != "root" ]; then
    echo "You Must Run This Script With SUDO or as ROOT."
    echo "Exiting..."
    exit 1
fi

echo "[!] ATTENTION: Would you like to clear IPTABLES Rules? (y/n)"
read iptable_decision

if [ "$iptable_decision" = 'y' ]; then
    echo "[-] Clearing IPTables..."
    echo 1 > /proc/sys/net/ipv4/ip_forward
    iptables -F
    iptables -t nat -F
    iptables -X
    echo "[*] Done!"
fi

if [ "$iptable_decision" != 'y' ]; then
    echo "[*] Leaving IPTables Intact."
fi

echo "[+] Enter the Proxy Server IPv4 Address (This Host!)"
read proxyip

echo "[+] Enter the Destination IPv4 Address"
read dstip

echo "[+] Enter ports you would like to forward, seperated by spaces:"
read portstring
portarray=($portstring)

for port in $portstring; do
    ip_port_combo=$dstip":"$port
    iptables -t nat -A PREROUTING -p tcp --dport $port -j DNAT --to-destination $ip_port_combo
    iptables -t nat -A POSTROUTING -p tcp -d $dstip --dport $port -j SNAT --to-source $proxyip
done

echo "[!] Complete! See Below:"
echo ""
iptables -t nat -L
