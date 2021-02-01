const String google_server_ip = "";
const String localhost = "localhost";

String getConfigString(String ip, int port, String call,
    {Map<String, dynamic> parameter}) {
  return 'ws://' + ip + ':' + port.toString() + '/$call?';
}
