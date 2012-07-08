#!/bin/sh
DEBIANDIR=`pwd`
cd ../..
CURDIR=`pwd`
make
mkdir $CURDIR/package
fakeroot make install DESTDIR=$CURDIR/package
BINSIZE=`du -s $CURDIR/package | grep  -o [0-9]*`
cp -r $DEBIANDIR/info $CURDIR/package/DEBIAN
cat $CURDIR/package/DEBIAN/control.template | sed "s/\$BINSIZE/$BINSIZE/g" > $CURDIR/package/DEBIAN/control
rm -f $CURDIR/package/DEBIAN/control.template
fakeroot dpkg -b package
mv "package.deb" "packaging/debian/gnome-modem-manager.deb"
rm -rf $CURDIR/package
