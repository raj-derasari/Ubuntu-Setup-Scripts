# safe to purge
sudo apt-get purge  --auto-remove adwaita-icon-theme
sudo apt-get purge  --auto-remove dmz-cursor-theme
sudo apt-get purge  --auto-remove gnome-icon-theme gtk-update-icon-cache
sudo apt-get purge  --auto-remove humanity-icon-theme
# uninstalls gnome-disk-utility but just replace it w gparted lol
#sudo apt-get purge  --auto-remove sound-theme-freedesktop
sudo apt-get purge  --auto-remove  plymouth-theme-lubuntu-logo plymouth-theme-lubuntu-text plymouth-label


## risky
sudo apt-get purge hicolor-icon-theme



sudo apt-get purge adwaita-icon-theme dmz-cursor-theme gnome-icon-theme hicolor-icon-theme humanity-icon-theme plymouth-theme-lubuntu-logo plymouth-theme-lubuntu-text sound-theme-freedesktop

# in case you lose the icons of sometihing
sai lubuntu-artwork