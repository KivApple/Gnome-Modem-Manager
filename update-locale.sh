#!/bin/sh
xgettext --language=Glade -o po/gnome-modem-manager.pot gnome-modem-manager.ui
msgmerge po/gnome-modem-manager-ru_RU.po po/gnome-modem-manager.pot > /tmp/ru_RU.po
mv /tmp/ru_RU.po po/gnome-modem-manager-ru_RU.po
msgmerge po/gnome-modem-manager-ua_UA.po po/gnome-modem-manager.pot > /tmp/ua_UA.po
mv /tmp/ua_UA.po po/gnome-modem-manager-ua_UA.po
