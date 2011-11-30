all: compile
compile: gnome-modem-manager.vala
	valac --disable-warnings --pkg gmodule-2.0 --pkg gio-2.0 --pkg gtk+-3.0 gnome-modem-manager.vala
clean:
	rm -f gnome-modem-manager
