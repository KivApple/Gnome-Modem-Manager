#!/bin/sh
cd ../..
make
mkdir package
fakeroot make install DESTDIR=package
CURDIR=`pwd`
ln -s $CURDIR/packaging/debian/info $CURDIR/package/DEBIAN
fakeroot dpkg -b package
mv "package.deb" "packaging/debian/gnome-modem-manager.deb"
rm -rf $CURDIR/package
