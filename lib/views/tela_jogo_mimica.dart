import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final int? temaId;
  final int limiteRodadas;

  const MimicaGameScreen({
    Key? key,
    required this.participantes,
    required this.tempoSelecionado,
    required this.tema,
    this.temaId,
    this.limiteRodadas = 10,
  }) : super(key: key);

  @override
  State<MimicaGameScreen> createState() => _MimicaGameScreenState();
}

class _MimicaGameScreenState extends State<MimicaGameScreen> {
  final Random _random = Random();
  final Map<String, int> _pontuacoes = {};

  List _palavrasDoTema = [];
  List _palavrasRestantes = [];
  int? _temaIdAtivo;
  String _temaAtivo = '';
  int? _palavraAtualId;
  String _palavraAtual = '';
  String? _mensagemErroBanco;
  bool _carregandoDados = true;
  bool _palavraVisivel = false;
  int _rodadaAtual = 1;
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

  int? _converterParaInt(dynamic valor) {
    if (valor == null) return null;
    if (valor is int) return valor;
    return int.tryParse(valor.toString());
  }

  Future<int?> _buscarJogoMimicaId(SupabaseClient client) async {
    final jogosRes = await client
        .from('jogo')
        .select('id, codigo, nome')
        .eq('ativo', true);

    final jogos = jogosRes as List;

    for (final rawJogo in jogos) {
      final jogo = rawJogo as Map;
      final codigo = (jogo['codigo'] ?? '').toString().trim().toUpperCase();
      final nome = (jogo['nome'] ?? '').toString().trim().toLowerCase();
      if (codigo == 'MIMICA' ||
          codigo == 'MÍMICA' ||
          nome.contains('mimica') ||
          nome.contains('mímica')) {
        return _converterParaInt(jogo['id']);
      }
    }

    return null;
  }

  Future<void> _carregarTemaEPalavrasDoBanco() async {
    try {
      final client = Supabase.instance.client;
      int? temaIdResolvido = widget.temaId;
      String nomeTemaResolvido =
          widget.tema.trim().isNotEmpty ? widget.tema.trim() : 'Geral';

      if (temaIdResolvido == null) {
        final jogoMimicaId = await _buscarJogoMimicaId(client);
        var queryTemas = client
            .from('tema')
            .select('id, jogo_id, nome_tema')
            .eq('ativo', true);

        if (jogoMimicaId != null) {
          queryTemas = queryTemas.eq('jogo_id', jogoMimicaId);
        }

        final temasRes = await queryTemas;
        final temas = temasRes as List;

        Map? temaEncontrado;
        if (widget.tema.trim().isNotEmpty) {
          for (final rawT in temas) {
            final t = rawT as Map;
            final nomeTema = (t['nome_tema'] ?? '').toString().trim();
            if (nomeTema.toLowerCase() == widget.tema.trim().toLowerCase()) {
              temaEncontrado = t;
              break;
            }
          }
        }

        temaEncontrado ??= temas.isNotEmpty ? temas.first as Map : null;

        if (temaEncontrado != null) {
          temaIdResolvido = _converterParaInt(temaEncontrado['id']);
          nomeTemaResolvido =
              (temaEncontrado['nome_tema'] ?? nomeTemaResolvido).toString();
        }
      }

      _temaIdAtivo = temaIdResolvido;
      _temaAtivo = nomeTemaResolvido;

      if (_temaIdAtivo == null) {
        _mensagemErroBanco = 'Nenhum tema encontrado no banco para Mímica.';
      } else {
        final palavrasRes = await client
            .from('palavra')
            .select('id, texto_palavra')
            .eq('tema_id', _temaIdAtivo!)
            .eq('ativo', true);

        final rawPalavras = palavrasRes as List;
        final filtradas = [];

        for (final rawP in rawPalavras) {
          final p = rawP as Map;
          final texto = (p['texto_palavra'] ?? '').toString().trim();
          if (texto.isNotEmpty) {
            filtradas.add({
              'id': _converterParaInt(p['id']),
              'texto_palavra': texto,
            });
          }
        }

        _palavrasDoTema = filtradas;

        if (_palavrasDoTema.isEmpty) {
          _mensagemErroBanco =
              'Nenhuma palavra ativa encontrada no banco para o tema "$_temaAtivo".';
        }
      }
    } catch (e) {
      _mensagemErroBanco = 'Erro ao buscar dados no Supabase: $e';
    }

    if (_palavrasDoTema.isNotEmpty) {
      _palavrasRestantes = List.from(_palavrasDoTema)..shuffle(_random);
      _sortearNovaPalavra();
    }

    if (mounted) {
      setState(() {
        _carregandoDados = false;
      });
    }
  }

  void _sortearNovaPalavra() {
    if (_palavrasDoTema.isEmpty) {
      _palavraAtualId = null;
      _palavraAtual = '';
      return;
    }

    if (_palavrasRestantes.isEmpty) {
      _palavrasRestantes = List.from(_palavrasDoTema)..shuffle(_random);
    }

    final palavraAnteriorId = _palavraAtualId;
    var escolhida = _palavrasRestantes.removeLast() as Map;

    if (escolhida['id'] == palavraAnteriorId && _palavrasRestantes.isNotEmpty) {
      final alternativa = _palavrasRestantes.removeLast() as Map;
      _palavrasRestantes.add(escolhida);
      escolhida = alternativa;
    }

    _palavraAtualId = _converterParaInt(escolhida['id']);
    _palavraAtual = (escolhida['texto_palavra'] ?? '').toString();
  }

  void _iniciarTurno() {
    if (_rodando || _carregandoDados || _palavraAtual.isEmpty) return;
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
        _encerrarRodada(acertou: false, tempoEsgotado: true);
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

  void _pularPalavra() {
    if (!_rodando) return;
    setState(() {
      _sortearNovaPalavra();
    });
  }

  void _encerrarRodada({
    required bool acertou,
    bool tempoEsgotado = false,
  }) {
    _pausarTimer();

    final mimico = widget.participantes.isNotEmpty
        ? widget.participantes[_indiceJogadorAtual]
        : 'Jogador';

    if (acertou && widget.participantes.isNotEmpty) {
      setState(() {
        _pontuacoes[mimico] = (_pontuacoes[mimico] ?? 0) + 1;
      });
    }

    final atingiuLimiteRodadas = _rodadaAtual >= widget.limiteRodadas;

    final mensagem = acertou
        ? '$mimico marcou +1 ponto com a palavra "$_palavraAtual".'
        : tempoEsgotado
            ? 'O tempo acabou! A palavra era "$_palavraAtual".'
            : 'Rodada encerrada para $mimico.';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: brancoPuro,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            acertou
                ? 'Ponto da Mímica!'
                : tempoEsgotado
                    ? 'Tempo Esgotado'
                    : 'Fim da Rodada',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: azulMarinho,
            ),
          ),
          content: Text(
            mensagem,
            style: const TextStyle(color: azulMarinho),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (atingiuLimiteRodadas) {
                  _mostrarResultadoFinal();
                } else {
                  _prepararProximaRodada();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    atingiuLimiteRodadas ? rosaVibrante : azulCobalto,
                foregroundColor: brancoPuro,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                atingiuLimiteRodadas ? 'Ver Placar Final' : 'Próxima Rodada',
              ),
            ),
          ],
        );
      },
    );
  }

  void _prepararProximaRodada() {
    setState(() {
      _rodadaAtual++;
      if (widget.participantes.isNotEmpty) {
        _indiceJogadorAtual =
            (_indiceJogadorAtual + 1) % widget.participantes.length;
      }
      _segundosRestantes = _tempoInicialSegundos;
      _palavraVisivel = false;
      _sortearNovaPalavra();
    });
  }

  void _mostrarResultadoFinal() {
    final ranking = _pontuacoes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final resumo = ranking.isEmpty
        ? 'Partida encerrada.'
        : ranking
            .asMap()
            .entries
            .map((e) => '${e.key + 1}º ${e.value.key}: ${e.value.value} pts')
            .join('\n');

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
            'Fim da Partida!',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: azulMarinho,
            ),
          ),
          content: Text(
            resumo,
            style: const TextStyle(
              color: azulMarinho,
              height: 1.5,
              fontWeight: FontWeight.w700,
            ),
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
    _temaAtivo = widget.tema;
    _temaIdAtivo = widget.temaId;
    _carregarTemaEPalavrasDoBanco();
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
      body: _carregandoDados
          ? const Center(
              child: CircularProgressIndicator(color: azulCobalto),
            )
          : _mensagemErroBanco != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: brancoPuro,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _mensagemErroBanco!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: azulMarinho,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _carregandoDados = true;
                                _mensagemErroBanco = null;
                              });
                              _carregarTemaEPalavrasDoBanco();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: azulCobalto,
                              foregroundColor: brancoPuro,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Tentar Novamente'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
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
                                    'Rodada $_rodadaAtual de ${widget.limiteRodadas} • $_temaAtivo',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
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
                              Text(
                                _palavraVisivel
                                    ? 'FAÇA A MÍMICA SEM FALAR'
                                    : 'PASSE O CELULAR PARA $jogadorDaVez'
                                        .toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                  color: azulMarinho.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 16),
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
                                  _palavraVisivel
                                      ? _palavraAtual
                                      : '• • • • •',
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
                              'Placar (${widget.limiteRodadas} rodadas)',
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
                                onPressed: _rodando
                                    ? () => _encerrarRodada(acertou: true)
                                    : null,
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