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
echo "--------------------------------------"
echo "--          Network Setup           --"
echo "--------------------------------------"
pacman -S networkmanager dhclient --noconfirm --needed
systemctl enable --now NetworkManager
echo "-------------------------------------------------"
echo "Setting up mirrors for optimal download          "
echo "-------------------------------------------------"
pacman -S --noconfirm pacman-contrib curl
pacman -S --noconfirm reflector rsync
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

nc=$(grep -c ^processor /proc/cpuinfo)
echo "You have " $nc" cores."
echo "-------------------------------------------------"
echo "Changing the makeflags for "$nc" cores."

sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$nc\"/g" /etc/makepkg.conf
echo "Changing the compression settings for "$nc" cores."
sed -i "s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $nc -z -)/g" /etc/makepkg.conf

echo "-------------------------------------------------"
echo "       Setup Language to FR and set locale       "
echo "-------------------------------------------------"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/^#fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
timedatectl --no-ask-password set-timezone Europe/Paris
timedatectl --no-ask-password set-ntp 1
localectl --no-ask-password set-locale LANG="fr_FR.UTF-8" LC_TIME="fr_FR.UTF-8"

# Set keymaps
localectl --no-ask-password set-keymap fr

# Add sudo no password rights
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

#Add parallel downloading
sed -i 's/^#Para/Para/' /etc/pacman.conf

#Enable colors
sed -i 's/^#Color/Color/' /etc/pacman.conf

#Enable multilib
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Sy --noconfirm

echo -e "\nInstalling Base System\n"

PKGS=(
"xorg"
"efibootmgr"
"network-manager-applet"
"wireless_tools"
"wpa_supplicant"
"dialog"
"os-prober"
"mtools"
"linux-headers"
"lightdm"
"lightdm-webkit2-greeter"
"lightdm-webkit-theme-litarvan"
"qtile"
"dmenu"
"rofi"
"nitrogen"
"firefox"
"ntfs-3g"
"zsh"
"xterm"
"terminator"
"pcmanfm"
"grub"
"htop"
"neofetch"
"openssh"
"pulseaudio"
"ufw"
"unrar"
"unzip"
"git"
"gvim"
"xdg-users-dirs"
"arandr"
"bat"
"lsd"
"kvantum-qt5"
"lxappearance"
"numlockx"
"reflector"
"ttf-roboto"
)

for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    sudo pacman -S "$PKG" --noconfirm --needed
done

# determine processor type and install microcode
proc_type=$(lscpu | awk '/Vendor ID:/ {print $3}')
case "$proc_type" in
	GenuineIntel)
		print "Installing Intel microcode"
		pacman -S --noconfirm intel-ucode
		proc_ucode=intel-ucode.img
		;;
	AuthenticAMD)
		print "Installing AMD microcode"
		pacman -S --noconfirm amd-ucode
		proc_ucode=amd-ucode.img
		;;
esac	

# Graphics Drivers find and install
if lspci | grep -E "NVIDIA|GeForce"; then
    pacman -S nvidia --noconfirm --needed
	nvidia-xconfig
elif lspci | grep -E "Radeon"; then
    pacman -S xf86-video-amdgpu --noconfirm --needed
elif lspci | grep -E "Integrated Graphics Controller"; then
    pacman -S libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils --needed --noconfirm
fi

# detect virtualbox
pacman -S dmidecode --noconfirm
VM=$(dmidecode -t system | grep 'Product Name')
if [[ $VM =~ "VirtualBox" ]]; then
	pacman -S virtualbox-guest-utils --noconfirm
fi

echo -e "\nDone!\n"

echo "Enter root password:"
passwd

read -p "Please enter username:" username
echo "username=$username" >> ${HOME}/arch-scripts/install.conf
if [ $(whoami) = "root" ];then
    useradd -m -G wheel -s /bin/bash $username 
    echo "Enter ${username} password:"
	passwd $username
	cp -R /root/arch-scripts /home/$username/
    chown -R $username /home/$username/arch-scripts
	read -p "Please name your machine name:" nameofmachine
	echo $nameofmachine > /etc/hostname
else
	echo "You are already a user proceed with aur installs"
fi