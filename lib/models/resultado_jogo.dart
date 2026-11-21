import 'package:flutter/foundation.dart';

/// Representa o resultado de um jogador na partida.
class JogadorPontuacao {
  final String nome;
  final int pontos;
  final String? detalhe; // Ex.: "Impostor (Venceu)", "Cidadão", "+5 cartas acertadas"
  final bool destaqueVencedor;

  const JogadorPontuacao({
    required this.nome,
    required this.pontos,
    this.detalhe,
    this.destaqueVencedor = false,
  });
}

/// Modelo de dados completo para a Tela de Encerramento e Ranking.
class ResultadoPartida {
  final String nomeJogo; // Ex: "Impostor", "Quem Sou Eu?"
  final List<JogadorPontuacao> ranking;
  final String? prenda; // Mensagem de prenda ou aposta social (opcional)
  final String? nomePerdedorPrenda;
  final VoidCallback? onJogarNovamente;
  final VoidCallback? onVoltarMenu;

  ResultadoPartida({
    required this.nomeJogo,
    required List<JogadorPontuacao> ranking,
    this.prenda,
    this.nomePerdedorPrenda,
    this.onJogarNovamente,
    this.onVoltarMenu,
  }) : ranking = List.unmodifiable(
          List<JogadorPontuacao>.from(ranking)
            ..sort((a, b) => b.pontos.compareTo(a.pontos)),
        );
}
