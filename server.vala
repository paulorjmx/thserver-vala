namespace Server
{
    public class ServerSocket : Object
    {
        private Thread<void*> th_listen;
        private Thread<void*> th_receive;
        private Socket _server;
        public signal void client_connected();
        public signal void packet_received(uint8[] packet, int len);

        public ServerSocket(string address, uint16 port)
        {
            InetSocketAddress _socket_address = new InetSocketAddress.from_string(address, port);
            _server = new Socket(SocketFamily.IPV4, SocketType.STREAM, SocketProtocol.TCP);
            _server.set_keepalive(true);
            _server.bind(_socket_address, true);
            _server.set_listen_backlog(10);
            _server.listen();
            stdout.printf("\nComecando a ouvir...\n");
        }

        public async void begin_accept()
        {
            if(Thread.supported() == true)
            {
                try
                {
                    th_listen = new Thread<void*>.try("LISTEN_THREAD", () =>
                    {
                        while(true)
                        {
                            Socket _ctl_socket = _server.accept();
                            client_connected();
                            this.receive_data.begin(_ctl_socket, (obj, res) =>
                            {
                                this.receive_data.end(res);
                            });
                        }
                        return null;
                    });
                }
                catch(Error e)
                {
                    stdout.printf("\n%s\n", e.message);
                }
            }
            else
            {
                stdout.printf("\nO sistema operacional nao oferece suporte para threads!.\n");
            }
        }

        public async void receive_data(Socket _sock)
        {
            if(Thread.supported() == true)
            {
                try
                {
                    th_receive = new Thread<void*>.try("RECEIVE_THREAD", () =>
                    {
                        while(true)
                        {
                            if(_sock.condition_wait(IOCondition.IN) == true)
                            {
                                uint8[] _buffer = new uint8[256];
                                ssize_t len = _sock.receive(_buffer);
                                if((string) _buffer == "SHT_CLI")
                                {
                                    _sock.shutdown(true, true);
                                    _sock.close();
                                    break;
                                }
                                packet_received(_buffer, (int) len);
                                continue;
                            }
                            else
                            {
                                continue;
                            }
                        }
                        return null;
                    });
                }
                catch(Error e)
                {
                    stdout.printf("\n%s\n", e.message);
                }
            }
            else
            {
                stdout.printf("\nO sistema operacional nao oferece suporte para threads!.\n");
            }
        }
    }
}
