#!/bin/bash

# Synchronize time
timedatectl set-ntp true

# Partitioning
parted /dev/sda <<EOF
mklabel gpt
mkpart primary fat32 1MiB 1024MiB
mkpart primary linux-swap 1025MiB 6144MiB
mkpart primary ext4 6145MiB 100%
set 1 boot on
print
quit
EOF

# Formatting partitions
mkfs.fat -F32 /dev/sda1
mkswap /dev/sda2
mkfs.ext4 /dev/sda3

# Mounting partitions
mount /dev/sda3 /mnt
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot
swapon /dev/sda2

# Installing base system
pacstrap /mnt base linux-lts linux-firmware intel-ucode

# Generating fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into new system
arch-chroot /mnt /bin/bash <<EOF

# Set timezone
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc

# Localization
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Hostname
echo "Arch_Linux" > /etc/hostname

# Root password (NOTE: PLEASE CHANGE YOUR PASSWORD TO A STRONG ONE OR DISABLE ROOT LATER AND USE A NORMAL USER WITH SUDO PERMISSIONS)
echo "root:password" | chpasswd

# Install networking tools (ETHERNET)
pacman -S dhcpcd
systemctl enable dhcpcd

# Install bootloader
bootctl install
echo "default arch" > /boot/loader/loader.conf
echo "timeout 5" >> /boot/loader/loader.conf
echo "console-mode max" >> /boot/loader/loader.conf
echo "editor no" >> /boot/loader/loader.conf

cat <<BOOT > /boot/loader/entries/arch.conf
title Arch_Linux
linux /vmlinuz-linux-lts
initrd /intel-ucode.img
initrd /initramfs-linux-lts.img
options root=/dev/sda3 rw
BOOT

bootctl update

# End of chroot commands
EOF

# Exit chroot
echo "Exiting chroot environment."

# Unmount and reboot
umount -R /mnt
swapoff -a
echo "Installation complete! Please Reboot"
