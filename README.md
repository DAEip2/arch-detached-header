# arch-detached-header
This script installs an encrypted Arch Linux system with a detached header. Before running it, ensure you have a completely blank main disk and boot partition.  
The path to the main disk is 'MAIN_PART' in the code (e.g., '/dev/sda') with no existing partitions.  
The path to the boot partition is 'BOOT_PART' in the code (e.g., '/dev/sdb1').  
The 'OFFSET' variable defines the sector number where your encrypted system will begin ('0' by default).  
The 'ZONE' variable sets your timezone ('/Etc/UTC' by default).  
The 'LUKS_NAME' is the name for the mapped LUKS device ('SYSTEM' by default).  
The 'HOSTNAME' defines your system's host name ('HOST' by default).  
WARNING: All data on the boot partition, as well as any data on the main disk located after the OFFSET sector, will be permanently destroyed.  
The installation step by step:
1. Boot the Installer: Boot into the official Arch Linux ISO (available at archlinux.org/download) using a flashing tool on a USB drive. Ensure your live system can access both the main disk and the boot partition. Ensure your live environment has an active internet connection (via Ethernet or Wi-Fi).
2. Copy the 'main.sh' file from this repository into your live environment ('curl -O https://raw.githubusercontent.com/DAEip2/arch-detached-header/main/main.sh').
3. Use the lsblk utility to find your drive paths, then update the 'MAIN_PART' and 'BOOT_PART' variables inside main.sh to match your actual system paths. If you want a system that can't be detected, you have to write 'dd if=/dev/urandom of=<PATH TO THE MAIN DISK (MAIN_DISK in code)> bs=100M status=progress'. This process can take a lot of time.
4. Enter 'chmod +x ./main.sh'.
5. Run the 'main.sh'.
6. Enter 'YES' when prompted.
7. Enter your encryption password three times when prompted.
8. Enter 'y' when prompted (this step is sometimes skipped).

Once 'main.sh' finishes successfully, your new system will include:  
A base Arch Linux installation.  
Standart linux kernel.  
US locale and keymap configuration.  
GRUB bootloader.
The header of the disk will be in the root of the boot partition as 'header.img'.  
