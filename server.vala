namespace Server
{
    public class ServerSocket : Object
    {
        private Thread<int> th_listen;
        private Thread<int> th_receive;
        private Socket _server;
        private Socket _ctl_socket;
        public signal void client_connected();
        public signal void packet_received(uint8[] packet);

        public ServerSocket(string address, uint16 port)
        {
            InetSocketAddress _socket_address = new InetSocketAddress.from_string(address, port);
            _server = new Socket(SocketFamily.IPV4, SocketType.STREAM, SocketProtocol.TCP);
            _server.bind(_socket_address, true);
            _server.set_listen_backlog(10);
            _server.listen();
            stdout.printf("\nComecando a ouvir...\n");
        }

        public async void begin_accept()
        {
            if(Thread.supported())
            {
                th_listen = new Thread<int>.try("begin_accept", start_server);
            }
            else
            {
                stdout.printf("\nO sistema nao possui suporte para threads!\n");
            }
        }

        private int start_server()
        {
            while(true)
            {
                stdout.printf("\nAceitando conexoes...\n");
                _ctl_socket = _server.accept();
                client_connected();
                this.begin_receive.begin((obj, res) =>
                {
                    this.begin_receive.end(res);
                });
            }
            return 0;
        }

        public async void begin_receive()
        {
            if(Thread.supported())
            {
                th_receive = new Thread<int>.try("begin_receive", receive_data);
            }
            else
            {
                stdout.printf("\nO sistema nao possui suporte para threads!\n");
            }
        }

        private int receive_data()
        {
            while(true)
            {
                if(_ctl_socket.condition_wait(IOCondition.IN) == true)
                {
                    uint8[] _buffer = new uint8[256];
                    ssize_t len = _ctl_socket.receive(_buffer);
                    stdout.printf("\n%s\n", (string) _buffer);
                    packet_received(_buffer);
                    continue;
                }
                else
                {
                    continue;
                }
            }
            return 0;
        }
    }
}
