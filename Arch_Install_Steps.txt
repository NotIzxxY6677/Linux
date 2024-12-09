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
