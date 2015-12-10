// TCP Server
namespace Server
{
    public class ServerSocket : Object
    {
        private File _pref_file;
        private Socket _server_socket;
        private InetSocketAddress _ip;
        private uint _port;

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

        }
    }
}
