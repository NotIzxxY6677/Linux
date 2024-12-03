#Install the base system!
timedatectl
fdisk /dev/sda
#Create GPT Table
g
#EFI System /dev/sda1 - 1
n
1
default
+2048M
t
1
#Linux swap /dev/sda2 - 19
n
2
default
+6144M
t
19
#Linux root (x86_64) /dev/sda3 - 23 
n
3
default
default
n
23
#Save the changes
w
#Format the Paritions Respectively to their Filesystem Type
mkfs.fat -F 32 /dev/sda1
mkswap /dev/sda2
mkfs.ext4 /dev/sda3
#Mount the disks
mount --mkdir /dev/sda1 /mnt/boot
swapon /dev/sda2
mount /dev/sda3 /mnt
#Install Essential Packages
pacstrap -K /mnt base linux-lts linux-firmware intel-ucode

#systemd-bootloader setup, inside arch-chroot after done setting up normal user account for sudo.

bootctl install

nano /boot/loader/loader.conf

default arch
timeout 5
console-mode max
editor no

nano /boot/loader/entries/arch.conf

title Arch_Linux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
options root=/dev/sda3 rw
