#!/bin/bash
bash pre-install.sh
arch-chroot /mnt /root/arch-scripts/install.sh
source /mnt/root/arch-scripts/install.conf
arch-chroot /mnt /usr/bin/runuser -u $username -- /home/$username/arch-scripts/user.sh
arch-chroot /mnt /root/arch-scripts/3-post-setup.sh