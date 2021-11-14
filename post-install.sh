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
echo -e "\nFINAL SETUP AND CONFIGURATION"
echo "--------------------------------------"
echo "-- GRUB EFI Bootloader Install&Check--"
echo "--------------------------------------"
grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=GRUB ${DISK}
grub-mkconfig -o /boot/grub/grub.cfg

echo -e "\nEnabling Login Display Manager"
systemctl enable sddm.service
echo -e "\nSetup SDDM Theme"
cat <<EOF > /etc/sddm.conf
[Theme]
Current=Nordic
EOF

echo -e "\nEnabling essential services"
systemctl enable NetworkManager.service

echo "
###############################################################################
# Cleaning
###############################################################################
"
# Remove no password sudo rights
sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
# Add sudo rights
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# Replace in the same state
cd $pwd
echo "
###############################################################################
# Done - Please Eject Install Media and Reboot
###############################################################################
"
