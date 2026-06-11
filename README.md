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
- 8x 1000Base-T ports which connect to an on board Marvell 88E6190 / 88E6190X Switch.  **None of the external ethernet ports connect directly to the CPU.**

### Marvell LinkStreet 88E6190/88E6190x Technical Information
- 11-Port Ethernet Switch
- 8 integrated Gigabit Ethernet Transcievers (External Ports)
- 2 SerDes Interfaces (Connected to CPU X553 Port 0 and Port 1)
- 1 Digitial Interface (Used for MII)

Step by step on how to configure FreeBSD on the WG M270 Platform

## Prerequisites:
Please read the prerequisites.md file.

## Hardware Preperation
Please read the hardware-prep.md file.

## FreeBSD Install
**IMPORTANT:** Please read the FreeBSD-Install.md file for the specific method of installing FreeBSD on the internal mSATA Drive.

## Kernel Configuration
If you have version 16 then you do not need to compile the kernel.  There is however a bug in the driver which prohibits you from loading it up at boot.  You must instead use a kld_list command in rc.conf.  Please see both my /etc/rc.conf and FreeBSD-Make-Kernel.md files for more info.

**IMPORTANT:** Please read the FreeBSD-Make-Kernel.md file for the specific steps required to re-compile the FreeBSD Kernel to utilize the onboard ethernet switch.



