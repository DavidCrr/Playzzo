import 'package:flutter/foundation.dart';

class Player {
  final String name;
  final bool isHost;
  Player({required this.name, this.isHost = false});
}

class SetupJogoImpostorModel with ChangeNotifier{
  final List<Player> _players = [

    Player(name: 'Ana Julia', isHost: true),
    Player(name: 'Marcos PP'),
    Player(name: 'Marcos V.'),
    Player(name: 'David'),
    Player(name: 'Paulo'),
  ];
    List<Player> get players => List.unmodifiable(_players);
  int get count => _players.length;

    void adicionarPlayer(String name) {
    if (_players.length >= 8) return;
    _players.add(Player(name: name));
    notifyListeners();
  }

    void removerPlayer(int index) {
    if (_players.length <= 4) return;
    _players.removeAt(index);
    notifyListeners();
  }

}
