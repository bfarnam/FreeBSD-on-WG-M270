# Kernel Configuration
These are the specific steps required to re-compile the FreeBSD Kernel to utilize the onboard ethernet switch.

According to the wiki, kernel re-compile should not be required for the 16.0 release.  However, as of 16.0 beta 3 you still need to recompile the kernel.  Perhaps I am missing something, but I have not figured it out yet.

**References**
- https://wiki.freebsd.org/NetworkFirewalls/WatchguardFireboxM270
- https://wiki.freebsd.org/dev/e6000sw%284%29

## NOW LETS CONFIGURE THE KERNEL FOR THE PLATFORM SPECIFIC ITEMS!
After reboot, login as root.

### On a fresh install, first some house cleaning
**Supported in Versions: 15.0, 15.1, 16.0 beta3**
```
pkg update && pkg upgrade -y
freebsd-update fetch && freebsd-update install
```

NOTE: If the freebsd-update fetch fails, you may need to update the CA Root Certs: pkg install -y ca_root_nss

```
reboot
```

### Log back in and verify the version - you will need this for later
**Supported in Versions: 15.0, 15.1, 16.0 beta3**
```
freebsd-version -u && freebsd-version -kr
```

# FreeBSD Version 15.x ONLY
**If you have FreeBSD version 16.0, you can stop here!**

Please add the appropriate files:
- /boot/loader.conf
- /etc/rc.conf
- /usr/local/etc/rc.d/config_switch.sh

**NOTE:** Make sure to uncomment the version 16 additions which are commented out in the files!

## Now lets build the custom Kernel
**This only applies to versions 15.x!**

### If not already done, we will update the CA Root Certs otherwise git fails.
**Supported in Versions: 15.0, 15.1, 16.0 beta3**
```
pkg install -y ca_root_nss git
rm -rf /usr/src
git clone https://git.freebsd.org/src.git /usr/src
cd /usr/src
```

### VERY IMPORTANT - the version you get from git MUST match the version above
**Supported in Versions: 15.0**
```
git checkout release/15.0
git pull
```
**Supported in Versions: 15.1**
```
git checkout stable/15
git pull
```

**Supported in Versions: 16.0 beta3**
```
git checkout main
git pull
```

### Now lets apply the diff patch for MDIO
**Supported in Versions: 15.0, 15.1**
```
cd
fetch -o /root/D50128.diff 'https://reviews.freebsd.org/D50128?download=true&id=155233'
cd /usr/src
patch -p1 < /root/D50128.diff
```

### IMPORTANT: Fix any errors by hand!
### Compare /usr/src/sys/modules/ix/Makefile with /usr/src/sys/modules/ix/Makefile.rej
### Normally it is only one or two entries in /usr/src/sys/modules/ix/Makefile

### Fix the build bug - Remove 'fdt' dependency!  
**Note:** This is actually not required.  On x86 platforms, FDT is isgnored.
```
edit /usr/src/sys/conf/files

CHANGE FROM:
dev/etherswitch/e6000sw/e6000sw.c optional e6000sw fdt

CHANGE TO:
# Removed Flat Device Tree dependency for M270 Platform
# dev/etherswitch/e6000sw/e6000sw.c     optional e6000sw fdt
dev/etherswitch/e6000sw/e6000sw.c       optional e6000sw

```

### Create the new Kernel
**Supported in Versions: 15.0, 15.1, 16.0 beta3**
Here we create a "fake" kernel just to fix the build bug above
```
echo "include GENERIC" >> /usr/src/sys/amd64/conf/M270
echo "ident M270" >> /usr/src/sys/amd64/conf/M270

```

### And we can pre-compile the modules in the kernel vs loading them from loader.conf
**Supported in Versions: 15.0, 15.1, 16.0 beta3**
```
echo "device etherswitch" >> /usr/src/sys/amd64/conf/M270
echo "device miiproxy" >> /usr/src/sys/amd64/conf/M270
echo "device e6000sw" >> /usr/src/sys/amd64/conf/M270

```

**NOTE:** The kernel already includes mdio, ix, miibus

**OPTIONAL:**  You can add any nodevice entries to supress devices in the GENERIC kernel such as nodevice speaker, etc.
There is a sample M270 kernel file in this repo.

### Create the hints file
**Supported in Versions: 15.0, 15.1, 16.0 beta3**
```
cp /usr/src/sys/amd64/conf/GENERIC.hints /usr/src/sys/amd64/conf/M270.hints
edit /usr/src/sys/amd64/conf/M270.hints

# ADD the following at the end:
hint.mdio.0.at="ix0"
hint.e6000sw.0.at="mdio1"
hint.e6000sw.0.addr="0x0"
hint.e6000sw.0.port0disabled="1"
hint.e6000sw.0.is6190x="1"
hint.e6000sw.0.port9cpu="1"
hint.e6000sw.0.port10cpu="1"
hint.e6000sw.0.port9speed="2500"
hint.e6000sw.0.port10speed="2500"
```

### Create the support files for the new kernel
**Supported in Versions: 15.0, 15.1, 16.0 beta3**
The support files are in the github directories by path

### Build and install the kernel
**Supported in Versions: 15.0, 15.1, 16.0 beta3**

```
cd /usr/src
make -j$(sysctl -n hw.ncpu) buildkernel KERNCONF=M270
make installkernel KERNCONF=M270
reboot
```

## If you pre-copied all the support files, the front ports should come up with port 0 on DHCP!
