#!/usr/bin/env bash

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

echo format

esac
esac
