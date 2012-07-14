all: compile locale
compile: gnome-modem-manager.vala
	valac -X -DGETTEXT_PACKAGE="gnome-modem-manager" --disable-warnings --pkg gmodule-2.0 --pkg gio-2.0 --pkg gtk+-3.0 gnome-modem-manager.vala
locale: po/gnome-modem-manager-ru_RU.po po/gnome-modem-manager-ru_UA.po
	msgfmt --output-file=po/gnome-modem-manager-ru_RU.mo po/gnome-modem-manager-ru_RU.po
	msgfmt --output-file=po/gnome-modem-manager-ru_UA.mo po/gnome-modem-manager-ru_UA.po
clean:
	rm -f gnome-modem-manager
	rm -f po/*.mo
install:
	install -Dm0755 gnome-modem-manager ${DESTDIR}/opt/extras.ubuntu.com/gnome-modem-manager/gnome-modem-manager
	install -Dm0644 gnome-modem-manager.ui ${DESTDIR}/opt/extras.ubuntu.com/gnome-modem-manager/gnome-modem-manager.ui
	install -Dm0755 gnome-modem-manager.desktop ${DESTDIR}/usr/share/applications/extras-gnome-modem-manager.desktop
	install -Dm0644 po/gnome-modem-manager-ru_RU.mo ${DESTDIR}/opt/extras.ubuntu.com/gnome-modem-manager/locale/ru_RU/LC_MESSAGES/gnome-modem-manager.mo
	install -Dm0644 po/gnome-modem-manager-ru_UA.mo ${DESTDIR}/opt/extras.ubuntu.com/gnome-modem-manager/locale/ru_UA/LC_MESSAGES/gnome-modem-manager.mo
uninstall:
	rm -fv ${DESTDIR}/opt/extras.ubuntu.com/gnome-modem-manager/gnome-modem-manager
	rm -fv ${DESTDIR}/opt/extras.ubuntu.com/gnome-modem-manager/gnome-modem-manager.ui
	rm -fv ${DESTDIR}/usr/share/applications/extras-gnome-modem-manager.desktop
	rm -fv ${DESTDIR}/opt/extras.ubuntu.com/gnome-modem-manager/locale/ru_RU/LC_MESSAGES/gnome-modem-manager.mo
	rm -fv ${DESTDIR}/opt/extras.ubuntu.com/gnome-modem-manager/locale/ru_UA/LC_MESSAGES/gnome-modem-manager.mo
	rm -frv ${DESTDIR}/opt/extras.ubuntu.com/gnome-modem-manager
