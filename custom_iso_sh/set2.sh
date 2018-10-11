sudo apt-get update
sudo apt-get update
sudo apt-get install -y --install-recommends python-genshi python-colorama python-distlib python-pkg-resources python-tk
sudo apt-get install -y --install-recommends python3-pip
sudo -H python3 -m pip install --user --upgrade pip
sudo -H python3 -m pip install --user --upgrade Requests
sudo -H python3 -m pip install --user --upgrade scipy
sudo -H python3 -m pip install --user --upgrade sklearn
sudo -H python3 -m pip install --user --upgrade matplotlib
sudo -H python3 -m pip install --user --upgrade pandas
sudo -H python3 -m pip install --user --upgrade h5py
sudo -H python3 -m pip install --user --upgrade flask
sudo -H python3 -m pip install --user --upgrade Twisted
sudo -H python3 -m pip install --user --upgrade lxml
sudo -H python3 -m pip install --user --upgrade BeautifulSoup4
sudo -H python3 -m pip install --user --upgrade IPython
sudo -H python3 -m pip install --user --upgrade jupyter
sudo apt -y autoremove
sudo apt-get install -y -f
rm -rfd /etc/skel/.cache/pip
rm -rfd /home/thanos/.cache/pip
sudo rm -rfd /var/cache/oracle-jdk*-installer/jdk*.tar.gz
sudo rm -rfd /var/lib/apt/lists/
sudo apt clean
read -p Press Enter, or y/Y to restart right now, or anything else to exit. -  shut
sudo reboot
