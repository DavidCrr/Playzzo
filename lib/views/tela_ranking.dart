import 'package:flutter/material.dart';
import '../models/resultado_jogo.dart';
import '../services/ranking_service.dart';

const Color _azulPrimario = Color(0xFF1A4B9F);
const Color _azulEscuro = Color(0xFF0A1B3F);
const Color _fundoCampo = Color(0xFFF0F7FB);
const Color _rosa = Color(0xFFF08BA0);
const Color _cinzaTexto = Color(0xFF434652);
const Color _ouro = Color(0xFFFFB800);
const Color _prata = Color(0xFFA0AAB8);
const Color _bronze = Color(0xFFCD7F32);

/// Tela de Encerramento e Ranking 100% reutilizável para todos os minigames do Playzzo.
class TelaRanking extends StatefulWidget {
  final ResultadoPartida resultado;

  const TelaRanking({
    super.key,
    required this.resultado,
  });

  @override
  State<TelaRanking> createState() => _TelaRankingState();
}

class _TelaRankingState extends State<TelaRanking> {
  bool _salvandoNoBanco = true;
  bool _salvoComSucesso = false;

  @override
  void initState() {
    super.initState();
    _salvarNoBackend();
  }

  Future<void> _salvarNoBackend() async {
    final sucesso = await RankingService.registrarPartida(widget.resultado);
    if (mounted) {
      setState(() {
        _salvandoNoBanco = false;
        _salvoComSucesso = sucesso;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ranking = widget.resultado.ranking;
    final bool temPodio = ranking.length >= 2;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_esports, color: _azulPrimario, size: 30),
            SizedBox(width: 8),
            Text(
              'PLAYZZO',
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // -------------------------------------
              // CABEÇALHO DO JOGO E RESULTADO
              // -------------------------------------
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: _fundoCampo,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF72BBE0)),
                      ),
                      child: Text(
                        widget.resultado.nomeJogo.toUpperCase(),
                        style: const TextStyle(
                          color: _azulPrimario,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events, color: _ouro, size: 32),
                        SizedBox(width: 8),
                        Text(
                          'FIM DE JOGO!',
                          style: TextStyle(
                            color: _azulEscuro,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Confira a classificação final da rodada',
                      style: TextStyle(color: _cinzaTexto, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // -------------------------------------
              // PÓDIO (se houver 2 ou mais competidores)
              // -------------------------------------
              if (temPodio)
                _construirPodio(ranking)
              else if (ranking.isNotEmpty)
                _construirCardJogadorUnico(ranking.first),

              const SizedBox(height: 20),

              // -------------------------------------
              // PRENDA OU APOSTA SOCIAL (se houver)
              // -------------------------------------
              if (widget.resultado.prenda != null &&
                  widget.resultado.prenda!.trim().isNotEmpty)
                _construirCardPrenda(),

              const SizedBox(height: 20),

              // -------------------------------------
              // LISTA COMPLETA DE CLASSIFICAÇÃO
              // -------------------------------------
              const Text(
                'Classificação Geral',
                style: TextStyle(
                  color: _azulEscuro,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ranking.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final jogador = ranking[index];
                  final posicao = index + 1;
                  return _construirItemRanking(posicao, jogador);
                },
              ),

              const SizedBox(height: 28),

              // -------------------------------------
              // BOTÕES DE AÇÃO
              // -------------------------------------
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: widget.resultado.onJogarNovamente ??
                      () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _azulPrimario,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.replay, size: 22),
                  label: const Text(
                    'Jogar Novamente',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: widget.resultado.onVoltarMenu ??
                      () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _azulEscuro,
                    side: const BorderSide(color: Color(0xFFE2EDF5), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.grid_view, size: 20),
                  label: const Text(
                    'Escolher Outro Jogo',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Indicador sutil de sincronização com o banco
              if (_salvandoNoBanco)
                const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Salvando histórico...',
                        style: TextStyle(fontSize: 11, color: _cinzaTexto),
                      ),
                    ],
                  ),
                )
              else if (_salvoComSucesso)
                const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_done, size: 16, color: Colors.green),
                      SizedBox(width: 6),
                      Text(
                        'Partida salva na sua conta!',
                        style: TextStyle(fontSize: 11, color: Colors.green),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // WIDGETS AUXILIARES
  // ==========================================================

  Widget _construirPodio(List<JogadorPontuacao> ranking) {
    final primeiro = ranking.isNotEmpty ? ranking[0] : null;
    final segundo = ranking.length > 1 ? ranking[1] : null;
    final terceiro = ranking.length > 2 ? ranking[2] : null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: _fundoCampo,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2EDF5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2º LUGAR
          if (segundo != null)
            _colunaPodio(
              jogador: segundo,
              posicao: '2º',
              corMedalha: _prata,
              alturaBase: 70,
              tamanhoAvatar: 46,
            )
          else
            const SizedBox(width: 60),

          // 1º LUGAR (MAIOR E CENTRAL)
          if (primeiro != null)
            _colunaPodio(
              jogador: primeiro,
              posicao: '1º',
              corMedalha: _ouro,
              alturaBase: 100,
              tamanhoAvatar: 58,
              destaque: true,
            ),

          // 3º LUGAR
          if (terceiro != null)
            _colunaPodio(
              jogador: terceiro,
              posicao: '3º',
              corMedalha: _bronze,
              alturaBase: 55,
              tamanhoAvatar: 42,
            )
          else
            const SizedBox(width: 60),
        ],
      ),
    );
  }

  Widget _colunaPodio({
    required JogadorPontuacao jogador,
    required String posicao,
    required Color corMedalha,
    required double alturaBase,
    required double tamanhoAvatar,
    bool destaque = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (destaque)
          const Icon(Icons.workspace_premium, color: _ouro, size: 26)
        else
          const SizedBox(height: 26),

        // Avatar com medalha
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: tamanhoAvatar / 2,
              backgroundColor: destaque ? _azulPrimario : Colors.white,
              child: Text(
                jogador.nome.isNotEmpty ? jogador.nome[0].toUpperCase() : '?',
                style: TextStyle(
                  color: destaque ? Colors.white : _azulEscuro,
                  fontWeight: FontWeight.bold,
                  fontSize: destaque ? 20 : 16,
                ),
              ),
            ),
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: corMedalha,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  posicao,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Nome do jogador
        SizedBox(
          width: 80,
          child: Text(
            jogador.nome,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _azulEscuro,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),

        // Pontos
        Text(
          '${jogador.pontos} pts',
          style: TextStyle(
            color: destaque ? _azulPrimario : _cinzaTexto,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 6),

        // Bloco visual de altura do pódio
        Container(
          width: 70,
          height: alturaBase,
          decoration: BoxDecoration(
            color: destaque
                ? _azulPrimario
                : const Color.fromARGB(255, 219, 230, 243),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Center(
            child: Text(
              posicao,
              style: TextStyle(
                color: destaque ? Colors.white : _azulEscuro,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirCardJogadorUnico(JogadorPontuacao jogador) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _fundoCampo,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2EDF5)),
      ),
      child: Column(
        children: [
          const Icon(Icons.stars, color: _ouro, size: 54),
          const SizedBox(height: 10),
          Text(
            jogador.nome,
            style: const TextStyle(
              color: _azulEscuro,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${jogador.pontos} PONTOS',
            style: const TextStyle(
              color: _azulPrimario,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (jogador.detalhe != null) ...[
            const SizedBox(height: 6),
            Text(
              jogador.detalhe!,
              style: const TextStyle(color: _cinzaTexto, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _construirCardPrenda() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _rosa.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: _rosa,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'PRENDA SOCIAL',
                      style: TextStyle(
                        color: _rosa,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (widget.resultado.nomePerdedorPrenda != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        '(${widget.resultado.nomePerdedorPrenda})',
                        style: const TextStyle(
                          color: _azulEscuro,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.resultado.prenda!,
                  style: const TextStyle(
                    color: _azulEscuro,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirItemRanking(int posicao, JogadorPontuacao jogador) {
    Color corBadge;
    if (posicao == 1) {
      corBadge = _ouro;
    } else if (posicao == 2) {
      corBadge = _prata;
    } else if (posicao == 3) {
      corBadge = _bronze;
    } else {
      corBadge = const Color(0xFFC3C6D7);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _fundoCampo,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: posicao == 1 ? _ouro.withValues(alpha: 0.5) : const Color(0xFFE2EDF5),
        ),
      ),
      child: Row(
        children: [
          // Posição
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: corBadge,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$posicaoº',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Nome e detalhe
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jogador.nome,
                  style: const TextStyle(
                    color: _azulEscuro,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (jogador.detalhe != null && jogador.detalhe!.isNotEmpty)
                  Text(
                    jogador.detalhe!,
                    style: const TextStyle(
                      color: _cinzaTexto,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),

          // Pontuação
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${jogador.pontos} pts',
              style: const TextStyle(
                color: _azulPrimario,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
