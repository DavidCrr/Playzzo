import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const Color azulCobalto = Color(0xFF1A4B9F);
const Color azulCeleste = Color(0xFF72BBE0);
const Color brancoPuro = Color(0xFFFFFFFF);
const Color azulMarinho = Color(0xFF0A1B3F);
const Color rosaCoral = Color(0xFFF07A9A);
const Color rosaVibrante = Color(0xFFE84A78);

class MimicaGameScreen extends StatefulWidget {
  final List<String> participantes;
  final String tempoSelecionado;
  final String tema;
  final int pontosParaVencer;

  const MimicaGameScreen({
    Key? key,
    required this.participantes,
    required this.tempoSelecionado,
    required this.tema,
    required this.pontosParaVencer,
  }) : super(key: key);

  @override
  State<MimicaGameScreen> createState() => _MimicaGameScreenState();
}

class _MimicaGameScreenState extends State<MimicaGameScreen> {
  final Random _random = Random();
  final Map<String, int> _pontuacoes = {};

  final Map<String, List<String>> _bancoPalavras = const {
    'Filmes e Séries': [
      'Titanic',
      'Matrix',
      'Harry Potter',
      'O Rei Leão',
      'Jurassic Park',
      'Vingadores',
      'Stranger Things',
      'La Casa de Papel',
      'Toy Story',
      'Homem-Aranha',
    ],
    'Objetos do Dia a Dia': [
      'Escova de Dentes',
      'Guarda-Chuva',
      'Controle Remoto',
      'Chaveiro',
      'Liquidificador',
      'Cadeado',
      'Aspirador de Pó',
      'Fones de Ouvido',
      'Tesoura',
      'Secador de Cabelo',
    ],
    'Ações e Profissões': [
      'Bombeiro Apagando Fogo',
      'Chef Cozinhando',
      'Astronauta',
      'Fotógrafo',
      'Pintor de Parede',
      'Mergulhador',
      'Dentista',
      'DJ na Festa',
      'Malabarista',
      'Surfista',
    ],
    'Animais': [
      'Canguru',
      'Pinguim',
      'Polvo',
      'Camaleão',
      'Gorila',
      'Flamingo',
      'Cobra',
      'Elefante',
      'Caranguejo',
      'Morcego',
    ],
  };

  List<String> _palavrasRestantes = [];
  final List<String> _acertosDaRodada = [];
  String _palavraAtual = '';
  bool _palavraVisivel = false;
  int _indiceJogadorAtual = 0;
  late int _tempoInicialSegundos;
  late int _segundosRestantes;
  Timer? _timer;
  bool _rodando = false;

  int _extrairSegundos(String textoTempo) {
    if (textoTempo.contains('30')) return 30;
    if (textoTempo.contains('90')) return 90;
    return 60;
  }

  List<String> _palavrasDoTema() {
    final lista = _bancoPalavras[widget.tema];
    if (lista != null && lista.isNotEmpty) {
      return List<String>.from(lista);
    }
    return ['Sol', 'Bicicleta', 'Guitarra', 'Relógio', 'Pizza', 'Chuva'];
  }

  void _sortearNovaPalavra() {
    if (_palavrasRestantes.isEmpty) {
      _palavrasRestantes = _palavrasDoTema()..shuffle(_random);
    }
    _palavraAtual = _palavrasRestantes.removeLast();
  }

  void _prepararProximaRodada() {
    _pausarTimer();
    setState(() {
      if (widget.participantes.isNotEmpty) {
        _indiceJogadorAtual =
            (_indiceJogadorAtual + 1) % widget.participantes.length;
      }
      _acertosDaRodada.clear();
      _segundosRestantes = _tempoInicialSegundos;
      _palavraVisivel = false;
      _sortearNovaPalavra();
    });
  }

  void _iniciarTurno() {
    if (_rodando) return;
    setState(() {
      _rodando = true;
      _palavraVisivel = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_segundosRestantes > 1) {
        setState(() {
          _segundosRestantes--;
        });
      } else {
        setState(() {
          _segundosRestantes = 0;
          _rodando = false;
        });
        timer.cancel();
        _finalizarTempoDaRodada();
      }
    });
  }

  void _pausarTimer() {
    _timer?.cancel();
    if (mounted) {
      setState(() {
        _rodando = false;
      });
    }
  }

  void _marcarAcertoContinuo() {
    if (!_rodando) return;
    setState(() {
      _acertosDaRodada.add(_palavraAtual);
      _sortearNovaPalavra();
    });
  }

  void _pularPalavra() {
    if (!_rodando) return;
    setState(() {
      _sortearNovaPalavra();
    });
  }

  void _finalizarTempoDaRodada() {
    if (_acertosDaRodada.isEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: brancoPuro,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Tempo esgotado!',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: azulMarinho,
              ),
            ),
            content: Text(
              'Nenhum acerto nesta rodada. A última palavra era "$_palavraAtual".',
              style: const TextStyle(color: azulMarinho),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _prepararProximaRodada();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: azulCobalto,
                  foregroundColor: brancoPuro,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Próximo Jogador'),
              ),
            ],
          );
        },
      );
      return;
    }

    final mimico = widget.participantes[_indiceJogadorAtual];
    final possiveisAdivinhadores = widget.participantes
        .where((nome) => nome != mimico)
        .toList();

    final Map<int, String?> escolhasPorAcerto = {
      for (int i = 0; i < _acertosDaRodada.length; i++)
        i: possiveisAdivinhadores.isNotEmpty
            ? possiveisAdivinhadores.first
            : null,
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: brancoPuro,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Text(
                'Resumo de $mimico',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: azulMarinho,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Marque quem acertou cada mímica (+1 pt para quem adivinhou e +1 pt para $mimico):',
                        style: TextStyle(
                          fontSize: 13,
                          color: azulMarinho.withOpacity(0.75),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...List.generate(_acertosDaRodada.length, (index) {
                        final palavra = _acertosDaRodada[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                palavra,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: azulMarinho,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: possiveisAdivinhadores.map((nome) {
                                  final selecionado =
                                      escolhasPorAcerto[index] == nome;
                                  return ChoiceChip(
                                    label: Text(
                                      nome,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: selecionado
                                            ? brancoPuro
                                            : azulMarinho,
                                      ),
                                    ),
                                    selected: selecionado,
                                    selectedColor: azulCobalto,
                                    backgroundColor: brancoPuro,
                                    side: BorderSide.none,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    onSelected: (_) {
                                      setDialogState(() {
                                        escolhasPorAcerto[index] = nome;
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _confirmarPontuacaoRodada(mimico, escolhasPorAcerto);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: rosaVibrante,
                      foregroundColor: brancoPuro,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Confirmar Pontos',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmarPontuacaoRodada(
    String mimico,
    Map<int, String?> escolhasPorAcerto,
  ) {
    setState(() {
      for (final adivinhador in escolhasPorAcerto.values) {
        if (adivinhador != null) {
          _pontuacoes[adivinhador] = (_pontuacoes[adivinhador] ?? 0) + 1;
          _pontuacoes[mimico] = (_pontuacoes[mimico] ?? 0) + 1;
        }
      }
    });

    final vencedores = _pontuacoes.entries
        .where((e) => e.value >= widget.pontosParaVencer)
        .toList();

    if (vencedores.isNotEmpty) {
      vencedores.sort((a, b) => b.value.compareTo(a.value));
      final campeao = vencedores.first;
      _mostrarVencedor(campeao.key, campeao.value);
      return;
    }

    _prepararProximaRodada();
  }

  void _mostrarVencedor(String vencedor, int pontos) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: brancoPuro,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Fim de Jogo!',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: azulMarinho,
            ),
          ),
          content: Text(
            '$vencedor atingiu $pontos pontos e venceu a partida!',
            style: const TextStyle(color: azulMarinho),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: rosaVibrante,
                foregroundColor: brancoPuro,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Voltar para Configuração'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    for (final nome in widget.participantes) {
      _pontuacoes[nome] = 0;
    }
    _tempoInicialSegundos = _extrairSegundos(widget.tempoSelecionado);
    _segundosRestantes = _tempoInicialSegundos;
    _palavrasRestantes = _palavrasDoTema()..shuffle(_random);
    _sortearNovaPalavra();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jogadorDaVez = widget.participantes.isNotEmpty
        ? widget.participantes[_indiceJogadorAtual]
        : 'Jogador';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: azulCobalto,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: brancoPuro),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/mask.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(brancoPuro, BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            const Text(
              'Mímica',
              style: TextStyle(
                color: brancoPuro,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: brancoPuro,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: azulCeleste.withOpacity(0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tema: ${widget.tema}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: azulCobalto,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Vez de: $jogadorDaVez',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: azulMarinho,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _segundosRestantes <= 10 && _rodando
                          ? rosaVibrante.withOpacity(0.16)
                          : azulCeleste.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${_segundosRestantes}s',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: _segundosRestantes <= 10 && _rodando
                            ? rosaVibrante
                            : azulMarinho,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: brancoPuro,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: azulCeleste.withOpacity(0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: azulCeleste.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Acertos na rodada: ${_acertosDaRodada.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: azulCobalto,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _palavraVisivel
                          ? 'FAÇA A MÍMICA SEM FALAR'
                          : 'PASSE O CELULAR PARA $jogadorDaVez'.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: azulMarinho.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        _palavraVisivel ? _palavraAtual : '• • • • •',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: azulMarinho,
                        ),
                      ),
                    ),
                    if (!_rodando) ...[
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _iniciarTurno,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text(
                            'Revelar e Iniciar Tempo',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: azulCobalto,
                            foregroundColor: brancoPuro,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: brancoPuro,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: azulCeleste.withOpacity(0.14),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Placar (Meta: ${widget.pontosParaVencer} pts)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: azulMarinho.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: widget.participantes.map((nome) {
                      final pts = _pontuacoes[nome] ?? 0;
                      final ativo = nome == jogadorDaVez;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: ativo
                              ? azulCobalto
                              : azulCeleste.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$nome: $pts',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: ativo ? brancoPuro : azulMarinho,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _rodando ? _pularPalavra : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: azulMarinho,
                        side: BorderSide(
                          color: _rodando
                              ? azulCobalto
                              : azulCobalto.withOpacity(0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Pular',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _rodando ? _marcarAcertoContinuo : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _rodando
                            ? rosaVibrante
                            : rosaCoral.withOpacity(0.45),
                        foregroundColor: brancoPuro,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Acertaram!',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}