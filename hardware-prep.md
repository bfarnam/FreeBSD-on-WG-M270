# Hardware Preperation

Before you can install FreeBSD or any other software such as OPNsense, PFsense, etc, you must prepare the hardware to boot off of USB.

1. Ensure that the M270 is powered off and unplugged from the mains.
2. Connect the Serial Console Cable between the M270 and your PC.
You should set your terminal to 115200,N,8,1.
3. Powerup the M270 and press <DELETE> or <TAB> when prompted to enter the BIOS.
4. Enter the BIOS password (WatchGaurd!).
5. Navigate to Security and Select the Administrator Password and change the password.  When prompted for the new password, just hit enter and confirm to remove the Administrator Password.  Repeat this for the User Password.  The User Password is the same as the Administrator Password.
6. Navigate to Boot and change ensure that the USB Device is the first boot device.

## Optional
I changed from LEGACY to UEFI for FreeBSD.  If you change to UEFI please note that UEFI and Legacy each have thier own boot orders.  I also ensured that Serial Port Rediection (Found under Advanced) was enabled for vt100.  You can make any other changes that you wish for your specific application.

**When done chose Save & Exit and Save Changes and Reset.**
