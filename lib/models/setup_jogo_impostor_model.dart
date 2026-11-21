import 'package:flutter/foundation.dart';


class Player {
  final String name;
  final bool isHost;
  Player({required this.name, this.isHost = false});
}


class SetupState with ChangeNotifier {
  
  final List<Player> _players = [
    Player(name: 'Ana Julia', isHost: true),
    Player(name: 'Marcos PP'),
    Player(name: 'Marcos V.'),
    Player(name: 'David'),
    Player(name: 'Paulo'),
  ];

  final List<String> _themes = ['Objetos', 'Lugares', 'Profissões'];
  String _selectedTheme = 'Objetos';

  final List<int> _roundOptions = [3, 5, 7, 10];
  int _selectedRounds = 5;

  bool _challengeEnabled = true;
  String _penalty =
      'O perdedor paga a rodada de pizza e a coca lava a louça da festa! 🍕';

 
  List<Player> get jogadores => List.unmodifiable(_players);
  int get jogadorCount => _players.length;

  List<String> get temas => List.unmodifiable(_themes);
  String get temaSelecionado => _selectedTheme;

  List<int> get opcoesRodada => List.unmodifiable(_roundOptions);
  int get rodadasSelecionadas => _selectedRounds;

  bool get desafioAtivo => _challengeEnabled;
  String get penalidade => _penalty;

 
  void adicionarJogador(String nome) {
    if (_players.length >= 8) return;
    _players.add(Player(name: nome));
    notifyListeners();
  }

  void removerJogador() {
    // remove o último (não o anfitrião) quando houver mais de 4 jogadores
    if (_players.length > 4) {
      _players.removeLast();
      notifyListeners();
    }
  }

  void selecionarTema(String tema) {
    if (_themes.contains(tema)) {
      _selectedTheme = tema;
      notifyListeners();
    }
  }

  void selecionarRodadas(int quantidade) {
    if (_roundOptions.contains(quantidade)) {
      _selectedRounds = quantidade;
      notifyListeners();
    }
  }

  void alternarDesafio() {
    _challengeEnabled = !_challengeEnabled;
    notifyListeners();
  }

  void alterarPenalidade(String texto) {
    _penalty = texto;
    notifyListeners();
  }
}
