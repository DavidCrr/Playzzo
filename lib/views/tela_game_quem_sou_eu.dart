import 'dart:async'; // necessário para o Timer (cronômetro)
import 'package:flutter/material.dart';

const Color _azulPrimario = Color(0xFF1A4B9F);
const Color _azulEscuro = Color(0xFF0A1B3F);
const Color _fundoCampo = Color(0xFFF0F7FB);
const Color _rosa = Color(0xFFF08BA0);

const int _tempoTotal = 60; // segundos de cada partida

// =====================================
// UMA CARTA DO JOGO
// =====================================
class Carta {
  final String palavra;
  final String categoria;

  const Carta(this.palavra, this.categoria);
}

class TelaQuemSouEu extends StatefulWidget {
  const TelaQuemSouEu({super.key});

  @override
  State<TelaQuemSouEu> createState() => _TelaQuemSouEuState();
}

class _TelaQuemSouEuState extends State<TelaQuemSouEu> {
  // Cartas de exemplo (no futuro virão do back-end) //Apenas teste
  final List<Carta> _cartas = [
    const Carta('SHREK', 'FILMES & ANIMAÇÕES'),
    const Carta('PELÉ', 'ESPORTES'),
    const Carta('PIKACHU', 'GAMES & DESENHOS'),
    const Carta('BATMAN', 'HERÓIS'),
    const Carta('ANITTA', 'MÚSICA'),
  ];

  int _indice = 0; // qual carta está aparecendo
  int _pontos = 0;
  int _segundos = _tempoTotal;
  Timer? _timer;

  // =====================================
  // GETTERS (valores calculados)
  // =====================================
  Carta get _cartaAtual => _cartas[_indice];


  final String _nomeJogador = 'Lucas Mendes';


  // =====================================
  // CICLO DE VIDA DA TELA
  // =====================================
  @override
  void initState() {
    super.initState();
    _novaPartida(); // começa o jogo assim que a tela abre
  }

  @override
  void dispose() {
    _timer?.cancel(); // para o cronômetro ao sair da tela
    super.dispose();
  }

  // =====================================
  // LÓGICA DO JOGO
  // =====================================
  void _novaPartida() {
    _cartas.shuffle(); // embaralha as cartas
    _indice = 0;
    _pontos = 0;
    _segundos = _tempoTotal;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _segundos--);
      if (_segundos == 0) _fimDeJogo();
    });
  }

  void _proximaCarta({required bool acertou}) {
    final eraUltima = _indice == _cartas.length - 1;

    setState(() {
      if (acertou) _pontos += 100;
      if (!eraUltima) {
        _indice++;
      }
    });

    if (eraUltima) _fimDeJogo();
  }

  void _fimDeJogo() {
    _timer?.cancel();

    showDialog(
      context: context,
      barrierDismissible: false, // não fecha clicando fora
      builder: (context) => AlertDialog(
        title: const Text('Fim de jogo!'),
        content: Text('$_nomeJogador fez $_pontos pontos.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // fecha a caixa
              Navigator.pop(context); // sai da tela do jogo
            },
            child: const Text('Sair'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // fecha a caixa
              setState(_novaPartida); // recomeça
            },
            child: const Text('Jogar de novo'),
          ),
        ],
      ),
    );
  }

  // 75 -> "01:15"
  String _formatarTempo(int total) {
    final minutos = total ~/ 60; // divisão inteira
    final segundos = total % 60; // resto da divisão
    return '${minutos.toString().padLeft(2, '0')}:'
        '${segundos.toString().padLeft(2, '0')}';
  }

  // =====================================
  // PEDAÇOS DA TELA
  // =====================================
  Widget _cardBranco({required Widget child, double padding = 12}) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  /*// Quadradinho SIM / NÃO / TALVEZ
  Widget _respostaPermitida(String texto, Color cor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: cor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const SizedBox(height: 4),
            Text(
              texto,
              style: TextStyle(color: cor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }*/

  // Botões PULAR / ACERTOU
  Widget _botaoAcao({
    required String titulo,
    required String subtitulo,
    required IconData icone,
    required Color cor,
    required VoidCallback aoClicar,
  }) {
    return SizedBox(
      height: 70,
      child: ElevatedButton(
        onPressed: aoClicar,
        style: ElevatedButton.styleFrom(
          backgroundColor: cor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icone, size: 18),
                const SizedBox(width: 6),
                Text(
                  titulo,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(subtitulo, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  // =====================================
  // CONSTRUÇÃO DA TELA
  // =====================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              //adicionar icon que está na tela de seleção que foi definido para esse jogo
              'PLAYZZO - QUEM SOU EU?',
              style: TextStyle(
                color: _azulPrimario,
                fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // =====================================
              // JOGADOR + PONTOS
              // =====================================
              Row(
                children: [
                  Expanded(
                    child: _cardBranco(
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Jogador da vez:',
                                  style: TextStyle(
                                    color: _azulPrimario,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _nomeJogador,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: _azulEscuro,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _cardBranco(
                    child: Row(
                      children: [
                        const Icon(Icons.stars, color: _azulPrimario),
                        const SizedBox(width: 6),
                        Text(
                          '$_pontos pts',
                          style: const TextStyle(
                            color: _azulEscuro,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // =====================================
              // CRONÔMETRO
              // =====================================
              Center(
                child: SizedBox(
                  width: 130,
                  height: 130,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: _segundos / _tempoTotal, // de 1.0 até 0.0
                        strokeWidth: 8,
                        backgroundColor: const Color(0xFFE0E6F0),
                        // fica vermelho nos últimos 10 segundos
                        color: _segundos <= 10 ? Colors.red : _azulPrimario,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatarTempo(_segundos),
                            style: const TextStyle(
                              color: _azulEscuro,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Text(
                            'SEGUNDOS',
                            style: TextStyle(
                              color: _azulPrimario,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // =====================================
              // CARTA
              // =====================================
              _cardBranco(
                padding: 24,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _fundoCampo,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _cartaAtual.categoria,
                        style: const TextStyle(
                          color: _azulPrimario,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _cartaAtual.palavra,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _azulEscuro,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              const SizedBox(height: 16),

                //Não concordei com essa parte, vou tirar do código, aguardando o restante dos colaboradores darem o aval.
              // =====================================
              // REGRA DE OURO
              // =====================================
              /*_cardBranco(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'REGRA DE OURO DA MESA',
                          style: TextStyle(
                            color: _cinzaTexto,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' só ouve:',
                          style: const TextStyle(
                            color: _azulEscuro,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _respostaPermitida('SIM', _azulPrimario),
                        const SizedBox(width: 8),
                        _respostaPermitida('NÃO', _rosa),
                        const SizedBox(width: 8),
                        _respostaPermitida('TALVEZ', Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              */

              // =====================================
              // BOTÕES PULAR / ACERTOU
              // =====================================
              Row(
                children: [
                  Expanded(
                    child: _botaoAcao(
                      titulo: 'PULAR',
                      subtitulo: 'Passar vez (0 pts)',
                      icone: Icons.fast_forward,
                      cor: _rosa,
                      aoClicar: () => _proximaCarta(acertou: false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _botaoAcao(
                      titulo: 'ACERTOU!',
                      subtitulo: '+100 pontos',
                      icone: Icons.check_circle,
                      cor: _azulPrimario,
                      aoClicar: () => _proximaCarta(acertou: true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}