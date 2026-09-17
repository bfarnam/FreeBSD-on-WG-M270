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

To address this issue, you have to change the MAC address using 
```
ether random
```
or by assigning a specific MAC using any valid MAC (QEMU/KVM/libvirt use the standard Red Hat OUI prefix 52:54:00)
```
link 52:54:00:xx:yy:zz
```

After you do this, you must then put the physical ports attached to the CPU in promiscuous mode otherwise the onboard hardware filter blocks all traffic.

Also, since all of the child virtual ports inherit the parents MTU, you must set the MTU to 9000 here as well if you are going to use jumbo frames later on.

**NOTE:** Becuase of a limitation on how etherswitch works in FreeBSD, you can only perform a single ifconfig function in rc.conf.  The workaround is to create interface startup scripts in /etc such as /etc/start_if.ix0.901.  You can then execute postinit ifconfig statements on the interface, such as modifying MTU or setting the IP address.

You can add the sample rc.conf by edditing your rc.conf file:
```
edit /etc/rc.conf
```

### etc/start_if.ixn.90n
Add the start interface scripts to the /etc directory.  Besure that the naming follows what you put in rc.conf and m270_switch.  After you have added them (you can copy the samples I have) and made any changes, be sure to make them executable:

```
chmod +x /etc/start_if.ix*
```

### usr/local/etc/rc.d/m270_switch
**NOTE:** You will have to first create the directory as it seems that v16.0 does not create a /usr/local/etc directory.

```
mkdir /usr/local/etc && mkdir /usr/local/etc/rc.d
```

Add the contents of any of the sample switch files in usr/local/etc/rc.d to a new m270_switch file.
```
edit /usr/local/etc/rc.d/m270_switch
chmod +x /usr/local/etc/rc.d/m270_switch
```

