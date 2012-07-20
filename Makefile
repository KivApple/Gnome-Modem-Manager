TMP = $(shell [ -e /etc/lsb-release ] && cat /etc/lsb-release | grep Ubuntu)

ifneq ($(TMP),)
	IS_UBUNTU = 1
endif

ifdef IS_UBUNTU
	DATA_DIR = ${DESTDIR}/opt/extras.ubuntu.com/gnome-modem-manager
	BIN_DIR = ${DESTDIR}/opt/extras.ubuntu.com/gnome-modem-manager
	LOCALE_DIR = ${DESTDIR}/opt/extras.ubuntu.com/gnome-modem-manager/locale
	DESKTOP_FILE_NAME = extras-gnome-modem-manager.desktop
else
	DATA_DIR = ${DESTDIR}/usr/share/gnome-modem-manager
	BIN_DIR = ${DESTDIR}/usr/bin
	LOCALE_DIR = ${DESTDIR}/usr/share/locale
	DESKTOP_FILE_NAME = gnome-modem-manager.desktop
endif

all: compile locale
compile: gnome-modem-manager.vala
	valac -X -DGETTEXT_PACKAGE="gnome-modem-manager" --disable-warnings --pkg gmodule-2.0 --pkg gio-2.0 --pkg gtk+-3.0 gnome-modem-manager.vala
locale: po/gnome-modem-manager-ru_RU.po po/gnome-modem-manager-ua_UA.po
	msgfmt --output-file=po/gnome-modem-manager-ru_RU.mo po/gnome-modem-manager-ru_RU.po
	msgfmt --output-file=po/gnome-modem-manager-ua_UA.mo po/gnome-modem-manager-ua_UA.po
clean:
	rm -f gnome-modem-manager
	rm -f po/*.mo
install:
	install -Dm0755 gnome-modem-manager ${BIN_DIR}/gnome-modem-manager
	install -Dm0644 gnome-modem-manager.ui ${DATA_DIR}/gnome-modem-manager.ui
	install -Dm0755 ${DESKTOP_FILE_NAME} ${DESTDIR}/usr/share/applications/${DESKTOP_FILE_NAME}
	install -Dm0644 po/gnome-modem-manager-ru_RU.mo ${LOCALE_DIR}/ru/LC_MESSAGES/gnome-modem-manager.mo
	install -Dm0644 po/gnome-modem-manager-ru_RU.mo ${LOCALE_DIR}/ru_RU/LC_MESSAGES/gnome-modem-manager.mo
	install -Dm0644 po/gnome-modem-manager-ua_UA.mo ${LOCALE_DIR}/ua/LC_MESSAGES/gnome-modem-manager.mo
	install -Dm0644 po/gnome-modem-manager-ua_UA.mo ${LOCALE_DIR}/ua_UA/LC_MESSAGES/gnome-modem-manager.mo
uninstall:
	rm -fv ${BIN_DIR}/gnome-modem-manager
	rm -fv ${DATA_DIR}/gnome-modem-manager.ui
	rm -fv ${DESTDIR}/usr/share/applications/${DESKTOP_FILE_NAME}
	rm -fv ${LOCALE_DIR}/ru/LC_MESSAGES/gnome-modem-manager.mo
	rm -fv ${LOCALE_DIR}/ru_RU/LC_MESSAGES/gnome-modem-manager.mo
	rm -fv ${LOCALE_DIR}/ua/LC_MESSAGES/gnome-modem-manager.mo
	rm -fv ${LOCALE_DIR}/ua_UA/LC_MESSAGES/gnome-modem-manager.mo
	rm -frv ${DESTDIR}/opt/extras.ubuntu.com/gnome-modem-manager
