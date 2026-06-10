# FreeBSD Install
In order to install FreeBSD to the internal mSATA in prep for recompiling the kernel, please follow this guide.

## Assumptions:
- You have completed the steps in prerequistes.md and hardware-prep.md

## Steps
1. Ensure that the M270 is powered off and unplugged from the mains.
2. Connect the Serial Console Cable between the M270 and your PC.
You should set your terminal to 115200,N,8,1.
3. Insert the USB drive into one of the USB ports.
4. Insert the USB to Ethernet adapter into the other USB port.
5. Powerup the M270.
6. When the FreeBSD installer boots, select Boot Installer (default on timer)
7. Choose the console type of vt100 (default)
8. Choose Install (default)
9. Choose your keymap
10. Enter your desired Hostname
11. **Select Distribution Sets** (Packages, while nice, install everything and you can not install a custom kernel.  For a lean install, use Distribution Sets!)
12. Select the following distribution sets at a minimum
    - lib-32
    (No need to select SRC as we will pull that later)
13. Config Network (use the USB adapter - usually something like ue0).  Select the appropriate Network configuration (Auto or Manual) for your environment.
14. Choose Manual Disk Setup
    - Ensure the hard disk (ada0) is selected
    - Choose AUTO - should prompt you and confirm ada0 - choose entire disk - confirm
    - Select GPT - GUID Partition Table
    - Select Finish and Commit
15. Select FreeBSD Mirror and the install starts
16. Enter a root password
17. Select Proper Time Zone and skip set date and time unless wrong

### System Configuration
18. Select sshd, ntpd, ntpd_sync_on_start, moused, dumpdev
19. When prompted - select clear TMP at reboot and secure console (optional).  
NOTE: APPLY ADDITIONAL HARDENING IF GOING INTO A PRODUCTION ENVIRONMENT

### At the end before reboot, enter shell and enter the following (optional if you want to ssh into the unit):
```
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
exit
```

### YOU ARE FINISHED WITH PHASE 1 AND ARE READY TO CONFIG THE KERNEL!
Reboot - remove the flash drive as soon as uhub0 is disconnected or at the BIOS screen!