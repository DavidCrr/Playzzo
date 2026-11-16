import 'package:flutter/material.dart';
import 'tela_config_jogo.dart';


const Color azulCobalto = Color(0xFF1A4B9F);
const Color azulCeleste = Color (0xFF72BBE0);
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

class GameCard extends StatelessWidget{
    final String title;
    final String description;
    final IconData icon;
    final VoidCallback onTap;

    const GameCard({
        Key? key,
        required this.title,
        required this.description,
        required this.icon,
        required this.onTap,
    }) : super(key: key);

    @override
    Widget build(BuildContext context){
        return GestureDetector(
            onTap: onTap,
            child: Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                    color: brancoPuro,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                        BoxShadow(
                            color: azulCeleste.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0,4),
                        ),
                    ],
                ),
                child: Row(
                    children:[ 
                        Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                                color: azulCobalto.withOpacity(0.1),
                                shape: BoxShape.circle,
                            ),
                            child: Icon(icon, size: 32, color: azulCobalto),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text(
                                        title,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: azulMarinho,
                                        ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                        description,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: azulMarinho.withOpacity(0.7),
                                        ),
                                    ),
                                ],
                            ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: azulCeleste, size: 16),
                    ],
                ),
            ),
        );
    }
}

class GameSelectionScreen extends StatelessWidget{
    const GameSelectionScreen({Key? key}) : super(key: key);

    @override
    Widget build (BuildContext context) {
        return Scaffold(
            backgroundColor: const Color(0xFFF5F7FA),
            appBar: const PlayzzoAppBar(titleText: 'Playzzo'),
            body: ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                    GameCard(
                        title: 'Mímica',
                        description: 'Gestos proibidos e risadas garantidas!',
                        icon: Icons.front_hand_rounded,
                        onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                builder: (context) => const GameConfigScreen(gameTitle: 'Mímica'),
                                ),
                            );
                        },
                    ),
                    GameCard(
                        title: 'Quem Sou Eu?',
                        description: 'Coloque na testa e adivinhe com as dicas da galera!',
                        icon: Icons.face_retouching_natural,
                        onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                builder: (context) => const GameConfigScreen(gameTitle: 'Quem Sou Eu?'),
                                ),
                            );
                        },
                    ),
                    GameCard(
                        title: 'O impostor',
                        description: 'Descubra quem não sabe a palavra secreta da rodada',
                        icon: Icons.masks_outlined,
                        onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                builder: (context) => const GameConfigScreen(gameTitle: 'O Impostor'),
                                ),
                            );
                        },
                    ),
                    GameCard(
                        title: 'Bomba Relógio',
                        description: 'Fale rápido e passe o celular antes da explosão',
                        icon: Icons.timer_outlined,
                         onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                builder: (context) => const GameConfigScreen(gameTitle: 'Bomba Relógio'),
                                ),
                            );
                        },
                    ),
                ],
            ),
        );
    }
}