#!/usr/bin/env bash

##################################################
# Vagrant Ubuntu 12.04 Provisioning Script 
# 	
# Description:
# 	Provisions Ubuntu 12.04 VM with deps for
# 	FiE on Firmware reproduction
# 	Assumes /vagrant as mountpoint
##################################################

# CWD=$(realpath .)

APT_INSTALL_PACKAGES=(
	coreutils
	wget
	build-essential
	g++
	bison
	flex
	libc6-dev-i386 # see https://github.com/klee/klee/issues/83
)

# use sources.list for old-releases
sudo cp "/etc/apt/sources.list" "/etc/apt/sources.list.bak"
sudo cp "/vagrant/etc/sources.list" "/etc/apt/sources.list"

# update list of available packages
echo "updating apt-get..."
sudo apt-get update -y

# upgrade installed packages
echo "upgrading installed packages..."
sudo apt-get upgrade -y

# install new packages
echo "installing packages: ${APT_INSTALL_PACKAGES[@]}"
sudo apt-get install --force-yes -y "${APT_INSTALL_PACKAGES[@]}"
echo "finished installing apt packages!"

# install clang 2.9 binaries
CLANG_NAME="clang+llvm-2.9"
echo "installing clang+llvm-2.9 binaries"
cd /vagrant/etc
if [ ! -d "/vagrant/etc/$CLANG_NAME" ] ; then
	if wget -O "$CLANG_NAME.tar.bz2" "https://releases.llvm.org/2.9/clang+llvm-2.9-x86_64-linux.tar.bz2" &&
		tar -jxvf "$CLANG_NAME.tar.bz2" && rm "$CLANG_NAME.tar.bz2" &&
		mv "clang+llvm-2.9-x86_64-linux.tar" "$CLANG_NAME" ; then
			echo -e "\n\nexport PATH=\$PATH:/vagrant/etc/$CLANG_NAME/bin\n" >> /home/vagrant/.bashrc
			echo -e "clang+llvm-2.9 downloaded and extracted successfully!"
	else
		echo -e "\n\n!!! error: failed to install $CLANG_NAME !!!\n\n" 1>&2
	fi
fi
cd -

# download and extract fie
echo "downloading fie..."
cd /vagrant
if [ ! -f "/vagrant/fie.tgz" ] ; then
	if wget "http://pages.cs.wisc.edu/~davidson/fie/fie.tgz" &&
		tar -zxvf "fie.tgz" && rm "fie.tgz" ; then
			echo "successfully downloaded and extracted fie!"
	else
		echo -e "\n\n!!! error: failed to download and extract fie !!!\n\n" 1>&2
	fi
fi
cd -

# login to /vagrant folder on ssh
if ! grep -q "cd /vagrant" ~/.bashrc ; then 
    echo -e "\ncd /vagrant\n" >> /home/vagrant/.bashrc 
fi 

echo -e "\n\nfinished!\n"