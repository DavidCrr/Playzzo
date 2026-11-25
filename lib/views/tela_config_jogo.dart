import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tela_jogo_mimica.dart';

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

  final List<int> _opcoesRodadas = const [5, 10, 15, 20];

  late String _tempoSelecionado;
  late int _limiteRodadas;

  List _temasBanco = [];
  int? _temaIdSelecionado;
  String _temaNomeSelecionado = '';
  bool _carregandoTemas = true;
  String? _erroTemas;

  bool get _usaTempo => widget.gameTitle != 'O Impostor';

  bool get _usaLimiteRodadas =>
      widget.gameTitle == 'Mímica' || widget.gameTitle == 'Quem Sou Eu?';

  int get _minimoJogadores {
    switch (widget.gameTitle) {
      case 'Bomba Relógio':
        return 4;
      default:
        return 3;
    }
  }

  bool get _podeIniciar =>
      _participantes.length >= _minimoJogadores &&
      !_carregandoTemas &&
      _temasBanco.isNotEmpty &&
      _temaNomeSelecionado.isNotEmpty;

  int? _converterParaInt(dynamic valor) {
    if (valor == null) return null;
    if (valor is int) return valor;
    return int.tryParse(valor.toString());
  }

  String _codigoEsperadoJogo() {
    switch (widget.gameTitle) {
      case 'Mímica':
        return 'MIMICA';
      case 'Quem Sou Eu?':
        return 'QUEM_SOU_EU';
      case 'O Impostor':
        return 'IMPOSTOR';
      case 'Bomba Relógio':
        return 'BOMBA_RELOGIO';
      default:
        return widget.gameTitle.toUpperCase();
    }
  }

  Future<void> _carregarTemasDoBanco() async {
    setState(() {
      _carregandoTemas = true;
      _erroTemas = null;
    });

    try {
      final client = Supabase.instance.client;
      final codigoAlvo = _codigoEsperadoJogo();

      final jogosRes = await client
          .from('jogo')
          .select('id, codigo, nome')
          .eq('ativo', true);

      final jogos = jogosRes as List;
      int? jogoIdEncontrado;

      for (final rawJogo in jogos) {
        final jogo = rawJogo as Map;
        final codigo = (jogo['codigo'] ?? '').toString().trim().toUpperCase();
        final nome = (jogo['nome'] ?? '').toString().trim().toLowerCase();
        if (codigo == codigoAlvo ||
            codigo == 'MÍMICA' && codigoAlvo == 'MIMICA' ||
            nome.contains(widget.gameTitle.toLowerCase())) {
          jogoIdEncontrado = _converterParaInt(jogo['id']);
          break;
        }
      }

      var queryTemas = client
          .from('tema')
          .select('id, nome_tema, jogo_id')
          .eq('ativo', true);

      if (jogoIdEncontrado != null) {
        queryTemas = queryTemas.eq('jogo_id', jogoIdEncontrado);
      }

      final temasRes = await queryTemas.order('nome_tema', ascending: true);
      final rawTemas = temasRes as List;
      final temasCarregados = [];

      for (final rawTema in rawTemas) {
        final item = rawTema as Map;
        final id = _converterParaInt(item['id']);
        final nome = (item['nome_tema'] ?? '').toString().trim();
        if (id != null && nome.isNotEmpty) {
          temasCarregados.add({
            'id': id,
            'nome_tema': nome,
          });
        }
      }

      if (!mounted) return;

      setState(() {
        _temasBanco = temasCarregados;
        if (_temasBanco.isNotEmpty) {
          final primeiro = _temasBanco.first as Map;
          _temaIdSelecionado = _converterParaInt(primeiro['id']);
          _temaNomeSelecionado = primeiro['nome_tema'].toString();
        } else {
          _temaIdSelecionado = null;
          _temaNomeSelecionado = '';
          _erroTemas =
              'Nenhum tema cadastrado no banco para ${widget.gameTitle}.';
        }
        _carregandoTemas = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _temasBanco = [];
        _temaIdSelecionado = null;
        _temaNomeSelecionado = '';
        _erroTemas = 'Erro ao carregar temas do banco: $e';
        _carregandoTemas = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tempoSelecionado = _opcoesTempo[1];
    _limiteRodadas = _opcoesRodadas[1];
    _carregarTemasDoBanco();
  }

  Widget _buildGameIcon() {
    switch (widget.gameTitle) {
      case 'Mímica':
        return SvgPicture.asset(
          'assets/icons/mask.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(brancoPuro, BlendMode.srcIn),
        );
      case 'Quem Sou Eu?':
        return SvgPicture.asset(
          'assets/icons/face.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(brancoPuro, BlendMode.srcIn),
        );
      case 'O Impostor':
        return SvgPicture.asset(
          'assets/icons/spy.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(brancoPuro, BlendMode.srcIn),
        );
      case 'Bomba Relógio':
        return SvgPicture.asset(
          'assets/icons/bomb.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(brancoPuro, BlendMode.srcIn),
        );
      default:
        return const Icon(Icons.sports_esports, color: brancoPuro, size: 24);
    }
  }

  String _textoRegrasJogo() {
    switch (widget.gameTitle) {
      case 'Mímica':
        return '• Quem estiver com o celular faz gestos sem falar nada.\n'
            '• Se acertarem a palavra, quem fez a mímica ganha +1 ponto.\n'
            '• A partida encerra ao atingir o limite de rodadas.';
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
      final msg = _temasBanco.isEmpty
          ? 'Aguarde ou verifique os temas cadastrados no banco para ${widget.gameTitle}.'
          : 'Adicione pelo menos $_minimoJogadores participantes para ${widget.gameTitle}.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: azulMarinho,
        ),
      );
      return;
    }

    switch (widget.gameTitle) {
      case 'Mímica':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MimicaGameScreen(
              participantes: List.from(_participantes),
              tempoSelecionado: _tempoSelecionado,
              tema: _temaNomeSelecionado,
              temaId: _temaIdSelecionado,
              limiteRodadas: _limiteRodadas,
            ),
          ),
        );
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
            _buildGameIcon(),
            const SizedBox(width: 8),
            Text(
              widget.gameTitle,
              style: const TextStyle(
                color: brancoPuro,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
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
                if (_usaLimiteRodadas) ...[
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
                          'Limite de Rodadas',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: azulMarinho,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          value: _limiteRodadas,
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
                          items: _opcoesRodadas.map((rodadas) {
                            return DropdownMenuItem<int>(
                              value: rodadas,
                              child: Text('$rodadas rodadas'),
                            );
                          }).toList(),
                          onChanged: (novasRodadas) {
                            if (novasRodadas != null) {
                              setState(() {
                                _limiteRodadas = novasRodadas;
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
                      if (_carregandoTemas)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: LinearProgressIndicator(color: azulCobalto),
                        )
                      else if (_temasBanco.isEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _erroTemas ??
                                  'Nenhum tema disponível no banco.',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: rosaVibrante,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextButton.icon(
                              onPressed: _carregarTemasDoBanco,
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: const Text('Recarregar temas'),
                            ),
                          ],
                        )
                      else
                        DropdownButtonFormField<int>(
                          value: _temaIdSelecionado,
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
                          items: _temasBanco.map((rawItem) {
                            final tema = rawItem as Map;
                            final id = _converterParaInt(tema['id']) ?? 0;
                            final nome = tema['nome_tema'].toString();
                            return DropdownMenuItem<int>(
                              value: id,
                              child: Text(nome),
                            );
                          }).toList(),
                          onChanged: (novoId) {
                            if (novoId == null) return;
                            final rawEscolhido = _temasBanco.firstWhere(
                              (rawT) =>
                                  _converterParaInt((rawT as Map)['id']) ==
                                  novoId,
                              orElse: () => _temasBanco.first,
                            );
                            final escolhido = rawEscolhido as Map;
                            setState(() {
                              _temaIdSelecionado =
                                  _converterParaInt(escolhido['id']);
                              _temaNomeSelecionado =
                                  escolhido['nome_tema'].toString();
                            });
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