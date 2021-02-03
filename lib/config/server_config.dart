const String _google_server_ip = "34.126.93.133";
const String _localhost = "localhost";
const int _port = 8000;

String _getStringCall(bool isWebsocket, String ip, int port, String call,
    Map<String, dynamic> parameters) {
  var header = 'http://';

  if (isWebsocket) {
    header = 'ws://';
  }

  var parameterString = '';

  if (parameters != null) {
    parameterString = parameterString + '?';
    parameters.forEach((key, value) {
      parameterString = parameterString + '$key=$value&';
    });
  }

  return header + ip + ':' + port.toString() + '/' + '$call' + parameterString;
}

String _getSocketConfigString(String ip, int port, String call,
    {Map<String, dynamic> parameters}) {
  return _getStringCall(true, ip, port, call, parameters);
}

String _getHttpPath(String ip, int port, String call,
    {Map<String, dynamic> parameters}) {
  return _getStringCall(false, ip, port, call, parameters);
}

String getUrltoStartRenderInstance(bool useLocalhost) {
  final ipAddr = useLocalhost ? _localhost : _google_server_ip;
  return _getSocketConfigString(ipAddr, _port, 'webg3n');
}

String getUrltoFollowRenderInstance(bool useLocalhost, String uuid) {
  assert(uuid != null);

  final ipAddr = useLocalhost ? _localhost : _google_server_ip;
  return _getSocketConfigString(ipAddr, _port, 'rtcwebg3n',
      parameters: {'uuid': uuid});
}

String getUrltoUploadModel(bool useLocalhost) {
  final ipAddr = useLocalhost ? _localhost : _google_server_ip;
  return _getHttpPath(ipAddr, _port, 'loadModel');
}

String getUrltoGetObjectList(bool useLocalhost) {
  final ipAddr = useLocalhost ? _localhost : _google_server_ip;
  return _getHttpPath(ipAddr, _port, 'objects');
}

String getUrltoGetClientList(bool useLocalhost) {
  final ipAddr = useLocalhost ? _localhost : _google_server_ip;
  return _getHttpPath(ipAddr, _port, 'allclients');
}
