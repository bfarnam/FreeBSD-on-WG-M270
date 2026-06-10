#!/bin/sh
#
# Script to setup the switch in the M270
#

# /usr/local/etc/rc.d/configure_switch.sh
# chmod +x /usr/local/etc/rc.d/configure_switch.sh

# PROVIDE: config_switch
# REQUIRE: FILESYSTEMS
# BEFORE:  NETWORKING

name="config_switch"
rcvar="config_switch_enable"
start_cmd="config_switch_start"

config_switch_start() {
    echo "Configuring M270 Switch ... "
    logger Configuring M270 Switch ...
    
    etherswitchcfg config vlan_mode DOT1Q
    
    etherswitchcfg vlangroup1 vlan 110 members 1,9t
    etherswitchcfg vlangroup2 vlan 120 members 2,9t
    etherswitchcfg vlangroup3 vlan 130 members 3,9t
    etherswitchcfg vlangroup4 vlan 140 members 4,9t
    etherswitchcfg vlangroup5 vlan 150 members 5,10t
    etherswitchcfg vlangroup6 vlan 160 members 6,10t
    etherswitchcfg vlangroup7 vlan 170 members 7,10t
    etherswitchcfg vlangroup8 vlan 180 members 8,10t
    
    etherswitchcfg port1 pvid 110
    etherswitchcfg port2 pvid 120
    etherswitchcfg port3 pvid 130
    etherswitchcfg port4 pvid 140
    etherswitchcfg port5 pvid 150
    etherswitchcfg port6 pvid 160
    etherswitchcfg port7 pvid 170
    etherswitchcfg port8 pvid 180
    
    echo "M270 Switch Configuration Complete"
    logger M270 Switch Configuration Complete
}
load_rc_config $name
run_rc_command "$1"
