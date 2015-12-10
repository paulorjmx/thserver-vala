// TCP Server
namespace Server
{
    public class ServerSocket : Object
    {
        private Thread<int> th_listen;
        private Thread<int> th_receive;
        private File _pref_file;
        private Socket _server_socket;
        private InetSocketAddress _ip;
        private uint _port;
        public signal void s_client_connected();

        //Properties
        public InetSocketAddress ip
        {
            set
            {
                _ip = value;
            }
            get
            {
                return _ip;
            }
        }

        public uint port
        {
            set
            {
                _port = value;
            }
            get
            {
                return _port;
            }
        }

        public ServerSocket()
        {
            try
            {
                _server_socket = new Socket(SocketFamily.IPV4, SocketType.STREAM, SocketProtocol.TCP);
            }
            catch (Error e)
            {
                stdout.printf("\n%s\n", e.message);
            }

        }

        public async void listen_async()
        {
            try
            {
                if(Thread.supported() == false)
                {
                    stdout.printf("\nThread is not supported by O.S.\n");
                }
                else
                {
                    th_listen = new Thread<int>.try("start_server_thread", start_server);
                }
            }
            catch(Error e)
            {
                stdout.printf("\n%s\n", e.message);
            }
        }

        private int start_server()
        {
            try
            {
                _server_socket.set_listen_backlog(10);
                _server_socket.bind(_ip, true);
                _server_socket.listen();
                _server_socket.accept();
            }
            catch (Error e)
            {
                stdout.printf("\n%s\n", e.message);
            }

            return 0;
        }
    }
}
