namespace Server
{
    public int main(string[] args)
    {
        Gtk.init(ref args);
        ServerUI server_ui = new ServerUI();
        server_ui.main_window.show_all();
        Gtk.main();
        return 0;
    }
}
