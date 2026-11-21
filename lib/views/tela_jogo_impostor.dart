import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/setup_jogo_impostor_model.dart';


class TelaJogoImpostor extends StatelessWidget {
  const TelaJogoImpostor({super.key});

  @override
  Widget build(BuildContext context) {
    final setup = Provider.of<SetupState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostor'),
        backgroundColor: const Color(0xFF1A4B9F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tema da palavra secreta
            Text('Tema: ${setup.selecionarTema}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // Rodadas selecionadas
            Text('Rodadas: ${setup.selecionarRodadas}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            // Lista de jogadores
            const Text('Jogadores',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: setup.jogadores.length,
                itemBuilder: (context, i) {
                  final p = setup.jogadores[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF1A4B9F),
                      child: Text('${i + 1}', style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(p.name),
                    trailing: p.isHost ? const Icon(Icons.star, size: 18, color: Colors.amber) : null,
                  );
                },
              ),
            ),
            // Desafio / prenda (se estiver ativo)
            if (setup.desafioAtivo) ...[
              const Divider(),
              const Text('Prenda', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(setup.penalidade),
            ],
            const SizedBox(height: 16),
            // Botão para avançar para a próxima fase (ex.: jogar)
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A4B9F),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Iniciar rodada'),
                onPressed: () {
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rodada iniciada (placeholder)')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
