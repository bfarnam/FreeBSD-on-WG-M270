# If you have more than one M270, you can copy your kernel to other M270's:

# On your build machine:
cd
tar -cvzf kernel-my-version-M270.tar.gz /boot/kernel /boot/kernel.old

# On your target machine:
cd
scp root@target_machine_ip:kernel-my-version-M270.tar.gz kernel-my-version-M270.tar.gz
tar -xvzf kernel-my-version-M270.tar.gz
