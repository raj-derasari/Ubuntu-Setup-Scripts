#!/bin/bash
sed -i 's/amixer -q sset Master toggle/amixer -D pulse set Master toggle/g' ~/openbox/lubuntu-rc.xml
echo PATH="\$PATH:~/.local/bin" >> ${BF}
sudo dpkg -i grive*.deb