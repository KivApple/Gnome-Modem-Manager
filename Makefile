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
	install -Dm0755 gnome-modem-manager ${DESTDIR}/usr/bin/gnome-modem-manager
	install -Dm0644 gnome-modem-manager.ui ${DESTDIR}/usr/share/gnome-modem-manager/gnome-modem-manager.ui
	install -Dm0755 gnome-modem-manager.desktop ${DESTDIR}/usr/share/applications/gnome-modem-manager.desktop
	install -Dm0644 po/gnome-modem-manager-ru_RU.mo ${DESTDIR}/usr/share/locale/ru_RU/LC_MESSAGES/gnome-modem-manager.mo
uninstall:
	rm -fv ${DESTDIR}/usr/bin/gnome-modem-manager
	rm -fv ${DESTDIR}/usr/share/gnome-modem-manager/gnome-modem-manager.ui
	rm -fv ${DESTDIR}/usr/share/applications/gnome-modem-manager.desktop
	rm -fv ${DESTDIR}/usr/share/locale/ru_RU/LC_MESSAGES/gnome-modem-manager.mo
