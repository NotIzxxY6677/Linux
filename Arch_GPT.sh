#!/bin/bash

# Synchronize time
timedatectl set-ntp true

# Partitioning
fdisk /dev/sda <<EOF
g       # Create GPT partition table
n       # Create EFI system partition
1       # Partition number 1
         # Default start sector
+2048M  # Size
t       # Change partition type
1       # EFI System (type 1)

n       # Create swap partition
2       # Partition number 2
         # Default start sector
+6144M  # Size
t       # Change partition type
2       # Select partition 2
19      # Linux swap (type 19)

n       # Create root partition
3       # Partition number 3
         # Default start sector
         # Use remaining space
t       # Change partition type
3       # Select partition 3
23      # Linux root (type 23)

w       # Write changes and exit
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

# End of chroot commands
EOF

# Exit chroot
echo "Exiting chroot environment."

# Unmount and reboot
umount -R /mnt
swapoff -a
echo "Installation complete! Rebooting..."
reboot
