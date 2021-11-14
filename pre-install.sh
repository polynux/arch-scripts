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
echo "Would you want to use existing home partition ? (Y/N)"
read homepart
case $homepart in
n|N|No|NO|no)

echo "-------------------------------------------------"
echo "----------Select your disk to format-------------"
echo "-------------------------------------------------"
lsblk
echo "Please enter disk to work on: (example /dev/sda)"
read DISK
echo "THIS WILL FORMAT AND DELETE ALL DATA ON SELECTED DISK"
read -p "Are you sure you want to continue (Y/N):" formatdisk
case $formatdisk in
y|yes|YES|Yes|Y)

echo "What size of your root partition do you want? (ex: 10G)"
read SIZE

echo "--------------------------------------"
echo -e "       Formatting disk..."
echo "--------------------------------------"

# prep disk
sgdisk -Z $DISK # erase partition table
sgdisk -a 2048 -o ${DISK} # new gpt disk 2048 alignment

#create partitions
sgdisk -n 1::100M --typecode=1:ef00 --change-name=1:"EFI" $DISK # EFI partition
sgdisk -n 2::$SIZE --typecode=2:8304 --change-name=2:"root" $DISK # root partition
sgdisk -n 3::-0 --typecode=3:8302 --change-name=3:"home" $DISK # home partition


esac
esac
