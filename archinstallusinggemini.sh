#!/bin/bash

# Install the base system!
timedatectl

# Automate fdisk tasks with GPT partitioning
fdisk /dev/sda << EOF
g  # Create GPT table
n   # New partition
p   # Primary partition
1   # Partition number 1
    # Default - start at beginning of disk
+2048M  # Size: 2048 Megabytes (EFI System)
t   # Change partition type
1   # Set type to EFI System (1)
n   # New partition
p   # Primary partition
2   # Partition number 2
    # Default - start immediately after preceding partition
+6144M  # Size: 6144 Megabytes (Linux swap)
t   # Change partition type
19  # Set type to Linux swap (19)
n   # New partition
p   # Primary partition
3   # Partition number 3
    # Default - start immediately after preceding partition
    # Default - extend partition to end of disk (Linux root)
w   # Save changes
q   # Quit
EOF

# Format the partitions
mkfs.fat -F 32 /dev/sda1
mkswap /dev/sda2
mkfs.ext4 /dev/sda3

# Mount the disks
mount --mkdir /dev/sda1 /mnt/boot
swapon /dev/sda2
mount /dev/sda3 /mnt

#Install Essential Packages (base system, including kernel and cpu microcode)
pacstrap -K /mnt base linux-lts linux-firmware intel-ucode
#Generate an fstab file (Used for Filesystem Table mount/unmount and etc.)
genfstab -U /mnt >> /mnt/etc/fstab
#Chroot (basically enter system without reboot to do stuff)
arch-chroot /mnt
#set timezone
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
#Install nano to do certain editing stuff. You can also install vim since it's preferred to edit sudoers file which will take place later on to create new user.
pacman -S nano
#Localization
locale-gen
nano /etc/locale.gen
uncomment en_US.UTF-8 UTF-8 
nano /etc/locale.conf
LANG=en_US.UTF-8
nano /etc/hostname
Arch_Linux
#Create a Strong Password for root user
passwd
PASSWORD
PASSWORD
#Enable Networking (Works for Ethernet, for any other please refer to: https://wiki.archlinux.org/title/Network_configuration)
pacman -S dhcpcd
systemctl enable dhcpcd

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

bootctl update
