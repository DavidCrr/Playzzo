import 'package:flutter/material.dart';
import 'package:playzzo/widgets/playzzo_app_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

const Color azulCobalto = Color(0xFF1A4B9F);
const Color azulCeleste = Color(0xFF72BBE0);
const Color brancoPuro = Color(0xFFFFFFFF);
const Color azulMarinho = Color(0xFF0A1B3F);
const Color rosaCoral = Color(0xFFF07A9A);
const Color rosaVibrante = Color(0xFFE84A78);

class GameConfigScreen extends StatefulWidget {
  final String gameTitle;

  const GameConfigScreen({
    Key? key,
    required this.gameTitle,
  }) : super(key: key);

  @override
  State<GameConfigScreen> createState() => _GameConfigScreenState();
}

class _GameConfigScreenState extends State<GameConfigScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final List<String> _participantes = [];

  final List<String> _opcoesTempo = const [
    'Rápido - 30 seg',
    'Médio - 60 seg',
    'Longo - 90 seg',
  ];

  final List<int> _opcoesPontos = const [5, 10, 15, 20];

  late String _tempoSelecionado;
  late String _temaSelecionado;
  late int _pontosParaVencer;

  bool get _usaTempo => widget.gameTitle != 'O Impostor';

  bool get _usaPontosVitoria =>
      widget.gameTitle == 'Mímica' || widget.gameTitle == 'Quem Sou Eu?';

  int get _minimoJogadores {
    switch (widget.gameTitle) {
      case 'Bomba Relógio':
        return 4;
      default:
        return 3;
    }
  }

  bool get _podeIniciar => _participantes.length >= _minimoJogadores;

  List<String> _opcoesTemasPorJogo() {
    switch (widget.gameTitle) {
      case 'Mímica':
        return const [
          'Filmes e Séries',
          'Objetos do Dia a Dia',
          'Ações e Profissões',
          'Animais',
        ];
      case 'Quem Sou Eu?':
        return const [
          'Personagens Famosos',
          'Comidas e Bebidas',
          'Lugares do Mundo',
          'Heróis e Vilões',
        ];
      case 'Bomba Relógio':
        return const [
          'Palavras com Letra Sorteada',
          'Coisas que Cabem na Mochila',
          'Marcas e Jogos',
          'Fatos do Cotidiano',
        ];
      case 'O Impostor':
        return const [
          'Cenários e Lugares',
          'Comidas Típicas',
          'Objetos de Festa',
          'Esportes e Lazer',
        ];
      default:
        return const ['Geral'];
    }
  }

  @override
  void initState() {
    super.initState();
    _tempoSelecionado = _opcoesTempo[1];
    _pontosParaVencer = _opcoesPontos[1];
    final temas = _opcoesTemasPorJogo();
    _temaSelecionado = temas.first;
  }

  Widget _buildGameIcon() {
    switch (widget.gameTitle) {
      case 'Mímica':
        return SvgPicture.asset(
          'assets/icons/mask.svg',
          width: 33,
          height: 33,
          colorFilter: const ColorFilter.mode(azulCobalto, BlendMode.srcIn),
        );
      case 'Quem Sou Eu?':
        return SvgPicture.asset(
          'assets/icons/face.svg',
          width: 33,
          height: 33,
          colorFilter: const ColorFilter.mode(azulCobalto, BlendMode.srcIn),
        );
      case 'O Impostor':
        return SvgPicture.asset(
          'assets/icons/spy.svg',
          width: 33,
          height: 33,
          colorFilter: const ColorFilter.mode(azulCobalto, BlendMode.srcIn),
        );
      case 'Bomba Relógio':
        return SvgPicture.asset(
          'assets/icons/bomb.svg',
          width: 33,
          height: 33,
          colorFilter: const ColorFilter.mode(azulCobalto, BlendMode.srcIn),
        );
      default:
        return const Icon(Icons.sports_esports, color: azulCobalto, size: 33);
    }
  }

  String _textoRegrasJogo() {
    switch (widget.gameTitle) {
      case 'Mímica':
        return '• Quem estiver com o celular faz gestos sem falar nada.\n'
            '• A galera tenta adivinhar antes do tempo acabar.';
      case 'Quem Sou Eu?':
        return '• O jogador adivinha quem ou o que é com base nas dicas da roda.\n'
            '• Responda apenas sim, não ou às vezes quando perguntado.';
      case 'O Impostor':
        return '• Todos recebem a palavra secreta, menos o impostor.\n'
            '• Conversem, deem dicas e votem em quem parece não saber a palavra.';
      case 'Bomba Relógio':
        return '• Responda ao tema da rodada e passe o aparelho para o próximo.\n'
            '• Quem estiver com o celular quando o tempo estourar perde a rodada.';
      default:
        return '• Todos jogam no mesmo aparelho, passando a vez a cada rodada.';
    }
  }

  void _abrirRegrasJogo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: brancoPuro,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Regras • ${widget.gameTitle}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: azulMarinho,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _textoRegrasJogo(),
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: azulMarinho,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _adicionarParticipante() {
    final nome = _nomeController.text.trim();
    if (nome.isEmpty) return;

    final jaExiste = _participantes.any(
      (item) => item.toLowerCase() == nome.toLowerCase(),
    );

    if (jaExiste) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esse nome já foi adicionado à partida.'),
          backgroundColor: azulMarinho,
        ),
      );
      return;
    }

    setState(() {
      _participantes.add(nome);
      _nomeController.clear();
    });
  }

  void _removerParticipante(int index) {
    setState(() {
      _participantes.removeAt(index);
    });
  }

  void _iniciarJogo() {
    if (!_podeIniciar) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Adicione pelo menos $_minimoJogadores participantes para ${widget.gameTitle}.',
          ),
          backgroundColor: azulMarinho,
        ),
      );
      return;
    }

    switch (widget.gameTitle) {
      case 'Mímica':
        break;
      case 'Quem Sou Eu?':
        break;
      case 'O Impostor':
        break;
      case 'Bomba Relógio':
        break;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final temasDisponiveis = _opcoesTemasPorJogo();
    final valorTemaAtual = temasDisponiveis.contains(_temaSelecionado)
        ? _temaSelecionado
        : temasDisponiveis.first;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: PlayzzoAppBar(titulo: widget.gameTitle, icone: _buildGameIcon()),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Configurações da Partida',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: azulMarinho,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _abrirRegrasJogo,
                      icon: const Icon(
                        Icons.menu_book_rounded,
                        size: 16,
                        color: azulCobalto,
                      ),
                      label: const Text(
                        'Regras',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: azulCobalto,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: azulCeleste.withOpacity(0.16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_usaTempo) ...[
                  Container(
                    padding: const EdgeInsets.all(18.0),
                    decoration: BoxDecoration(
                      color: brancoPuro,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: azulCeleste.withOpacity(0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Duração da Rodada',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: azulMarinho,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _tempoSelecionado,
                          dropdownColor: brancoPuro,
                          borderRadius: BorderRadius.circular(16),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF5F7FA),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: azulMarinho,
                          ),
                          items: _opcoesTempo.map((opcao) {
                            return DropdownMenuItem<String>(
                              value: opcao,
                              child: Text(opcao),
                            );
                          }).toList(),
                          onChanged: (novoValor) {
                            if (novoValor != null) {
                              setState(() {
                                _tempoSelecionado = novoValor;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_usaPontosVitoria) ...[
                  Container(
                    padding: const EdgeInsets.all(18.0),
                    decoration: BoxDecoration(
                      color: brancoPuro,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: azulCeleste.withOpacity(0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pontos para Vencer',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: azulMarinho,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          value: _pontosParaVencer,
                          dropdownColor: brancoPuro,
                          borderRadius: BorderRadius.circular(16),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF5F7FA),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: azulMarinho,
                          ),
                          items: _opcoesPontos.map((pontos) {
                            return DropdownMenuItem<int>(
                              value: pontos,
                              child: Text('$pontos pontos'),
                            );
                          }).toList(),
                          onChanged: (novosPontos) {
                            if (novosPontos != null) {
                              setState(() {
                                _pontosParaVencer = novosPontos;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Container(
                  padding: const EdgeInsets.all(18.0),
                  decoration: BoxDecoration(
                    color: brancoPuro,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: azulCeleste.withOpacity(0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tema da Partida',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: azulMarinho,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: valorTemaAtual,
                        dropdownColor: brancoPuro,
                        borderRadius: BorderRadius.circular(16),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF5F7FA),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: azulMarinho,
                        ),
                        items: temasDisponiveis.map((tema) {
                          return DropdownMenuItem<String>(
                            value: tema,
                            child: Text(tema),
                          );
                        }).toList(),
                        onChanged: (novoTema) {
                          if (novoTema != null) {
                            setState(() {
                              _temaSelecionado = novoTema;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18.0),
                  decoration: BoxDecoration(
                    color: brancoPuro,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: azulCeleste.withOpacity(0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Adicionar Participantes',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: azulMarinho,
                            ),
                          ),
                          Text(
                            'Mín. $_minimoJogadores',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: azulMarinho.withOpacity(0.65),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nomeController,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _adicionarParticipante(),
                              decoration: InputDecoration(
                                hintText: 'Digite um nome',
                                hintStyle: TextStyle(
                                  color: azulMarinho.withOpacity(0.45),
                                  fontSize: 14,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF5F7FA),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              onPressed: _adicionarParticipante,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: azulCobalto,
                                foregroundColor: brancoPuro,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Icon(Icons.add_rounded),
                            ),
                          ),
                        ],
                      ),
                      if (_participantes.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(_participantes.length, (index) {
                            return Chip(
                              label: Text(
                                _participantes[index],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: azulMarinho,
                                ),
                              ),
                              backgroundColor: azulCeleste.withOpacity(0.18),
                              deleteIconColor: azulCobalto,
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onDeleted: () => _removerParticipante(index),
                            );
                          }),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _iniciarJogo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _podeIniciar
                      ? rosaVibrante
                      : rosaCoral.withOpacity(0.45),
                  foregroundColor: brancoPuro,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Iniciar Jogo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}