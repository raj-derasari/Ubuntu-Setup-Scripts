#!/bin/bash
grub_custom_file=/etc/grub.d/40_custom

if [[ -z $1 ]]; then
	echo "Usage: bash setup_clonezilla.sh [ install | uninstall ]
	install   | installs clonezilla to $grub_custom_file or \$grub_custom_file in script
	uninstall | removes clonezilla by setting the contents of \$grub_custom_file in script
-------------------------------------------------------------------------------------------------
	Note; When running update-grub, you will not see the clonezilla entry in console.
	But when you reboot the machine you will see the clonezilla entry in the GRUB menu.
-------------------------------------------------------------------------------------------------"
	exit 1
elif [ "$1" = "install" ]; then
	clonezilla_iso_file=`ls clonezilla-live*.iso`
	echo "Clonezilla ISO Found: " ${clonezilla_iso_file}

	## IMPORTANT: DO NOT ENTER A SLASH AFTER THE PATH
	clonezilla_iso_path=/home/clonezilla_iso
	sudo mkdir -p ${clonezilla_iso_path}

	## copy the file if newer, to new output
	echo "Copying Clonezilla ISO to: " ${clonezilla_iso_path}
	sudo cp --update ./${clonezilla_iso_file} ${clonezilla_iso_path}/${clonezilla_iso_file}

	echo "Adding custom grub entry to file: " ${grub_custom_file}
	# echo this thingy and output to etc/grub ... etc.
	echo "
	menuentry \"Clonezilla live (ISO)\" {
	set isofile=\"${clonezilla_iso_path}/${clonezilla_iso_file}\"
	loopback loop \$isofile
	linux (loop)/live/vmlinuz boot=live union=overlay username=user config components quiet noswap nolocales edd=on nomodeset ocs_live_run=\\\"ocs-live-general\\\" ocs_live_extra_param=\\\"\\\" keyboard-layouts= ocs_live_batch=\\\"no\\\" locales= vga=788 ip=frommedia nosplash toram=filesystem.squashfs findiso=\$isofile
	initrd (loop)/live/initrd.img
	}" | sudo tee -a ${grub_custom_file}

elif [ "$1" = "uninstall" ]; then
	echo "Removing clonezilla entries by resetting custom GRUB file: " ${grub_custom_file}
	echo "#!/bin/sh
exec tail -n +3 \$0
# This file provides an easy way to add custom menu entries.  Simply type the
# menu entries you want to add after this comment.  Be careful not to change
# the 'exec tail' line above.
" | sudo tee ${grub_custom_file}
fi

echo "Updating grub and executing grub-install /dev/sda"
sudo update-grub
sudo grub-install /dev/sda