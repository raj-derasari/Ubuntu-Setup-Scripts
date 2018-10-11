python3 -m pip install --user --upgrade pip
python3 -m pip install --user --upgrade Requests
python3 -m pip install --user --upgrade scipy
python3 -m pip install --user --upgrade sklearn
python3 -m pip install --user --upgrade matplotlib
python3 -m pip install --user --upgrade pandas
python3 -m pip install --user --upgrade BeautifulSoup4
cp /root/.gitconfig /etc/skel/.gitconfig
rm -rfd /etc/skel/.cache/pip
rm -rfd /root/.cache/pip
rm -rfd /tmp
sudo rm -rfd /var/cache/oracle-jdk*-installer/jdk*.tar.gz
sudo rm -rfd /var/lib/apt/lists/
sudo apt clean
