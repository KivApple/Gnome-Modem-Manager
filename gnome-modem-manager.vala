using Gtk;

[DBus (name = "org.freedesktop.ModemManager")]
interface ModemManager : GLib.Object {
	public abstract ObjectPath[] EnumerateDevices() throws IOError;
	public signal void DeviceAdded(ObjectPath device);
	public signal void DeviceRemoved(ObjectPath device);
}

struct ModemInfo {
	string manufacturer;
	string modem;
	string version;
}

[DBus (name = "org.freedesktop.ModemManager.Modem")]
interface Modem : GLib.Object {
	public abstract string Device { owned get; }
	public abstract string MasterDevice { owned get; }
	public abstract string Driver { owned get; }
	public abstract void Enable(bool enable) throws IOError;
	public abstract void Connect(string number) throws IOError;
	public abstract void Disconnect() throws IOError;
	public abstract ModemInfo GetInfo() throws IOError;
}

[DBus (name = "org.freedesktop.ModemManager.Modem.Gsm.Card")]
interface GsmModemCard : GLib.Object {
	public abstract void ChangePin(string old_pin, string new_pin) throws IOError;
	public abstract void EnablePin(string pin, bool enable) throws IOError;
	public abstract string GetImei() throws IOError;
	public abstract string GetImsi() throws IOError;
	public abstract string GetSpn() throws IOError;
}

struct GsmRegistrationInfo {
	uint status;
	string operator_code;
	string operator_name;
}

[DBus (name = "org.freedesktop.ModemManager.Modem.Gsm.Network")]
interface GsmModemNetwork : GLib.Object {
	public abstract uint GetBand() throws IOError;
	public abstract uint GetNetworkMode() throws IOError;
	public abstract uint GetSignalQuality() throws IOError;
	public abstract GsmRegistrationInfo GetRegistrationInfo() throws IOError;
	public signal void SignalQuality(uint quality);
	public signal void RegistrationInfo(uint status, string operator_code, string operator_name);
}

[DBus (name = "org.freedesktop.ModemManager.Modem.Gsm.Ussd")]
interface GsmModemUssd : GLib.Object {
	public abstract string State { owned get; }
	public abstract string NetworkNotification { owned get; }
	public abstract string NetworkRequest { owned get; }
	public abstract string Initiate(string command) throws IOError;
	public abstract string Respond(string response) throws IOError;
	public abstract void Cancel() throws IOError;
}

[DBus (name = "org.freedesktop.ModemManager.Modem.Gsm.SMS")]
interface GsmModemSms : GLib.Object {
	public abstract void Delete(uint index) throws IOError;
	public abstract HashTable<string, Variant> Get(uint index) throws IOError;
	public abstract uint GetFormat() throws IOError;
	public abstract void SetFormat(uint format) throws IOError;
	public abstract string GetSmsc() throws IOError;
	public abstract void SetSmsc(string format) throws IOError;
	public abstract HashTable<string, Variant>[] List() throws IOError;
	public abstract uint[] Save(HashTable<string, Variant> properties) throws IOError;
	public abstract uint[] Send(HashTable<string, Variant> properties) throws IOError;
	public abstract void SendFromStorage(uint index) throws IOError;
	public abstract void SetIndication(uint mode, uint mt, uint bm, uint ds, uint bfr) throws IOError;
	public signal void SmsReceived(uint index, bool complete);
	public signal void Completed(uint index, bool completed);
}

struct GsmContactInfo {
	uint index;
	string name;
	string number;
}

[DBus (name = "org.freedesktop.ModemManager.Modem.Gsm.Contacts")]
interface GsmModemContacts : GLib.Object {
	public abstract uint Add(string name, string number) throws IOError;
	public abstract void Delete(uint index) throws IOError;
	public abstract GsmContactInfo Get(uint index) throws IOError;
	public abstract GsmContactInfo[] List() throws IOError;
	public abstract GsmContactInfo[] Find(string pattern) throws IOError;
	public abstract uint GetCount() throws IOError;
}

class GnomeModemManager : GLib.Object {
	ModemManager modem_manager;
	
	Modem modem;
	GsmModemCard gsm_modem_card;
	GsmModemNetwork gsm_modem_network;
	GsmModemUssd gsm_modem_ussd;
	string modem_path;
	GsmModemSms gsm_modem_sms;
	GsmModemContacts gsm_modem_contacts;
	
	Builder builder;
	Window main_window;
	ListStore modem_liststore;
	ComboBox modem_combobox;
	Notebook notebook;
	Label modem_device_label;
	Label modem_master_device_label;
	Label modem_driver_label;
	Label modem_manufacturer_label;
	Label modem_modem_label;
	Label modem_version_label;
	Label modem_imei_label;
	Label modem_imsi_label;
	Label modem_spn_label;
	Label modem_operator_name_label;
	Label modem_signal_quality_label;
	Label modem_path_label;
	Widget contacts_tab;
	Label no_contacts_label;
	ListStore contact_liststore;
	TreeView contact_treeview;
	ListStore sms_liststore;
	TreeView sms_treeview;
	TextView sms_textview;
	Button remove_sms_button;
	TextView ussd_textview;
	Entry ussd_entry;
	Dialog sms_dialog;
	Entry sms_number_entry;
	TextView sms_dialog_textview;
	Dialog about_dialog;
	
	public GnomeModemManager() {
		this.load_ui();
		try {
			this.modem = null;
			this.modem_manager = Bus.get_proxy_sync(BusType.SYSTEM, "org.freedesktop.ModemManager", "/org/freedesktop/ModemManager");
			ObjectPath[] modem_paths = this.modem_manager.EnumerateDevices();
			foreach (ObjectPath modem_path in modem_paths) {
				this.device_added(modem_path);
			}
			this.modem_manager.DeviceAdded.connect(this.device_added);
			this.modem_manager.DeviceRemoved.connect(this.device_removed);
		} catch (Error e) {
			stderr.printf("Failed to connect to modem-manager: %s\n", e.message);
		}
		this.modem_changed(this.modem_combobox);
		this.main_window.visible = true;
	}
	
	private void load_ui() {
		try {
			this.builder = new Builder();
			this.builder.add_from_file("gnome-modem-manager.ui");
			this.builder.connect_signals(this);
			this.main_window = this.builder.get_object("main-window") as Window;
			this.modem_liststore = this.builder.get_object("modem-liststore") as ListStore;
			this.modem_combobox = this.builder.get_object("modem-combobox") as ComboBox;
			this.notebook = this.builder.get_object("notebook") as Notebook;
			this.modem_device_label = this.builder.get_object("modem-device-label") as Label;
			this.modem_master_device_label = this.builder.get_object("modem-master-device-label") as Label;
			this.modem_driver_label = this.builder.get_object("modem-driver-label") as Label;
			this.modem_manufacturer_label = this.builder.get_object("modem-manufacturer-label") as Label;
			this.modem_modem_label = this.builder.get_object("modem-modem-label") as Label;
			this.modem_version_label = this.builder.get_object("modem-version-label") as Label;
			this.modem_imei_label = this.builder.get_object("modem-imei-label") as Label;
			this.modem_imsi_label = this.builder.get_object("modem-imsi-label") as Label;
			this.modem_spn_label = this.builder.get_object("modem-spn-label") as Label;
			this.modem_operator_name_label = this.builder.get_object("modem-operator-name-label") as Label;
			this.modem_signal_quality_label = this.builder.get_object("modem-signal-quality-label") as Label;
			this.modem_path_label = this.builder.get_object("modem-path-label") as Label;
			this.contacts_tab = this.builder.get_object("contacts-tab") as Widget;
			this.no_contacts_label = this.builder.get_object("no-contacts-label") as Label;
			this.contact_liststore = this.builder.get_object("contacts-liststore") as ListStore;
			this.contact_treeview = this.builder.get_object("contact-treeview") as TreeView;
			this.sms_liststore = this.builder.get_object("sms-liststore") as ListStore;
			this.sms_treeview = this.builder.get_object("sms-treeview") as TreeView;
			this.sms_textview = this.builder.get_object("sms-textview") as TextView;
			this.remove_sms_button = this.builder.get_object("remove-sms-button") as Button;
			this.ussd_textview = this.builder.get_object("ussd-textview") as TextView;
			this.ussd_entry = this.builder.get_object("ussd-entry") as Entry;
			this.sms_dialog = this.builder.get_object("sms-dialog") as Dialog;
			this.sms_number_entry = this.builder.get_object("sms-number-entry") as Entry;
			this.sms_dialog_textview = this.builder.get_object("sms-dialog-textview") as TextView;
			this.about_dialog = this.builder.get_object("about-dialog") as Dialog;
		} catch (Error e) {
			stderr.printf("Failed to load ui: %s\n", e.message);
		}
	}
	
	[CCode (instance_pos = -1)]
	public void modem_changed(ComboBox combobox) {
		TreeIter iter;
		if (combobox.get_active_iter(out iter)) {
			if (this.modem != null) {
				this.gsm_modem_network.SignalQuality.disconnect(this.signal_quality_changed);
				this.gsm_modem_network.RegistrationInfo.disconnect(this.registration_info_changed);				
			}
			modem_liststore.get(iter, 1, out this.modem, 2, out this.gsm_modem_card, 3, out this.gsm_modem_network,
				4, out this.gsm_modem_ussd, 5, out this.modem_path, 6, out this.gsm_modem_sms, 7, out this.gsm_modem_contacts);
			this.gsm_modem_network.SignalQuality.connect(this.signal_quality_changed);
			this.gsm_modem_network.RegistrationInfo.connect(this.registration_info_changed);
			notebook.sensitive = true;
			try {
				this.modem.Enable(true);
				this.modem_driver_label.set_text(this.modem.Driver);
				this.modem_device_label.set_text(this.modem.Device);
				this.modem_master_device_label.set_text(this.modem.MasterDevice);
				{
					ModemInfo info = this.modem.GetInfo();
					this.modem_manufacturer_label.set_text(info.manufacturer);
					this.modem_modem_label.set_text(info.modem);
					this.modem_version_label.set_text(info.version);
				}
				this.modem_imei_label.set_text(this.gsm_modem_card.GetImei());
				try {
					this.modem_imsi_label.set_text(this.gsm_modem_card.GetImsi());
				} catch (Error e) {
					this.modem_imsi_label.set_text("Unavailable");
				}
				this.modem_spn_label.set_text(this.gsm_modem_card.GetSpn());
				this.modem_signal_quality_label.set_text("%u%%".printf(this.gsm_modem_network.GetSignalQuality()));
				{
					GsmRegistrationInfo info = this.gsm_modem_network.GetRegistrationInfo();
					this.modem_operator_name_label.set_text(info.operator_name);
				}
				this.modem_path_label.set_text(this.modem_path);
			} catch (Error e) {
				warning("Query modem info error: %s", e.message);
			}
			try {
				contact_liststore.clear();
				GsmContactInfo[] contacts = this.gsm_modem_contacts.List();
				foreach (GsmContactInfo contact in contacts) {
					TreeIter i;
					contact_liststore.append(out i);
					contact_liststore.set(i, 0, contact.index, 1, contact.name, 2, contact.number);
				}
				this.contacts_tab.sensitive = true;
				this.no_contacts_label.visible = false;
			} catch (Error e) {
				this.no_contacts_label.visible = true;
				this.contacts_tab.sensitive = false;
			}
			this.update_sms_list();
		} else {
			notebook.sensitive = false;
			this.modem = null;
		}
	}
	
	[CCode (instance_pos = -1)]
	public void current_sms_changed(TreeView tree_view) {
		TreePath path;
		tree_view.get_cursor(out path, null);
		if (path != null) {
			this.sms_textview.sensitive = true;
			this.remove_sms_button.sensitive = true;
			TreeIter iter;
			this.sms_liststore.get_iter(out iter, path);
			string text;
			this.sms_liststore.get(iter, 2, out text);
			this.sms_textview.buffer.text = text;
		} else {
			this.sms_textview.sensitive = false;
			this.remove_sms_button.sensitive = false;
		}		
	}
	
	[CCode (instance_pos = -1)]
	public void create_sms_button_clicked(Button button) {
		sms_number_entry.text = "+7";
		sms_dialog_textview.buffer.text = "";
		uint result = sms_dialog.run();
		if (result != 0) {
			var props = new HashTable<string, Variant>(str_hash, str_equal);
			props.insert("number", sms_number_entry.text);
			props.insert("text", sms_dialog_textview.buffer.text);
			switch (result) {
				case 1:
					try {
						uint[] index = this.gsm_modem_sms.Send(props);
						TreeIter iter;
						sms_liststore.append(out iter);
						sms_liststore.set(iter, 0, index[0], 1, sms_number_entry.text,
							2, sms_dialog_textview.buffer.text, 3, true);
					} catch (Error e) {
						var dialog = new MessageDialog.with_markup(this.main_window,
							DialogFlags.MODAL | DialogFlags.DESTROY_WITH_PARENT, MessageType.ERROR, ButtonsType.CLOSE,
							"<b>Failed to send SMS</b>\n%s", e.message);
						dialog.run();
						dialog.destroy();
					}
					break;
				case 2:
					try {
						uint[] index = this.gsm_modem_sms.Save(props);
						TreeIter iter;
						sms_liststore.append(out iter);
						sms_liststore.set(iter, 0, index[0], 1, sms_number_entry.text,
							2, sms_dialog_textview.buffer.text, 3, true);
					} catch (Error e) {
						var dialog = new MessageDialog.with_markup(this.main_window,
							DialogFlags.MODAL | DialogFlags.DESTROY_WITH_PARENT, MessageType.ERROR, ButtonsType.CLOSE,
							"<b>Failed to save SMS</b>\n%s", e.message);
						dialog.run();
						dialog.destroy();
					}
					break;
			}
		}
		sms_dialog.hide();
	}
	
	[CCode (instance_pos = -1)]
	public void remove_sms_button_clicked(Button button) {
		TreePath path;
		this.sms_treeview.get_cursor(out path, null);
		TreeIter iter;
		this.sms_liststore.get_iter(out iter, path);
		uint index;
		this.sms_liststore.get(iter, 0, out index);
		try {
			this.gsm_modem_sms.Delete(index);
			this.sms_liststore.remove(iter);
		} catch (Error e) {
			var dialog = new MessageDialog.with_markup(this.main_window, DialogFlags.MODAL | DialogFlags.DESTROY_WITH_PARENT,
				MessageType.ERROR, ButtonsType.CLOSE, "<b>Failed to delete SMS</b>\n%s", e.message);
			dialog.run();
			dialog.destroy();
		}
	}
	
	[CCode (instance_pos = -1)]
	public void send_ussd_button_clicked(Button button) {
		try {
			string result = this.gsm_modem_ussd.Initiate(this.ussd_entry.text);
			this.ussd_textview.buffer.text = result;
		} catch (Error e) {
			var dialog = new MessageDialog.with_markup(this.main_window, DialogFlags.MODAL | DialogFlags.DESTROY_WITH_PARENT,
				MessageType.ERROR, ButtonsType.CLOSE, "<b>USSD query failed</b>\n%s", e.message);
			dialog.run();
			dialog.destroy();
		}
		try {
			this.gsm_modem_ussd.Cancel();
		} catch (Error e) {}
	}
	
	[CCode (instance_pos = -1)]
	public void about_button_clicked(Button button) {
		this.about_dialog.run();
		this.about_dialog.hide();
	}
	
	[CCode (instance_pos = -1)]
	public void close_button_clicked(Button button) {
		Gtk.main_quit();
	}
	
	private void signal_quality_changed(uint quality) {
		this.modem_signal_quality_label.set_text("%u%%".printf(quality));
	}
	
	private void registration_info_changed(uint status, string operator_code, string operator_name) {
		this.modem_spn_label.set_text(operator_code);
		this.modem_operator_name_label.set_text(operator_name);
	}
	
	private void sms_received(uint index, bool complete) {
		HashTable<string, Variant> sms = this.gsm_modem_sms.Get(index);
		string number = sms.lookup("number").get_string();
		string text = sms.lookup("text").get_string();
		bool completed = sms.lookup("completed").get_boolean();
		TreeIter iter;
		sms_liststore.append(out iter);
		sms_liststore.set(iter, 0, index, 1, number, 2, text, 3, completed);
	}
	
	private void sms_completed(uint index, bool completed) {
		var path = new TreePath.from_indices(index);
		TreeIter iter;
		this.sms_liststore.get_iter(out iter, path);
		this.sms_liststore.set(iter, 3, completed);
	}
	
	private void device_added(ObjectPath device) {
		Modem modem = Bus.get_proxy_sync(BusType.SYSTEM, "org.freedesktop.ModemManager", device);
		GsmModemCard gsm_modem_card = Bus.get_proxy_sync(BusType.SYSTEM, "org.freedesktop.ModemManager", device);
		GsmModemNetwork gsm_modem_network = Bus.get_proxy_sync(BusType.SYSTEM, "org.freedesktop.ModemManager", device);
		GsmModemUssd gsm_modem_ussd = Bus.get_proxy_sync(BusType.SYSTEM, "org.freedesktop.ModemManager", device);
		GsmModemSms gsm_modem_sms = Bus.get_proxy_sync(BusType.SYSTEM, "org.freedesktop.ModemManager", device);
		GsmModemContacts gsm_modem_contacts = Bus.get_proxy_sync(BusType.SYSTEM, "org.freedesktop.ModemManager", device);
		TreeIter iter;
		this.modem_liststore.append(out iter);
		ModemInfo info = modem.GetInfo();
		this.modem_liststore.set(iter, 0, "%s (%s %s)".printf(modem.Device, info.manufacturer, info.modem),
			1, modem, 2, gsm_modem_card, 3, gsm_modem_network, 4, gsm_modem_ussd, 5, device, 6, gsm_modem_sms, 7, gsm_modem_contacts);
		if (this.modem == null) {
			modem_combobox.active = 0;
		}
	}
	
	private void device_removed(ObjectPath device) {
		this.modem_liststore.foreach((model, path, iter) => {
				string object_path;
				model.get(iter, 5, out object_path);
				if (object_path == device) {
					(model as ListStore).remove(iter);
					return false;
				} else {
					return true;
				}
			});
	}
	
	private void update_sms_list() {
		try {
			sms_liststore.clear();
			HashTable<string, Variant>[] sms_list = this.gsm_modem_sms.List();
			uint index = 0;
			foreach (HashTable<string, Variant> sms in sms_list) {
				string number = sms.lookup("number").get_string();
				string text = sms.lookup("text").get_string();
				bool completed = sms.lookup("completed").get_boolean();
				TreeIter i;
				sms_liststore.append(out i);
				sms_liststore.set(i, 0, index, 1, number, 2, text, 3, completed);
				index++;
			}
		} catch (Error e) {
			warning("Failed to fetch SMS list: %s", e.message);
		}
	}
	
	public void run() {
		Gtk.main();
	}
	
	static int main(string[] args) {
		Gtk.init(ref args);
		var application = new GnomeModemManager();
		application.run();
		return 0;
	}
}
