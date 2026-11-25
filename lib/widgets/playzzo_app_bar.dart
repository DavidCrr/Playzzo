import 'package:flutter/material.dart';

const Color _azulPrimario = Color(0xFF1A4B9F);
const Color _azulEscuro = Color(0xFF0A1B3F);

// AppBar padrão do Playzzo, usada em todas as telas.
// Fundo branco, ícone e título em azul.
class PlayzzoAppBar extends StatelessWidget implements PreferredSizeWidget {
  // Texto do topo (padrão: PLAYZZO)
  final String titulo;

  // Ícone à esquerda do título (padrão: controle de videogame).
  // Passe null para mostrar só o texto.
  final Widget? icone;

  // Botões opcionais do lado direito (ex.: ajuda no jogo Impostor)
  final List<Widget>? actions;

  // false = não mostra a seta de voltar automática
  final bool automaticallyImplyLeading;

  const PlayzzoAppBar({
    super.key,
    this.titulo = 'PLAYZZO',
    this.icone = const Icon(
      Icons.sports_esports,
      color: _azulPrimario,
      size: 33,
    ),
    this.actions,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true, // alinha o título ao centro
      automaticallyImplyLeading: automaticallyImplyLeading,
      iconTheme: const IconThemeData(color: _azulEscuro), // cor da seta de voltar
      actions: actions,
      title: Row(
        mainAxisSize: MainAxisSize.min, // ocupa o mínimo de espaço, junto com o centerTitle
        children: [
          // Só mostra o ícone (e o espaço) se ele existir
          if (icone != null) ...[
            icone!,
            const SizedBox(width: 8), // espaço entre o ícone e o texto
          ],
          Text(
            titulo,
            style: const TextStyle(
              color: _azulPrimario,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // O Scaffold precisa saber a altura da appBar: usamos a altura padrão
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
