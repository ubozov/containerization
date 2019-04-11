#!/bin/bash
RED="\033[1;31m"
GREEN="\033[1;32m"
NOCOLOR="\033[0m"

if [ -n "$1" ]
then
    source ./yaml.sh
	create_variables $1
else
	. ./container.config
fi

container=${CONTAINER_NAME:-test-container}
version=${CONTAINER_VERSION:-stretch}
password=${CONTAINER_PASSWORD:-p0S1w2D3}
archive=${CONTAINER_TAR:-on}

echo "Container name:" ${container}
echo "Debian version:" ${version}
echo "Container root password:" ${password}
echo "Container archiving status:" ${archive}

# create container
sudo debootstrap ${version} ./${container} http://deb.debian.org/debian

# connect to container
sudo systemd-nspawn -D ${container}/ << EOF

#set root password
echo -e "$password\n$password\n" | passwd

echo "pts/0" >> /etc/securetty
echo deb http://deb.debian.org/debian $version-backports main > /etc/apt/sources.list.d/$version-backports.list

apt update
apt -t $version-backports install -y systemd
apt install -y dbus net-tools

# install locale
apt install -y locales

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
update-locale LANG=en_US.UTF-8

rm -rf /usr/share/doc/*
find /usr/share/locale -maxdepth 1 -mindepth 1 ! -name en_US -exec rm -rf {} \;
find /usr/share/i18n/locales -maxdepth 1 -mindepth 1 ! -name en_US -exec rm -rf {} \;
rm -rf /usr/share/man/*
rm -rf /usr/share/groff/*
rm -rf /usr/share/info/*
rm -rf /usr/share/lintian/*
rm -rf /usr/include/*

logout
EOF

if [ "$archive" = "on" ]
then
    echo "Creating tar archive..."
    # create tar archive
    sudo tar cpJf ${container}.tar.xz --exclude="./var/cache/apt/archives/*.deb" \
    --exclude="./var/lib/apt/lists/*" --exclude="./var/cache/apt/*.bin" \
    --one-file-system -C ${container} .

    if [[ $? > 0 ]] 
    then 
        echo -e "[${RED}FAIL${NOCOLOR}] Occured error"
        exit 1
    else
        echo -e "[${GREEN}OK${NOCOLOR}] Container was succesfully archived."
    fi
fi

echo "Container was succesfully created."