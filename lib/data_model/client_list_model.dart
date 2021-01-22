class ClientList {
  const ClientList(this.clients, this.count);

  final List<String> clients;
  final int count;

  bool get isEmpty {
    if (clients != null && clients.isNotEmpty) {
      return false;
    }

    return true;
  }

  factory ClientList.fromMap(Map<String, dynamic> map) {
    final _clientList =
        map['clients'] == null ? null : (map['clients'] as List);
    final _clientListString = _clientList == null
        ? null
        : _clientList.map((client) {
            return client.toString();
          }).toList();
    final _count = map['count'];

    return ClientList(_clientListString, _count);
  }

  //@override
  List<Object> get props => [clients, count];
}
