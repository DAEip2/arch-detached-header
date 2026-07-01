#!/bin/bash

MAIN_PART=""
BOOT_PART=""
LUKS_NAME="SYSTEM"
ZONE="Etc/UTC"
HOSTNAME="HOST"
OFFSET="0"


MAIN_DISK_ID=$(find -L /dev/disk/by-id/ -samefile "${MAIN_PART}" 2>/dev/null | head -n1)
BOOT_UUID=$(blkid -s UUID -o value "${BOOT_PART}")

dd if=/dev/zero of=/tmp/header.img bs=16M count=1 > /dev/null 2>&1
cryptsetup luksFormat --offset "${OFFSET}" --header /tmp/header.img "${MAIN_PART}"
cryptsetup open --header /tmp/header.img "${MAIN_PART}" "${LUKS_NAME}"

mkfs.ext4 "/dev/mapper/${LUKS_NAME}"
mkfs.fat -F32 "${BOOT_PART}"

mkdir -p /mnt/sysimage
mount "/dev/mapper/${LUKS_NAME}" /mnt/sysimage
mkdir -p /mnt/sysimage/boot
mount "${BOOT_PART}" /mnt/sysimage/boot

mv /tmp/header.img /mnt/sysimage/boot/

pacstrap /mnt/sysimage base nano vim cryptsetup grub efibootmgr linux linux-firmware lvm2

genfstab -U /mnt/sysimage >> /mnt/sysimage/etc/fstab

ROOT_UUID=$(blkid -s UUID -o value "/dev/mapper/${LUKS_NAME}")
LUKS_UUID=$(cryptsetup luksDump /mnt/sysimage/boot/header.img | grep "UUID" | awk '{print $2}')

arch-chroot /mnt/sysimage/ /bin/bash <<EOF
ln -sf /usr/share/zoneinfo/${ZONE} /etc/localtime
hwclock --systohc

sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "${HOSTNAME}" > /etc/hostname

echo "KEYMAP=us" > /etc/vconsole.conf
sed -i 's/^MODULES=.*/MODULES=(vfat)/' /etc/mkinitcpio.conf
sed -i 's/^HOOKS=.*/HOOKS=(base systemd autodetect microcode modconf kms keyboard block sd-vconsole sd-encrypt lvm2 filesystems fsck)/' /etc/mkinitcpio.conf

echo "${LUKS_NAME} ${MAIN_DISK_ID} none header=/header.img:UUID=${BOOT_UUID}" > /etc/crypttab.initramfs

mkinitcpio -P

grub-install --target=x86_64-efi --efi-directory=/boot --removable --recheck

echo "GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR='Arch'
GRUB_CMDLINE_LINUX_DEFAULT='loglevel=3 root=UUID="${ROOT_UUID}" rd.luks.uuid="${LUKS_UUID}" rd.luks.name="${LUKS_UUID}"=ROOT0 rd.luks.data="${LUKS_UUID}"="${MAIN_DISK_ID}" rd.luks.options="${LUKS_UUID}"=header=/header.img:UUID="${BOOT_UUID}"'
GRUB_CMDLINE_LINUX=''" > /etc/default/grub

grub-mkconfig -o /boot/grub/grub.cfg

EOF
