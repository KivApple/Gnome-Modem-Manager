all: compile
compile: gnome-modem-manager.vala
	valac --disable-warnings --pkg gmodule-2.0 --pkg gio-2.0 --pkg gtk+-3.0 gnome-modem-manager.vala
clean:
	rm -f gnome-modem-manager
install:
	install -Dm0755 gnome-modem-manager ${DESTDIR}/usr/bin/gnome-modem-manager
	install -Dm0644 gnome-modem-manager.ui ${DESTDIR}/usr/share/gnome-modem-manager.ui
	install -Dm0755 gnome-modem-manager.desktop ${DESTDIR}/usr/share/applications/gnome-modem-manager.desktop
uninstall:
	rm -fv ${DESTDIR}/usr/bin/gnome-modem-manager
	rm -fv gnome-modem-manager.ui ${DESTDIR}/usr/share/gnome-modem-manager.ui
	rm -fv gnome-modem-manager.desktop ${DESTDIR}/usr/share/applications/gnome-modem-manager.desktop
