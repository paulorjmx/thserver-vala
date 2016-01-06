using Gtk;

namespace Server
{
    public class ServerUI : Object
    {
        private ServerSocket _server = new ServerSocket("127.0.0.1", 8000);
        private Window _main_window;
        private Dialog _prefs_dialog;
        private Entry _ip_entry;
        private Entry _port_entry;
        private ImageMenuItem _preferences;
        private ImageMenuItem _start;
        private ImageMenuItem _stop;
        private TextView _log_msg;
        private Builder _builder;
        private StringBuilder _sb = new StringBuilder();

        public ServerUI()
        {
            _builder = new Builder.from_file("ui/server.ui");
            _main_window =  _builder.get_object("main_window") as Gtk.Window;
            _prefs_dialog = _builder.get_object("dialog_prefs") as Dialog;
            _prefs_dialog.add_button("_OK", ResponseType.OK);
            _prefs_dialog.add_button("_Cancel", ResponseType.CANCEL);
            _preferences = _builder.get_object("img_prefs") as ImageMenuItem;
            _start = _builder.get_object("img_start") as ImageMenuItem;
            _stop = _builder.get_object("img_stop") as ImageMenuItem;
            _ip_entry = _builder.get_object("entry_ip") as Entry;
            _port_entry = _builder.get_object("entry_port") as Entry;
            _log_msg = _builder.get_object("log_msg") as TextView;
            connect_events();
        }

        //Properties
        public Gtk.Window main_window
        {
            private set { }
            get
            {
                return _main_window;
            }
        }

        private void connect_events()
        {
            _main_window.destroy.connect(on_main_main_window_destroy);
            _start.activate.connect(on_start_activate);
            _stop.activate.connect(on_stop_activate);
            _preferences.activate.connect(on_preferences_activated);
            _prefs_dialog.delete_event.connect(on_dialog_prefs_close);
            _prefs_dialog.response.connect(on_prefs_dialog_response);
            _server.client_connected.connect(on_client_connected);
            _server.packet_received.connect(on_packet_received);
        }

        // Events Methods
        private void on_start_activate()
        {
            _server.begin_accept.begin( (obj, res) =>
            {
                _server.begin_accept.end(res);
            });
        }

        private void on_client_connected()
        {
            /*_sb.append("\nCliente conectado!\n");*/
            /*_log_msg.buffer.text = (string) _sb.data;*/
            stdout.printf("\nCliente conectado!\n");
        }

        private void on_packet_received(uint8[] buffer)
        {
            _sb.append("\n");
            _sb.append((string) buffer);
            _log_msg.buffer.text = (string) _sb.data;
            stdout.printf("\n%s\n", (string) buffer);
        }

        private void on_stop_activate()
        {

        }

        private void on_main_main_window_destroy()
        {
            /*_server.shutdown_server();*/
            Gtk.main_quit();
        }

        private void on_preferences_activated()
        {
            _prefs_dialog.show();
        }

        private bool on_dialog_prefs_close(Gdk.EventAny e)
        {
            if(e.type == Gdk.EventType.DELETE)
            {
                _prefs_dialog.hide_on_delete();
                return true;
            }
            else
            {
                return false;
            }
        }

        private void on_prefs_dialog_response(int id_response)
        {
            switch(id_response)
            {
                case ResponseType.OK:
                    if(_ip_entry.text == "")
                    {
                        // Error message
                        MessageDialog _msg_dialog = new MessageDialog(_main_window, DialogFlags.MODAL, MessageType.WARNING, ButtonsType.OK, "O campo IP Address não pode ficar vazio!");
                        _msg_dialog.set_title("Warning!");
                        _msg_dialog.show_all();
                        _msg_dialog.destroy.connect( (s) =>
                        {
                                _msg_dialog.destroy();
                        });
                        _msg_dialog.response.connect( (s, r) =>
                        {
                            switch(r)
                            {
                                case ResponseType.OK:
                                    _msg_dialog.destroy();
                                    break;

                                default:
                                    _msg_dialog.destroy();
                                    break;
                            }
                        });
                    }
                    else
                    {
                        if(_port_entry.text == "")
                        {
                            // Error message
                            MessageDialog _msg_dialog = new MessageDialog(_main_window, DialogFlags.MODAL, MessageType.WARNING, ButtonsType.OK_CANCEL, "O campo port não pode ficar vazio!");
                            _msg_dialog.set_title("Warning!");
                            _msg_dialog.show_all();
                            _msg_dialog.destroy.connect( (s) =>
                            {
                                    _msg_dialog.close();
                            });
                            _msg_dialog.response.connect( (s, r) =>
                            {
                                switch(r)
                                {
                                    case ResponseType.OK:
                                        _msg_dialog.close();
                                        break;

                                    default:
                                        _msg_dialog.close();
                                        break;
                                }
                            });
                        }
                        else
                        {
                            /*_server.listen_address = new InetSocketAddress.from_string(_ip_entry.get_text(), 8000);*/
                            /*stdout.printf("\n%s\n", _server.listen_address.address.to_string());*/
                            /*stdout.printf("\n%s\n", _server.listen_address.get_port().to_string());*/
                            _prefs_dialog.hide_on_delete();
                        }
                    }
                    break;

                case ResponseType.CANCEL:
                    _prefs_dialog.hide_on_delete();
                    break;

                default:
                    _prefs_dialog.hide_on_delete();
                    break;
            }
        }
    }
}
