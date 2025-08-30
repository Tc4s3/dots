#!/usr/bin/env bash

echo "This will get syncterm, build it, and install it for you!"

# Determine if debian or not
checkOS=$(grep -iE "^id|id_like|REDHAT_BUGZILLA_PRODUCT" /etc/os-release|awk -F\= '{print $2}'|sed 's/"//g')

if [[ "$checkOS" == *"debian"* ]]; then
  # Debian/Ubuntu: To Install apps/libraries used to compile
  echo "Debian/Ubuntu found: Preparing to install relevant libraries..."
  sudo apt-get install -y wget libncurses-dev libncursesw6 gcc libsdl1.2-dev build-essential
fi

if [[ "$checkOS" == *"fedora"* ]]; then
  # Redhat/Fedora: To Install apps/libraries used to compile
  echo "Redhat/Fedora found: Preparing to install relevant libraries..."
  sudo yum -y install wget ncurses-devel gcc sdl12-compat SDL2
  sudo yum -y groupinstall 'Development Tools'
fi

if [[ "$checkOS" == "arch" ]]; then
  # Arch Linux: To Install apps/libraries used to compile
  echo "Arch Linux found: Preparing to install relevant libraries..."
  sudo pacman -S --needed --noconfirm wget sdl12-compat sdl2 gcc ncurses base-devel
fi

# Make a temporary build directory
CDIR=$(pwd)
WDIR=/tmp/get-syncterm
[[ -d $WDIR ]] && rm -rf $WDIR
mkdir $WDIR && cd $WDIR

# To Pull source
echo "About to download the syncterm application source..."
wget https://gitlab.synchro.net/main/sbbs/-/archive/master/sbbs-master.zip?path=3rdp -O 3rdp.zip
wget https://gitlab.synchro.net/main/sbbs/-/archive/master/sbbs-master.zip?path=src -O src.zip

# To extract zip files
echo "Extracting the source now..."
for F in *.zip; do unzip -a ${F}; done

# Sort directory structure
echo "Sorting directory structure..."
for D in `ls -1d sbbs*`; do cp -rv ${D}/* .; done
rm -rf sbbs-master-*

# Change directory to
echo "Change into the 'make' folder"
cd src/syncterm

# To get full path src
echo "Set st_path variable for the SRC_ROOT path..."
st_path=$(pwd | sed 's/\/syncterm$//g')

# Time to compile!
echo "Make SRC_ROOT with path: $st_path"
make SRC_ROOT=$st_path

# Install SyncTerm
echo "Install SyncTERM..."
sudo make install

# Find out where Syncterm was installed
echo "Find out where SyncTERM installed"
which syncterm

# Get back to the original directory
cd $CDIR

