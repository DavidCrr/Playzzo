//Inserindo bibliotecas
import 'package:flutter/material.dart';

//Criando a classe TelaLogin
class TelaLogin extends StatelessWidget {
    const TelaLogin({super.key});

//Sobrecarga no StatelessWidget, inserindo um Widget com a barra de aplicativos
@override
Widget build(BuildContext context) {
  return Scaffold(
  appBar: AppBar( //barra de aplicativos
  backgroundColor: Colors.white,
  elevation: 0,
  centerTitle: true, //Alinha esse widget todo ao centro
  title: const Row(
    mainAxisSize: MainAxisSize.min,  //ocupa o mínimo de espaço e atua junto com o centerTitle, se eu tirar ele tira o texto do centro
    children: [
      Icon(
        Icons.sports_esports,
        color: Color(0xFF1A4B9F),
        size: 33,
      ),
      SizedBox(width: 8), //Esse sized box vai delimitar o espaço do ícone para o texto
      Text(
        'PLAYZZO',
        style: TextStyle(
          color: Color(0xFF1A4B9F), //cor padrão
          fontWeight: FontWeight.bold //fonte em negrito
        )
      )
    ],
  ),
),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container (
                      width: 80,
                      height: 80,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0F7FB),
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF2F3FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.celebration,
                          color: Color(0xFF1A4B9F),
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Bem-vindo de volta',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF0A1B3F),
                        fontSize: 28,
                        fontWeight: FontWeight.w800
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Entre para organizar partidas, salvar o histórico da galera e gerenciar seus jogos de festa favoritos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF434652),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    Container (
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F7FB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,

                              alignment: Alignment.center,

                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F3FF),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(
                              Icons.devices,
                              color: Color(0xFF1A4B9F),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'MULTIPLAYER ONE-DEVICE',
                                  style: TextStyle(
                                    color: Color(0xFF1A4B9F),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Apenas o anfitrião precisa estar logado para '
                                  'iniciar partidas com amigos no mesmo aparelho.',
                                  style: TextStyle(
                                    color: Color(0xFF0A1B3F),
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ]
                            ),
                          ),
                        ]
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}