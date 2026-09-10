#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm     \
    gst-plugins-base        \
    gst-plugins-good        \
    libayatana-appindicator

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano webkit2gtk-4.1-mini

# Comment this out if you need an AUR package
#make-aur-package dorion-bin

# If the application needs to be manually built that has to be done down here

# if you also have to make nightly releases check for DEVEL_RELEASE = 1
case "$ARCH" in # they use AMD64 and ARM64 for the deb links
	x86_64)  deb_arch=amd64;;
	aarch64) deb_arch=arm64;;
esac
DEB_LINK=$(wget https://api.github.com/repos/SpikeHD/Dorion/releases -O - \
      | sed 's/[()",{} ]/\n/g' | grep -o -m 1 "https.*$deb_arch.deb")
echo "$DEB_LINK" | awk -F'/' '{gsub(/^v/, "", $(NF-1)); print $(NF-1); exit}' > ~/version
if ! wget --retry-connrefused --tries=30 "$DEB_LINK" -O /tmp/app.deb 2>/tmp/download.log; then
	cat /tmp/download.log
	exit 1
fi

mkdir -p ./AppDir/bin
ar xvf /tmp/app.deb
tar -xvf ./data.tar.gz
rm -f ./*.gz
