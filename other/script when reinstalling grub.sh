# to get disk data 
sudo fdisk -l ## here note down the ubuntu partition

# mount partitions
sudo mount /dev/sda5 /mnt
sudo mount /dev/sda2 /mnt/boot/efi
for i in /dev /dev/pts /proc /sys; do sudo mount -B $i /mnt$i; done

# to make sure that your internet connection stays alive. Copy and paste this command line into the terminal:
sudo cp /etc/resolv.conf /mnt/etc/

# to get some efi vars
modprobe efivars

# enter chroot
sudo chroot /mnt

# install grub
apt-get install --reinstall grub-efi-amd64

# exit chroot
exit

# unmount all things
for i in /sys /proc /dev/pts /dev; do sudo umount /mnt$i; done
sudo umount /mnt/boot/efi
sudo umount /mnt

# reboot
sudo reboot