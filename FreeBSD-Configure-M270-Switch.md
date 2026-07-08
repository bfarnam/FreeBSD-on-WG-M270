# FreeBSD Configure M270 Switch

## FreeBSD Version 16-CURRENT
After FreeBSD has been installed and you have booted into the base OS, please update/or create the following files:

### loader.conf
Add the contents of the sample boot/loader.conf file to the end of loader.conf
```
edit /boot/loader.conf
```

### etc/rc.conf
Add the contents of the sample etc/rc.conf file to the end of rc.conf.  Don't forget to comment out the USB adapter configure commands in the rc.conf so that the switch will come up.  

**NOTE:** Because of the way the Marvel Switch was implemented in this hardware and the way the switch ports are activated, every port that comes up has the exact same MAC address as every other M270.  I have tested this on three seperate devices and they all have the same MAC: 34:12:78:56:01:03.

To address this issue, there is a ifconfig ether random statement in the sample file.

```
edit /etc/rc.conf
```

### usr/local/etc/rc.d/configure_switch.sh
**NOTE:** You will have to first create the directory as it seems that v16.0 does not create a /usr/local/etc directory.

```
mkdir /usr/local/etc && mkdir /usr/local/etc/rc.d
```

Add the contents of the sample usr/local/etc/rc.d/configure_switch.sh to a new configure_switch.sh file.

```
edit /usr/local/etc/rc.d/configure_switch.sh
chmod +x /usr/local/etc/rc.d/configure_switch.sh
```

