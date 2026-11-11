import 'package:flutter/material.dart';

const Color azulColbato = Color(0xFF1A4B9F);
const Color azulCeleste = Color (0xFF72BBE0);
const Color brancoPuro = Color(0xFFFFFFFF);
const Color azulMarinho = Color(0xFF0A1B3F);
const Color rosaCoral = Color(0xFFF07A9A);

class GameCard extends StatelessWidget{
    final String title;
    final String description;
    final IconData icon;
    final VoidCallback onTap;
    final bool isPopular;

    const GameCard({
        Key? key,
        required this.title,
        required this.description,
        required this.icon,
        required this.onTap,
        this.isPopular = false,
    }) : super(key: key);

    @override
    Widget build(BuildContext context){
        return GestureDetector(
            onTap: onTap,
            child: Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                padding const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                    color: brancoPuro,
                    borderRadius: borderRadius.circular(20.0),
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
                                color: azulColbato.withOpacity(0.1),
                                shape: BoxShape.circle,
                            ),
                            child: Icon(icon, size: 32, color: azulColbato),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                            child:Column{
                                crossAxisAlignment: crossAxisAlignment.start,
                                children: [
                                    Row(
                                        children: [
                                            Text(
                                                title,
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w800,
                                                    color: azulMarinho,
                                                ),
                                            ),
                                            if(isPopular)...[
                                                const SizedBox(width: 8),
                                                Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                        color: rosaCoral,
                                                        borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: const Text(
                                                        'Popular',
                                                        style: TextStyle(color: brancoPuro, fontSize: 10, fontWeight: FontWeight.bold),
                                                    ),
                                                ),
                                            ]
                                        ],
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
                            },
                        ),
                        const Icon(Icons.arrow_foward_ios, color: azulCeleste, size: 16),
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
            appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevantion: 0,
                title: const Text(
                    'Escolha um minigame',
                    style: TextStyle(
                        color: azulMarinho,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                    ),
                ),
                centerTitle: false,
            ),
            body: ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                    GameCard(
                        title: 'Mímica',
                        description: 'Gestos proibidos e risadas garantidas!',
                        icon: Icons.front_hand_rounded,
                        isPopular: true,
                        onTap: () {
                            print("Navegando para Configuração de Mímica");
                        },
                    ),
                    GameCard(
                        title: 'Quem Sou Eu?',
                        description: 'Coloque na testa e adivinhe com as dicas da galera!',
                        icon: Icons.face_retouching_natural,
                        onTap: (){
                            print("Navegando para Configuração de Quem Sou Eu?");
                        },
                    ),
                    GameCard(
                        title: 'O impostor',
                        description: 'Descubra quem não sabe a palavra secreta da rodada',
                        icon: Icons.masks.outlined,
                        onTap: (){
                            print("Navegando para Configuração de O Impostor");
                        },
                    ),
                    GameCard(
                        title: 'Bomba Relógio',
                        description: 'Fale rápido e passe o celular antes da explosão',
                        icon: Icons.timer_outlined,
                        onTap: (){
                            print("Navegando para Configuração de Bomba Relógio");
                        },
                    ),
                ],
            ),
        );
    }
}