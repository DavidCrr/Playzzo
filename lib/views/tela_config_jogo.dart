import 'package:flutter/material.dart';

const Color azulCobalto = Color(0xFF1A4B9F);
const Color azulCeleste = Color(0xFF72BBE0);
const Color brancoPuro = Color(0xFFFFFFFF);
const Color azulMarinho = Color(0xFF0A1B3F);
const Color rosaCoral = Color(0xFFF07A9A);

class PlayzzoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;

  const PlayzzoAppBar({super.key, required this.titleText});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: azulCobalto,
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sports_esports, color: brancoPuro, size: 24),
          const SizedBox(width: 8),
          Text(
            titleText,
            style: const TextStyle(
              color: brancoPuro,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class GameConfigScreen extends StatelessWidget {
  final String gameTitle;

  const GameConfigScreen({super.key, required this.gameTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: PlayzzoAppBar(titleText: gameTitle),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Configurações da Partida',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: azulMarinho,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: brancoPuro,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: azulCeleste.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tempo por Rodada (segundos)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: azulMarinho,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: 60,
                    min: 30,
                    max: 180,
                    divisions: 5,
                    activeColor: azulCobalto,
                    inactiveColor: azulCeleste.withOpacity(0.3),
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: rosaCoral,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () {
                print("Iniciar partida de $gameTitle");
              },
              child: const Text(
                'Iniciar Jogo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: brancoPuro,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}