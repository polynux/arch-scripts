#!/usr/bin/env bash
#-----------------------------------------------------------------
#  ██▓███   ▒█████   ██▓   ▓██   ██▓ ███▄    █  █    ██ ▒██   ██▒
# ▓██░  ██▒▒██▒  ██▒▓██▒    ▒██  ██▒ ██ ▀█   █  ██  ▓██▒▒▒ █ █ ▒░
# ▓██░ ██▓▒▒██░  ██▒▒██░     ▒██ ██░▓██  ▀█ ██▒▓██  ▒██░░░  █   ░
# ▒██▄█▓▒ ▒▒██   ██░▒██░     ░ ▐██▓░▓██▒  ▐▌██▒▓▓█  ░██░ ░ █ █ ▒ 
# ▒██▒ ░  ░░ ████▓▒░░██████▒ ░ ██▒▓░▒██░   ▓██░▒▒█████▓ ▒██▒ ▒██▒
# ▒▓▒░ ░  ░░ ▒░▒░▒░ ░ ▒░▓  ░  ██▒▒▒ ░ ▒░   ▒ ▒ ░▒▓▒ ▒ ▒ ▒▒ ░ ░▓ ░
# ░▒ ░       ░ ▒ ▒░ ░ ░ ▒  ░▓██ ░▒░ ░ ░░   ░ ▒░░░▒░ ░ ░ ░░   ░▒ ░
# ░░       ░ ░ ░ ▒    ░ ░   ▒ ▒ ░░     ░   ░ ░  ░░░ ░ ░  ░    ░  
#              ░ ░      ░  ░░ ░              ░    ░      ░    ░  
#                           ░ ░                                  
#-----------------------------------------------------------------
# Color code
purple="\e[35m";
reset="\e[0m";

echo -e "$purple"
echo "-----------------------------------------------------------------"
echo "  ██▓███   ▒█████   ██▓   ▓██   ██▓ ███▄    █  █    ██ ▒██   ██▒"
echo " ▓██░  ██▒▒██▒  ██▒▓██▒    ▒██  ██▒ ██ ▀█   █  ██  ▓██▒▒▒ █ █ ▒░"
echo " ▓██░ ██▓▒▒██░  ██▒▒██░     ▒██ ██░▓██  ▀█ ██▒▓██  ▒██░░░  █   ░"
echo " ▒██▄█▓▒ ▒▒██   ██░▒██░     ░ ▐██▓░▓██▒  ▐▌██▒▓▓█  ░██░ ░ █ █ ▒ "
echo " ▒██▒ ░  ░░ ████▓▒░░██████▒ ░ ██▒▓░▒██░   ▓██░▒▒█████▓ ▒██▒ ▒██▒"
echo " ▒▓▒░ ░  ░░ ▒░▒░▒░ ░ ▒░▓  ░  ██▒▒▒ ░ ▒░   ▒ ▒ ░▒▓▒ ▒ ▒ ▒▒ ░ ░▓ ░"
echo " ░▒ ░       ░ ▒ ▒░ ░ ░ ▒  ░▓██ ░▒░ ░ ░░   ░ ▒░░░▒░ ░ ░ ░░   ░▒ ░"
echo " ░░       ░ ░ ░ ▒    ░ ░   ▒ ▒ ░░     ░   ░ ░  ░░░ ░ ░  ░    ░  "
echo "              ░ ░      ░  ░░ ░              ░    ░      ░    ░  "
echo "                           ░ ░                                  "
echo "-----------------------------------------------------------------"
echo -e "$reset"
echo "-------Welcome to my arch install scripts--------"


echo "-------------------------------------------------"
echo "----------Select your disk to format-------------"
echo "-------------------------------------------------"
lsblk
echo "Please enter disk to work on: (example /dev/sda)"
read DISK
echo "THIS WILL FORMAT AND DELETE ALL DATA ON SELECTED DISK"
read -p "Are you sure you want to continue (Y/N):" formatdisk
case $formatdisk in
n|N|No|NO|no)

reboot now
;;

y|yes|YES|Yes|Y)

if [[ ${DISK} =~ "nvme" ]]; then
DISK="${DISK}p"
fi

echo "--------------------------------------"
echo -e "       Formatting disk..."
echo "--------------------------------------"

echo "Would you want to use existing home partition ? (Y/N)"
read homepart
case $homepart in
n|N|No|NO|no)

echo "What size of your root partition do you want? (ex: 10G)"
read SIZE

# prep disk
sgdisk -Z $DISK # erase partition table
sgdisk -a 2048 -o ${DISK} # new gpt disk 2048 alignment

#create partitions
sgdisk -n 1::100M --typecode=1:ef00 --change-name=1:"EFI" $DISK # EFI partition
sgdisk -n 2::$SIZE --typecode=2:8304 --change-name=2:"root" $DISK # root partition
sgdisk -n 3::-0 --typecode=3:8302 --change-name=3:"home" $DISK # home partition

# Format home partition
mkfs.ext4 -L "home" "${DISK}3"
;;

y|yes|YES|Yes|Y)

echo "Keeping you ${DISK}3 home partition"
;;
esac

# Format EFI and root partition
mkfs.fat -F32 -n "EFI" "${DISK}1"
mkfs.btrfs -L "root" "${DISK}2" -f

# Create subvolume for root partition
mount -t btrfs "${DISK}2" /mnt
btrfs subvolume create /mnt/@
umount /mnt

# Mount partition
mount -t btrfs -o subvol=@ -L root /mnt
mkdir /mnt/home
mkdir -p /mnt/boot/EFI
mount -L EFI /mnt/boot/EFI
mount -L home /mnt/home

if ! grep -qs '/mnt' /proc/mounts; then
    echo "Drive is not mounted can not continue"
    echo "Rebooting in 3 Seconds ..." && sleep 1
    echo "Rebooting in 2 Seconds ..." && sleep 1
    echo "Rebooting in 1 Second ..." && sleep 1
    reboot now
fi

echo "--------------------------------------"
echo "--   Arch Install on Main Drive     --"
echo "--------------------------------------"

timedatectl set-ntp true
sed -i 's/^#Para/Para/' /etc/pacman.conf # enable parallels download
sed -i 's/^#Color/Color/' /etc/pacman.conf # enable colors

# Install base
pacstrap /mnt base base-devel linux linux-firmware nano sudo \
    archlinux-keyring wget btrfs-progs e2fsprogs dosfstools --noconfirm --needed
genfstab -U /mnt >> /mnt/etc/fstab

cp -R $(pwd) /mnt/root/

;;
esac
