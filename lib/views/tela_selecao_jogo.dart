import 'package:flutter/material.dart';
import 'package:playzzo/widgets/playzzo_app_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'tela_config_jogo.dart';
import 'tela_perfil.dart';

const Color azulCobalto = Color(0xFF1A4B9F);
const Color azulCeleste = Color(0xFF72BBE0);
const Color brancoPuro = Color(0xFFFFFFFF);
const Color azulMarinho = Color(0xFF0A1B3F);
const Color rosaCoral = Color(0xFFF07A9A);

class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoTag({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: azulCeleste.withOpacity(0.16),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: azulCobalto),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: azulMarinho,
            ),
          ),
        ],
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  final String title;
  final String description;
  final Widget leadingIcon;
  final String primeiraTag;
  final IconData iconePrimeiraTag;
  final String segundaTag;
  final IconData iconeSegundaTag;
  final VoidCallback onTap;

  const GameCard({
    Key? key,
    required this.title,
    required this.description,
    required this.leadingIcon,
    required this.primeiraTag,
    required this.iconePrimeiraTag,
    required this.segundaTag,
    required this.iconeSegundaTag,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: azulCobalto.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: leadingIcon,
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
                  const SizedBox(height: 12.0),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoTag(icon: iconePrimeiraTag, label: primeiraTag),
                      _InfoTag(icon: iconeSegundaTag, label: segundaTag),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            const Icon(Icons.arrow_forward_ios, color: azulCeleste, size: 16),
          ],
        ),
      ),
    );
  }
}

class GameSelectionScreen extends StatefulWidget {
  const GameSelectionScreen({Key? key}) : super(key: key);

  @override
  State<GameSelectionScreen> createState() => _GameSelectionScreenState();
}

class _GameSelectionScreenState extends State<GameSelectionScreen> {
  int _indiceAtual = 0;


  Widget _buildConteudoAba() {
    if (_indiceAtual == 1) {
      return const Center(
        child: Text(
          'Histórico de partidas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: azulMarinho,
          ),
        ),
      );
    }

    if (_indiceAtual == 2) {
      return const TelaPerfil();
    }

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jogos da Galera',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: azulMarinho,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Escolha um minigame para jogar no mesmo celular',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: azulMarinho.withOpacity(0.65),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
        const SizedBox(height: 12),
        GameCard(
          title: 'Mímica',
          description: 'Gestos proibidos e risadas garantidas!',
          leadingIcon: SvgPicture.asset(
            'assets/icons/mask.svg',
            width: 32,
            height: 32,
            colorFilter: const ColorFilter.mode(azulCobalto, BlendMode.srcIn),
          ),
          primeiraTag: '3+ Jogadores',
          iconePrimeiraTag: Icons.groups_rounded,
          segundaTag: 'Sem Falar',
          iconeSegundaTag: Icons.mic_off_rounded,
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
          leadingIcon: SvgPicture.asset(
            'assets/icons/face.svg',
            width: 32,
            height: 32,
            colorFilter: const ColorFilter.mode(azulCobalto, BlendMode.srcIn),
          ),
          primeiraTag: '3 a 10 Jogadores',
          iconePrimeiraTag: Icons.groups_rounded,
          segundaTag: 'Na Testa',
          iconeSegundaTag: Icons.style_outlined,
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
          title: 'Bomba Relógio',
          description: 'Fale rápido e passe o celular antes da explosão',
          leadingIcon: SvgPicture.asset(
            'assets/icons/bomb.svg',
            width: 32,
            height: 32,
            colorFilter: const ColorFilter.mode(azulCobalto, BlendMode.srcIn),
          ),
          primeiraTag: '4+ Jogadores',
          iconePrimeiraTag: Icons.groups_rounded,
          segundaTag: 'Passe Rápido',
          iconeSegundaTag: Icons.bolt_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GameConfigScreen(gameTitle: 'Bomba Relógio'),
              ),
            );
          },
        ),
        GameCard(
          title: 'O Impostor',
          description: 'Descubra quem não sabe a palavra secreta da rodada',
          leadingIcon: SvgPicture.asset(
            'assets/icons/spy.svg',
            width: 32,
            height: 32,
            colorFilter: const ColorFilter.mode(azulCobalto, BlendMode.srcIn),
          ),
          primeiraTag: '3 a 8 Jogadores',
          iconePrimeiraTag: Icons.groups_rounded,
          segundaTag: 'Papéis Secretos',
          iconeSegundaTag: Icons.visibility_off_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GameConfigScreen(gameTitle: 'O Impostor'),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
            appBar: const PlayzzoAppBar(),
      body: _buildConteudoAba(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _indiceAtual,
        backgroundColor: brancoPuro,
        selectedItemColor: azulCobalto,
        unselectedItemColor: azulMarinho.withOpacity(0.55),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800),
        onTap: (index) {
          setState(() {
            _indiceAtual = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports_rounded),
            label: 'Jogos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'Histórico',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}