# to get disk data 
sudo fdisk -l ## here note down the ubuntu partition

# mount partitions
# this may work - BUT - what if there are many linux distros? what if the text is NOT Linux ?
Z=`sudo fdisk -l | grep Linux | cut -d ' '  -f 1`
sudo mount ${Z} /mnt
#sudo mount /dev/sda5 /mnt

sudo mount /dev/sda2 /mnt/boot/efi

## to get some efi vars
# modprobe efivars
## if working in efi this is needed
# apt-get install --reinstall grub-efi-amd64

## is an alternative to the commented-below part
sudo grub-install --root-directory=/mnt /dev/sda

## to make sure that your internet connection stays alive. Copy and paste this command line into the terminal:
#sudo cp /etc/resolv.conf /mnt/etc/

## mount necessary
# for i in /dev /dev/pts /proc /sys; do sudo mount -B $i /mnt$i; done
## enter chroot
# sudo chroot /mnt
# install grub-efi-loader
# exit chroot

# # unmount all things
#for i in /sys /proc /dev/pts /dev; do sudo umount /mnt$i; done

# reboot
sudo reboot