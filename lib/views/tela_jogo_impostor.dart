import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/resultado_jogo.dart';
import '../models/setup_jogo_impostor_model.dart';
import 'tela_ranking.dart';

const Color _azulPrimario = Color(0xFF1A4B9F);
const Color _azulEscuro = Color(0xFF0A1B3F);
const Color _fundoCampo = Color(0xFFF0F7FB);
const Color _fundoConfidencial = Color(0xFF283044);
const Color _rosa = Color(0xFFF07A9A);
const Color _verde = Color(0xFF2E7D32);
const Color _borda = Color(0xFFE2EDF5);
const Color _azulClaro = Color(0xFF72BBE0);
const Color _cinzaTexto = Color(0xFF434652);

enum FaseJogo {
  distribuicao, // Passe de mão em mão para ver papéis
  discussao, // Debate presencial na mesa
  votacao, // Escolha de quem é o impostor e encerramento
}

/// Tela de Gameplay Oficial do jogo **Impostor** (Passe & Jogue).
class TelaJogoImpostor extends StatefulWidget {
  const TelaJogoImpostor({super.key});

  @override
  State<TelaJogoImpostor> createState() => _TelaJogoImpostorState();
}

class _TelaJogoImpostorState extends State<TelaJogoImpostor> {
  FaseJogo _faseAtual = FaseJogo.distribuicao;

  int _indiceJogadorAtual = 0;
  int _indiceImpostor = 0;
  String _palavraSecreta = '';
  bool _identidadeRevelada = false;

  // Variáveis da fase de votação
  int? _jogadorAcusadoIndex;
  bool _votacaoFinalizada = false;

  // Variáveis do sorteio de quem começa as pistas (Fase 2)
  int _indiceQuemComeca = 0;
  bool _sorteioEmAndamento = false;
  bool _sorteioFinalizado = false;
  int _indiceAnimacaoSorteio = 0;

  // Banco de palavras local por tema (com fallback resiliente até plugar no Supabase)
  final Map<String, List<String>> _bancoPalavras = {
    'Objetos': ['Bicicleta', 'Celular', 'Relógio', 'Câmera', 'Guitarra', 'Óculos', 'Mochila', 'Guarda-chuva'],
    'Lugares': ['Praia', 'Cinema', 'Hospital', 'Aeroporto', 'Estádio', 'Biblioteca', 'Museu', 'Parque'],
    'Profissões': ['Médico', 'Bombeiro', 'Astronauta', 'Professor', 'Cozinheiro', 'Policial', 'Pintor', 'Advogado'],
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _iniciarPartida());
  }

  void _iniciarPartida() {
    final setup = Provider.of<SetupState>(context, listen: false);
    final listaJogadores = setup.jogadores;

    // 1. Sorteia aleatoriamente quem será o Impostor
    final random = Random();
    _indiceImpostor = random.nextInt(listaJogadores.isNotEmpty ? listaJogadores.length : 1);

    // 2. Sorteia a palavra secreta com base no tema escolhido
    final palavrasDoTema = _bancoPalavras[setup.temaSelecionado] ?? _bancoPalavras['Objetos']!;
    _palavraSecreta = palavrasDoTema[random.nextInt(palavrasDoTema.length)];

    // 3. Sorteia quem começa as pistas (nunca o impostor)
    final candidatos = List.generate(listaJogadores.length, (i) => i)
        .where((i) => i != _indiceImpostor)
        .toList()
      ..shuffle(random);
    _indiceQuemComeca = candidatos.isNotEmpty ? candidatos.first : 0;

    setState(() {
      _indiceJogadorAtual = 0;
      _identidadeRevelada = false;
      _faseAtual = FaseJogo.distribuicao;
      _jogadorAcusadoIndex = null;
      _votacaoFinalizada = false;
      _sorteioEmAndamento = false;
      _sorteioFinalizado = false;
      _indiceAnimacaoSorteio = 0;
    });
  }

  bool get _jogadorAtualEImpostor => _indiceJogadorAtual == _indiceImpostor;

  void _proximoJogador(int totalJogadores) {
    if (_identidadeRevelada) {
      // Segurança: oculta antes de passar
      setState(() => _identidadeRevelada = false);
      return;
    }

    if (_indiceJogadorAtual < totalJogadores - 1) {
      setState(() {
        _indiceJogadorAtual++;
        _identidadeRevelada = false;
      });
    } else {
      // Todos já viram suas identidades! Avança para o debate
      setState(() {
        _faseAtual = FaseJogo.discussao;
        _identidadeRevelada = false;
      });
    }
  }

  void _concluirVotacaoEExibirRanking(SetupState setup) {
    final listaJogadores = setup.jogadores;
    final bool acertaramOImpostor = _jogadorAcusadoIndex == _indiceImpostor;
    final impostor = listaJogadores[_indiceImpostor];

    // Calcula pontuações da rodada
    final List<JogadorPontuacao> rankingFinal = [];

    for (int i = 0; i < listaJogadores.length; i++) {
      final p = listaJogadores[i];
      if (i == _indiceImpostor) {
        // Pontuação do impostor
        final pontos = acertaramOImpostor ? 0 : 300;
        final detalhe = acertaramOImpostor ? 'Impostor (Descoberto)' : 'Impostor (Enganou a mesa!)';
        rankingFinal.add(JogadorPontuacao(
          nome: p.name,
          pontos: pontos,
          detalhe: detalhe,
          destaqueVencedor: !acertaramOImpostor,
        ));
      } else {
        // Pontuação dos jogadores
        final pontos = acertaramOImpostor ? 150 : 50;
        final detalhe = acertaramOImpostor ? 'Jogador(a) (Venceu)' : 'Jogador(a) (Enganado)';
        rankingFinal.add(JogadorPontuacao(
          nome: p.name,
          pontos: pontos,
          detalhe: detalhe,
          destaqueVencedor: acertaramOImpostor,
        ));
      }
    }

    // Navega para a Tela de Ranking reutilizável
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TelaRanking(
          resultado: ResultadoPartida(
            nomeJogo: 'Impostor',
            prenda: setup.desafioAtivo ? setup.penalidade : null,
            nomePerdedorPrenda: acertaramOImpostor ? impostor.name : 'Mesa',
            ranking: rankingFinal,
            onJogarNovamente: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const TelaJogoImpostor()),
              );
            },
            onVoltarMenu: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final setup = Provider.of<SetupState>(context);
    final listaJogadores = setup.jogadores;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _azulEscuro),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.theater_comedy, color: _azulPrimario, size: 26),
            const SizedBox(width: 8),
            Text(
              'IMPOSTOR',
              style: const TextStyle(
                color: _azulPrimario,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: _azulEscuro),
            onPressed: _exibirAjuda,
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _construirCorpoFase(setup, listaJogadores),
        ),
      ),
    );
  }

  Widget _construirCorpoFase(SetupState setup, List<Player> listaJogadores) {
    switch (_faseAtual) {
      case FaseJogo.distribuicao:
        return _telaDistribuicao(setup, listaJogadores);
      case FaseJogo.discussao:
        return _telaDiscussao(setup, listaJogadores);
      case FaseJogo.votacao:
        return _telaVotacao(setup, listaJogadores);
    }
  }

  // =========================================================================
  // FASE 1: DISTRIBUIÇÃO SECRETA (Passe & Jogue)
  // =========================================================================
  Widget _telaDistribuicao(SetupState setup, List<Player> listaJogadores) {
    if (listaJogadores.isEmpty) return const SizedBox();

    final jogadorAtual = listaJogadores[_indiceJogadorAtual];
    final total = listaJogadores.length;
    final bool eOUltimo = _indiceJogadorAtual == total - 1;
    final proximoNome = !eOUltimo ? listaJogadores[_indiceJogadorAtual + 1].name : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---------------------------------------------
          // Barra de progresso segmentada
          // ---------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _fundoCampo,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _azulClaro),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock, size: 14, color: _azulPrimario),
                    SizedBox(width: 4),
                    Text(
                      'Distribuição Secreta',
                      style: TextStyle(
                        fontSize: 11,
                        color: _azulPrimario,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Jogador ${_indiceJogadorAtual + 1} de $total',
                style: const TextStyle(
                  color: _azulEscuro,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Barrinhas segmentadas
          Row(
            children: List.generate(total, (index) {
              final preenchido = index <= _indiceJogadorAtual;
              return Expanded(
                child: Container(
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: preenchido ? _azulPrimario : const Color(0xFFE2EDF5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 24),

          // ---------------------------------------------
          // CARD CENTRAL DE TROCA OU REVELAÇÃO
          // ---------------------------------------------
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _identidadeRevelada
                ? _cardConfidencialRevelado(jogadorAtual)
                : _cardPasseCelular(jogadorAtual),
          ),

          const SizedBox(height: 24),

          // ---------------------------------------------
          // BOTÃO DE AVANÇAR
          // ---------------------------------------------
          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _identidadeRevelada
                  ? () => setState(() => _identidadeRevelada = false)
                  : () => _proximoJogador(total),
              style: ElevatedButton.styleFrom(
                backgroundColor: _identidadeRevelada ? _fundoConfidencial : _azulPrimario,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
              ),
              icon: Icon(
                _identidadeRevelada
                    ? Icons.visibility_off
                    : (eOUltimo ? Icons.play_arrow : Icons.arrow_forward),
              ),
              label: Text(
                _identidadeRevelada
                    ? 'Ocultar Identidade'
                    : (eOUltimo ? 'Todos Prontos! Ir para a Mesa' : 'Já decorei, passar para $proximoNome'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardPasseCelular(Player jogador) {
    return Container(
      key: const ValueKey('card_passe'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _fundoCampo,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _borda, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0A1B3F),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Ícone de troca
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: _azulClaro),
            ),
            child: const Icon(Icons.sync_alt, color: _azulPrimario, size: 30),
          ),
          const SizedBox(height: 16),

          const Text(
            'MOMENTO DA TROCA',
            style: TextStyle(
              color: _azulClaro,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),

          const Text(
            'Passe o celular para:',
            style: TextStyle(color: _cinzaTexto, fontSize: 14),
          ),
          const SizedBox(height: 6),

          // Nome do jogador em destaque
          Text(
            jogador.name,
            style: const TextStyle(
              color: _azulEscuro,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 18),

          // Aviso de privacidade
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borda),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.visibility_off, size: 16, color: _rosa),
                SizedBox(width: 8),
                Text(
                  'Apenas você deve ver a próxima tela!',
                  style: TextStyle(
                    fontSize: 12,
                    color: _azulEscuro,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Botão SEGURE PARA REVELAR (com gesture detector)
          GestureDetector(
            onLongPressStart: (_) => setState(() => _identidadeRevelada = true),
            onLongPressEnd: (_) => setState(() => _identidadeRevelada = false),
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: _azulPrimario,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x331A4B9F),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fingerprint, color: Colors.white, size: 26),
                  SizedBox(width: 10),
                  Text(
                    'SEGURE PARA REVELAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Toque e mantenha pressionado para ler seu papel',
            style: TextStyle(fontSize: 11, color: _cinzaTexto),
          ),
        ],
      ),
    );
  }

  Widget _cardConfidencialRevelado(Player jogador) {
    final bool eImpostor = _jogadorAtualEImpostor;

    return Container(
      key: const ValueKey('card_confidencial'),
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: _fundoConfidencial,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Badge CONFIDENCIAL
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_open, size: 14, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'CONFIDENCIAL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          if (eImpostor) ...[
            // MODO IMPOSTOR
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0x33F07A9A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.theater_comedy, color: _rosa, size: 36),
            ),
            const SizedBox(height: 14),
            const Text(
              'VOCÊ É O IMPOSTOR!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _rosa,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Você NÃO sabe a palavra secreta.\nFinja que sabe, ouça os outros e blefe para não ser descoberto!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
            ),
          ] else ...[
            // MODO JOGADOR(A)
            const Text(
              'SUA PALAVRA SECRETA É:',
              style: TextStyle(
                color: Color(0xFF72BBE0),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _palavraSecreta.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF5C7A99),
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Você não é o impostor',
                style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Dê pistas sutis na mesa para que outros jogadores saibam que você sabe, sem entregar a palavra ao impostor.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
            ),
          ],

          const SizedBox(height: 20),

          // Botão manual de ocultar
          TextButton.icon(
            onPressed: () => setState(() => _identidadeRevelada = false),
            icon: const Icon(Icons.visibility_off, color: Colors.white70, size: 18),
            label: const Text(
              'Solte ou toque para ocultar',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // FASE 2: DEBATE E PISTAS NA MESA
  // =========================================================================
  Widget _telaDiscussao(SetupState setup, List<Player> listaJogadores) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info: tema + rodadas
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: _fundoCampo,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borda),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoBadge('Tema', setup.temaSelecionado),
                _infoBadge('Rodadas', '${setup.rodadasSelecionadas} volta(s)'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Área do sorteio — troca de estado com animação
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
            child: _sorteioFinalizado
                ? _cardResultadoSorteio(listaJogadores)
                : _sorteioEmAndamento
                    ? _cardAnimacaoSorteio(listaJogadores)
                    : _cardBotaoSortear(listaJogadores),
          ),

          const SizedBox(height: 20),

          // Instruções (sempre visíveis)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borda),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Como jogar agora:',
                  style: TextStyle(color: _azulEscuro, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 6),
                Text(
                  '1. Em círculo, cada jogador fala UMA pista sobre o tema.\n'
                  '2. O Impostor precisa fingir que sabe e blefar.\n'
                  '3. Quando terminarem, cliquem abaixo para votar!',
                  style: TextStyle(color: _cinzaTexto, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          if (_sorteioFinalizado)
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _faseAtual = FaseJogo.votacao),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _azulPrimario,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.how_to_vote),
                label: const Text(
                  'Ir para Votação / Acusação',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Card inicial: botão para disparar o sorteio
  Widget _cardBotaoSortear(List<Player> jogadores) {
    return Container(
      key: const ValueKey('btn_sortear'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _fundoCampo,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borda),
      ),
      child: Column(
        children: [
          const Icon(Icons.record_voice_over, color: _azulPrimario, size: 48),
          const SizedBox(height: 12),
          const Text(
            'RODADA DE PISTAS!',
            style: TextStyle(color: _azulEscuro, fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sorteie quem dará a primeira pista.\nO impostor nunca começa!',
            textAlign: TextAlign.center,
            style: TextStyle(color: _cinzaTexto, fontSize: 13),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => _iniciarAnimacaoSorteio(jogadores),
              style: ElevatedButton.styleFrom(
                backgroundColor: _azulPrimario,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.casino),
              label: const Text(
                'SORTEAR QUEM COMEÇA!',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Card com nomes ciclando (efeito roleta desacelerando)
  Widget _cardAnimacaoSorteio(List<Player> jogadores) {
    final nomeAtual = jogadores.isNotEmpty ? jogadores[_indiceAnimacaoSorteio % jogadores.length].name : '';
    return Container(
      key: const ValueKey('anim_sorteio'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: _fundoConfidencial,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'SORTEANDO...',
            style: TextStyle(
              color: _azulClaro,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 60),
            child: Text(
              nomeAtual,
              key: ValueKey(nomeAtual + _indiceAnimacaoSorteio.toString()),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const LinearProgressIndicator(
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(_azulClaro),
          ),
        ],
      ),
    );
  }

  /// Card final com o resultado do sorteio
  Widget _cardResultadoSorteio(List<Player> jogadores) {
    final nome = jogadores.isNotEmpty ? jogadores[_indiceQuemComeca].name : '';
    return Container(
      key: const ValueKey('resultado_sorteio'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _azulPrimario,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x331A4B9F), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events, color: Colors.white, size: 36),
          const SizedBox(height: 10),
          const Text(
            'COMEÇA POR:',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            nome,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Os demais seguem em ordem na mesa.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// Lógica da animação de roleta com desaceleração progressiva
  void _iniciarAnimacaoSorteio(List<Player> jogadores) {
    if (jogadores.isEmpty) return;

    // Delays crescentes simulam a roleta desacelerando
    final delays = [70, 70, 80, 80, 100, 110, 130, 160, 200, 260, 330, 420, 530];

    int step = 0;

    setState(() {
      _sorteioEmAndamento = true;
      _sorteioFinalizado = false;
      _indiceAnimacaoSorteio = 0;
    });

    void proximoPasso() {
      if (!mounted) return;

      if (step >= delays.length) {
        // Finaliza: exibe o sorteado real
        setState(() {
          _sorteioEmAndamento = false;
          _sorteioFinalizado = true;
          _indiceAnimacaoSorteio = _indiceQuemComeca;
        });
        return;
      }

      setState(() {
        _indiceAnimacaoSorteio = (_indiceAnimacaoSorteio + 1) % jogadores.length;
      });

      Future.delayed(Duration(milliseconds: delays[step]), () {
        step++;
        proximoPasso();
      });
    }

    Future.delayed(const Duration(milliseconds: 70), proximoPasso);
  }

  // =========================================================================
  // FASE 3: VOTAÇÃO E ACUSAÇÃO
  // =========================================================================
  Widget _telaVotacao(SetupState setup, List<Player> listaJogadores) {
    final bool eImpostorAcertado = _jogadorAcusadoIndex == _indiceImpostor;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Text(
              'QUEM É O IMPOSTOR?',
              style: TextStyle(
                color: _azulEscuro,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'A mesa entrou em consenso? Selecione o jogador acusado:',
              textAlign: TextAlign.center,
              style: TextStyle(color: _cinzaTexto, fontSize: 13),
            ),
          ),
          const SizedBox(height: 20),

          // Lista de botões para escolher o acusado
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: List.generate(listaJogadores.length, (index) {
              final jogador = listaJogadores[index];
              final bool selecionado = _jogadorAcusadoIndex == index;

              return ChoiceChip(
                label: Text(jogador.name),
                selected: selecionado,
                selectedColor: _azulPrimario,
                backgroundColor: _fundoCampo,
                labelStyle: TextStyle(
                  color: selecionado ? Colors.white : _azulEscuro,
                  fontWeight: FontWeight.bold,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                onSelected: _votacaoFinalizada
                    ? null
                    : (val) {
                        setState(() => _jogadorAcusadoIndex = val ? index : null);
                      },
              );
            }),
          ),

          const SizedBox(height: 24),

          // Revelação pós-votação
          if (_votacaoFinalizada) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: eImpostorAcertado ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: eImpostorAcertado ? _verde : _rosa,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    eImpostorAcertado ? Icons.check_circle : Icons.cancel,
                    color: eImpostorAcertado ? _verde : _rosa,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    eImpostorAcertado
                        ? 'A MESA ACERTOU!'
                        : 'O IMPOSTOR ENGANOU A TODOS!',
                    style: TextStyle(
                      color: eImpostorAcertado ? _verde : _rosa,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'O verdadeiro impostor era: ${listaJogadores[_indiceImpostor].name}',
                    style: const TextStyle(
                      color: _azulEscuro,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'A palavra secreta era: $_palavraSecreta',
                    style: const TextStyle(color: _cinzaTexto, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Botões de ação
          if (!_votacaoFinalizada)
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _jogadorAcusadoIndex == null
                    ? null
                    : () {
                        setState(() => _votacaoFinalizada = true);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _azulPrimario,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.gavel),
                label: const Text(
                  'Confirmar Acusação da Mesa',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            )
          else
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _concluirVotacaoEExibirRanking(setup),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _azulPrimario,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.emoji_events),
                label: const Text(
                  'Ver Pódio e Classificação Final',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoBadge(String label, String valor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: _cinzaTexto, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          valor,
          style: const TextStyle(
            color: _azulEscuro,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _exibirAjuda() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: _azulPrimario),
            SizedBox(width: 8),
            Text('Regras do Impostor'),
          ],
        ),
        content: const Text(
          '1. O celular passa na mão de cada um em segredo.\n'
          '2. Quem for Jogador(a) verá a Palavra Secreta.\n'
          '3. O Impostor verá que é o impostor e não sabe a palavra!\n'
          '4. Na mesa, todos falam pistas curtas.\n'
          '5. No fim, a mesa vota para descobrir quem mentiu.',
          style: TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }
}
