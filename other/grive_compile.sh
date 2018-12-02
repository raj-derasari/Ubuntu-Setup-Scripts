mkdir ~/SetupScript/GRIVE
cd ~/SetupScript/GRIVE
sudo apt-get install git cmake build-essential libgcrypt11-dev libyajl-dev libboost-all-dev libcurl4-openssl-dev libexpat1-dev libcppunit-dev binutils-dev debhelper zlib1g-dev dpkg-dev pkg-config
git clone https://github.com/vitalif/grive2.git
cd grive2
dpkg-buildpackage -j4
cd ..
sudo dpkg -i grive-0*.deb
[ $? -eq 0 ] && echo "Grive installed successfully!" || echo "Grive did not install successfully"