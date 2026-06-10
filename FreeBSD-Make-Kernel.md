# Kernel Configuration
These are the specific steps required to re-compile the FreeBSD Kernel to utilize the onboard ethernet switch.

As of v16 this is supposedly pre-baked into the kernel.  If you can't use v16, these are the steps to make everything work.

**References**
- https://wiki.freebsd.org/NetworkFirewalls/WatchguardFireboxM270
- https://wiki.freebsd.org/dev/e6000sw%284%29

## NOW LETS CONFIGURE THE KERNEL FOR THE PLATFORM SPECIFIC ITEMS!
After reboot, login as root.

### On a fresh install, first some house cleaning
pkg update && pkg upgrade -y
freebsd-update fetch && freebsd-update install

NOTE: If the freebsd-update fetch fails, you may need to update the CA Root Certs: pkg install -y ca_root_nss

reboot

### Log back in and verify the version - you will need this for later
freebsd-version -u && freebsd-version -kr

## Now lets build the custom Kernel
### If not already done, we will update the CA Root Certs otherwise git fails.
pkg install -y ca_root_nss git
rm -rf /usr/src
git clone https://git.freebsd.org/src.git /usr/src
cd /usr/src

### VERY IMPORTANT - the version you get from git MUST match the version above
git checkout release/15.0
git pull

### Now lets apply the diff patch for MDIO
cd
fetch -o /root/D50128.diff 'https://reviews.freebsd.org/D50128?download=true&id=155233'
cd /usr/src
patch -p1 < /root/D50128.diff

### IMPORTANT: Fix any errors by hand!
### Compare /usr/src/sys/modules/ix/Makefile with /usr/src/sys/modules/ix/Makefile.rej
### Normally it is only one or two entries in sys/modules/ix/Makefile

### Fix the build bug - Remove 'fdt' dependency!  
edit /usr/src/sys/conf/files

CHANGE FROM:
dev/etherswitch/e6000sw/e6000sw.c optional e6000sw fdt

CHANGE TO:
'# Removed Flat Device Tree dependency for M270 Platform'
'# dev/etherswitch/e6000sw/e6000sw.c     optional e6000sw fdt'
'dev/etherswitch/e6000sw/e6000sw.c       optional e6000sw'

### Create the new Kernel
#### Here we create a "fake" kernel just to fix the build bug above
echo "include GENERIC" >> /usr/src/sys/amd64/conf/M270
echo "ident M270" >> /usr/src/sys/amd64/conf/M270

### And we can pre-compile the modules in the kernel vs loading them from loader.conf
echo "device etherswitch" >> /usr/src/sys/amd64/conf/M270
echo "device miiproxy" >> /usr/src/sys/amd64/conf/M270
echo "device e6000sw" >> /usr/src/sys/amd64/conf/M270

NOTE: The kernel already includes mdio, ix, miibus

OPTIONAL:  You can add any nodevice entries to supress devices in the GENERIC kernel such as nodevice speaker, etc.
There is a sample M270 kernel file in this repo.

### Create the hints file
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

### Create the support files for the new kernel
The support files are in the github directories by path

### Build and install the kernel
cd /usr/src
make -j$(sysctl -n hw.ncpu) buildkernel KERNCONF=M270
make installkernel KERNCONF=M270
reboot

## If you pre-copied all the support files, the front ports should come up with port 0 on DHCP!
