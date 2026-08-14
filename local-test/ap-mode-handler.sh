#!/bin/bash

set -e

source ap-mode-handler.env

# Turn on AP mode.
ap_mode_on() {
    echo ">>> STARTING WIRELESS AP MODE"

    echo ">>> Unmanage $WRLS_IFACE with nmcli..."
    nmcli device set $WRLS_IFACE managed no

    # Cycle wifi Interface for better process reliability.
    echo ">>> Set $WRLS_IFACE down..."
    ip link set $WRLS_IFACE down

    echo ">>> Set $WRLS_IFACE up..."
    ip link set $WRLS_IFACE up

    # Configure the wifi interface with a static IP address and the
    # correct subnet broadcast address.
    echo ">>> Set $WRLS_IFACE IP to $WRLS_IFACE_IP..."
    ip addr replace $WRLS_IFACE_IP broadcast $WRLS_BCAST_IP dev $WRLS_IFACE

    # Stopping and starting makes the process of running hostapd
    # more reliable.
    echo ">>> Stopping hostapd"
    systemctl stop hostapd

    # Hostapd turns the current system into a wireless access point.
    echo ">>> Staring hostapd"
    systemctl start hostapd

    # DNSMasq provides DHCP and DNS.
    echo ">>> Staring dnsmasq"
    systemctl start dnsmasq
}


# Turn off AP mode.
ap_mode_off() {
    echo ">>> STOPPING WIRELESS AP MODE"

    # Allow steps to fail and keep going.
    set +e

    echo ">>> Stopping dnsmasq..."
    systemctl stop dnsmasq

    echo ">>> Stopping hostapd..."
    systemctl stop hostapd

    echo ">>> Running netplan apply to restore network settings..."
    netplan apply 

    set -e
}


# Turn AP mode on if we're not already on a network.
auto_ap_mode() {
    echo ">>> AUTO AP MODE SELECTOR"

    set +e

    # Detect whether or not we're connected.
    iw $WRLS_IFACE link | grep -q 'Connected to'
    WRLS_IFACE_CONNECTED=$?

    set -e

    if [ $WRLS_IFACE_CONNECTED -eq 0 ]; then
        echo ">>> Already connected to a WiFi network. NOT activating AP mode."
    else
        echo ">>> NOT connected to a WiFi network. Activating AP mode."
        ap_mode_on
    fi
}


# Run AP auto mode after a programmed delay.
auto_ap_mode_delay() {
    echo ">>> AUTO AP MODE RUNNING AFTER $AUTO_DELAY_SEC SECONDS"

    sleep $AUTO_DELAY_SEC

    auto_ap_mode
}


# Track whether to print help and which exit code to use at script exit.
AP_MODE="none"
PRINT_HELP="false"
EXIT_CODE=0

# See if we actually got an argument.
if [[ "$1" != "" ]]; then

    # Check to make sure we're running as root.
    if [ "$UID" == "0" ]; then
        # Grab first positional argument.
        AP_MODE=$1
    else
        AP_MODE="nop"
        PRINT_HELP="true"
        # TODO: change me to permissions error?
        EXIT_CODE=1 
        echo "ERROR: this script must be run as root."
        echo ""
    fi

    # Pick a mode or generate an error.
    if [ $AP_MODE == "on" ]; then
        ap_mode_on
    elif [ $AP_MODE == "off" ]; then
        ap_mode_off
    elif [ $AP_MODE == "auto" ]; then
        auto_ap_mode
    elif [ $AP_MODE == "auto-delay" ]; then
        auto_ap_mode_delay
    elif [ $AP_MODE == "help" ]; then
        PRINT_HELP="true"
    elif [ $AP_MODE == "nop" ]; then
        PRINT_HELP="true"
    else
        # Print error mesage, print help, and exit with code 1.
        PRINT_HELP="true"
        EXIT_CODE=1
        echo "ERROR: Invalid argument. Got '$AP_MODE'.";
        echo ""
    fi

else
    # Print error mesage, print help, and exit with code 1.
    PRINT_HELP="true"
    EXIT_CODE=1
    echo "ERROR: Missing positional argument.";
    echo ""
fi


# Print help before exiting?
if [ $PRINT_HELP == "true" ]; then
    echo "ap-mode-handler.sh manages wireless access point functionality."
    echo ""
    echo "NOTE: The script must be run as root."
    echo ""
    echo 'Supported positional arguemnts are "on", "off", "auto", or "help".';
    echo ""
    echo "Argument list:"
    echo " auto:       Will turn access point mode on if the system isn't connected"
    echo "             to a wireless network. Auto mode does not turn the wireless"
    echo "             access pont mode off since the script is unaware of the"
    echo "             system's known wireless networks. The script must be run in"
    echo "             off mode or the system rebooted to rejoin known wireless"
    echo "             networks."
    echo " auto-delay: Run the "auto" command after $AUTO_DELAY_SEC seconds."
    echo " on:         Turns on wireless access point mode."
    echo " off:        Turns wireless access point mode off."
    echo " help:       Prints this message."
fi

# Exit with the specified exit code.
exit $EXIT_CODE
