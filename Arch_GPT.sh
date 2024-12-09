#!/bin/bash

# Synchronize time
timedatectl set-ntp true

# Partitioning
fdisk /dev/sda <<EOF
g
n
1

+2048M
t
1
n
2

+6144M
t
2
19
n
3


w
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

# Root password
echo "root:password" | chpasswd

# Install networking tools
pacman -S --noconfirm dhcpcd
systemctl enable dhcpcd

# Install bootloader
bootctl install
echo "default arch" > /boot/loader/loader.conf
echo "timeout 5" >> /boot/loader/loader.conf
echo "console-mode max" >> /boot/loader/loader.conf
echo "editor no" >> /boot/loader/loader.conf

cat <<BOOT > /boot/loader/entries/arch.conf
title Arch_Linux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
options root=/dev/sda3 rw
BOOT

bootctl update
EOF

# Unmount and reboot
umount -R /mnt
swapoff -a
echo "Installation complete! Rebooting..."
reboot
