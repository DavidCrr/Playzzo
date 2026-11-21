import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/resultado_jogo.dart';
import 'auth_service.dart';

/// Serviço responsável por persistir e consultar resultados de partidas no Supabase.
class RankingService {
  static SupabaseClient get _supabase => Supabase.instance.client;

  /// Registra o resultado da partida no Supabase.
  /// Possui tratamento resiliente: se houver oscilação de conexão ou tabela ausente,
  /// o jogo não trava e continua funcionando localmente.
  static Future<bool> registrarPartida(ResultadoPartida resultado) async {
    try {
      final user = AuthService.usuarioAtual;

      final dadosPartida = {
        'jogo': resultado.nomeJogo,
        'usuario_id': user?.id,
        'criado_em': DateTime.now().toIso8601String(),
        'vencedor': resultado.ranking.isNotEmpty ? resultado.ranking.first.nome : null,
        'pontuacao_vencedor': resultado.ranking.isNotEmpty ? resultado.ranking.first.pontos : 0,
        'prenda': resultado.prenda,
        'detalhes': resultado.ranking
            .map((j) => {
                  'nome': j.nome,
                  'pontos': j.pontos,
                  'detalhe': j.detalhe,
                })
            .toList(),
      };

      await _supabase.from('historico_partidas').insert(dadosPartida);
      return true;
    } catch (e) {
      debugPrint('RankingService [Aviso]: Não foi possível salvar no Supabase (offline/tabela ausente): $e');
      return false;
    }
  }

  /// Consulta o histórico recente de partidas de determinado jogo.
  static Future<List<Map<String, dynamic>>> obterHistorico(String nomeJogo) async {
    try {
      final response = await _supabase
          .from('historico_partidas')
          .select()
          .eq('jogo', nomeJogo)
          .order('criado_em', ascending: false)
          .limit(10);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('RankingService [Aviso]: Erro ao buscar histórico: $e');
      return [];
    }
  }
}
