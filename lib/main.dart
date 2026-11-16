import 'package:flutter/material.dart';
import 'views/tela_selecao_jogo.dart';

void main() {
  runApp(const PlayzooApp());
}

class PlayzooApp extends StatelessWidget {
  const PlayzooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameSelectionScreen(),
    );
  }
}