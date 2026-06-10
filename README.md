# FreeBSD-on-WG-M270

## Platform Information
The Lanner NCB-WG2511 is a proprietary, customized OEM motherboard manufactured by Lanner Electronics. It serves as the underlying hardware platform for the WatchGuard Firebox M270.  It is seen with various revisions and versions.  The information contained here was tested and verified using the NCB-WG2511A ver 0.6 motherboard.  

This model is a deriviative of the Lanner NCA-2510 Network Appliance:  
https://www.lannerinc.com/products/network-appliances/x86-rackmount-network-appliances/nca-2510 

This was often sold as a Lanner L-2510A Whitebox appliance:
https://westwardsales.com/lanner-l-2510a-whitebox-rackmount-network-appliance?srsltid=AfmBOorCIt4PT3AeSfCFhne_ryl-lUhhZY-k9MRVkmw2DgARY6MYBLXi

## NCB-WG2511 Platform Specifications
- Intel® Atom™ C3558 (Quad-Core) Denverton System-on-Chip (SoC)
- AMI SPI Flash BIOS
- Supports Intel® QuickAssist Technology
- 1x288-pin 4GB DDR4 2400MHz ECC RAM.  (MAX 16GB ECC/unbuffered or 32GB Registered)
- 1x mSATA (mini-SATA) 16KB Transcend TS16EPTMM1600L MLC NAND Flash SSD
- 1x RJ45 Console Port which supports BIOS vtty Serial Port Redirection (No need for Unix Redirection)
- 2x USB 3.0 ports
- 8x 1000Base-T ports witch connect to an on board Marvell 88E6190 / 88E6190X Switch.  None of the ports connect directly to the CPU.

### Marvell LinkStreet 88E6190/88E6190x Technical Information
- 11-Port Ethernet Switch
- 8 integrated Gigabit Ethernet Transcievers
- 2 SerDes Interfaces (Connected to CPU X553 Port 0 and Port 1)
- 1 Digitial Interface (Used for MII)

Step by step on how to configure FreeBSD on the WG M270 Platform

## Prerequisites:
Please read the prerequisites.md file.

## Hardware Preperation
Please read the hardware-prep.md file.

# Prepare to install FreeBSD


# FreeBSD Install

# CHOOSE THE FOLLOWING OPTIONS:
Choose Install
Enter your desired HostName
Select Distribution Sets (Packages, while nice, install everything and you can not install a custom kernel.  For a lean install, use Distribution Sets!)
Select the following distribution sets at a minimum
    lib-32
    (No need to select SRC as we will pull that later)
Config Network (use the USB adapter - usually something like ue0)
Choose Manual Disk Setup
    Ensure the hard disk (ada0) is selected
    Choose AUTO - should prompt you and confirm ada0 - choose entire disk - confirm
    Select GPT - GUID Partition Table
    Select Finish and Commit
Select FreeBSD Mirror and the install starts
Enter a root password
Select Proper Time Zone and skip set date and time unless wrong

# System Configuration
Select sshd, ntpd, ntpd_sync_on_start, moused, dumpdev
When prompted - select clear TMP at reboot and secure console (optional).  
NOTE: APPLY ADDITIONAL HARDENING IF GOING INTO A PRODUCTION ENVIRONMENT

At the end before reboot, enter shell and enter the following (optional if you want to ssh into the unit):

echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
exit

YOU ARE FINISHED WITH PHASE 1 AND ARE READY TO CONFIG THE KERNEL!
Reboot - remove the flash drive as soon as uhub0 is disconnected or at the BIOS screen!

# NOW LETS CONFIGURE THE KERNEL FOR THE PLATFORM SPECIFIC ITEMS!
After reboot, login as root.

# On a fresh install, first some house cleaning
pkg update && pkg upgrade -y
freebsd-update fetch && freebsd-update install

NOTE: If the freebsd-update fetch fails, you may need to update the CA Root Certs: pkg install -y ca_root_nss

reboot

# Log back in and verify the version - you will need this for later
freebsd-version -u && freebsd-version -kr

# Now lets build the custom Kernel
# If not already done, we will update the CA Root Certs otherwise git fails.
pkg install -y ca_root_nss git
rm -rf /usr/src
git clone https://git.freebsd.org/src.git /usr/src
cd /usr/src

# VERY IMPORTANT - the version you get from git MUST match the version above
git checkout release/15.0
git pull

# Now lets apply the diff patch for MDIO
cd
fetch -o /root/D50128.diff 'https://reviews.freebsd.org/D50128?download=true&id=155233'
cd /usr/src
patch -p1 < /root/D50128.diff

# IMPORTANT: Fix any errors by hand!
# Compare /usr/src/sys/modules/ix/Makefile with /usr/src/sys/modules/ix/Makefile.rej
# Normally it is only one or two entries in sys/modules/ix/Makefile

# Fix the build bug - Remove 'fdt' dependency!  
edit /usr/src/sys/conf/files

CHANGE FROM:
dev/etherswitch/e6000sw/e6000sw.c optional e6000sw fdt

CHANGE TO:
# Removed Flat Device Tree dependency for M270 Platform
# dev/etherswitch/e6000sw/e6000sw.c     optional e6000sw fdt
dev/etherswitch/e6000sw/e6000sw.c       optional e6000sw

# Create the new Kernel
# Here we create a "fake" kernel just to fix the build bug above
echo "include GENERIC" >> /usr/src/sys/amd64/conf/M270
echo "ident M270" >> /usr/src/sys/amd64/conf/M270

# And we can pre-compile the modules in the kernel vs loading them from loader.conf
echo "device etherswitch" >> /usr/src/sys/amd64/conf/M270
echo "device miiproxy" >> /usr/src/sys/amd64/conf/M270
echo "device e6000sw" >> /usr/src/sys/amd64/conf/M270

NOTE: The kernel already includes mdio, ix, miibus

OPTIONAL:  You can add any nodevice entries to supress devices in the GENERIC kernel such as nodevice speaker, etc.
There is a sample M270 kernel file in this repo.

# Create the hints file
cp /usr/src/sys/amd64/conf/GENERIC.hints /usr/src/sys/amd64/conf/M270.hints
edit /usr/src/sys/amd64/conf/M270.hints

ADD the following at the end:
hint.mdio.0.at="ix0"
hint.e6000sw.0.at="mdio1"
hint.e6000sw.0.addr="0x0"
hint.e6000sw.0.port0disabled="1"
hint.e6000sw.0.is6190x="1"
hint.e6000sw.0.port9cpu="1"
hint.e6000sw.0.port10cpu="1"
hint.e6000sw.0.port9speed="2500"
hint.e6000sw.0.port10speed="2500"

# Create the support files for the new kernel
The support files are in the github directories by path

# Build and install the kernel
cd /usr/src
make -j$(sysctl -n hw.ncpu) buildkernel KERNCONF=M270
make installkernel KERNCONF=M270
reboot

# If you pre-copied all the support files, the front ports should come up with port 0 on DHCP!


