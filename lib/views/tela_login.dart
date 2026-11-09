//Inserindo bibliotecas
import 'package:flutter/material.dart';

//Criando a classe TelaLogin
class TelaLogin extends StatelessWidget {
    const TelaLogin({super.key});

//Sobrecarga no StatelessWidget, inserindo um Widget com a barra de aplicativos
@override
Widget build(BuildContext context) {
  return Scaffold(
  appBar: AppBar(
  backgroundColor: Colors.white,
  elevation: 0,
  centerTitle: true, //Alinha esse widget todo ao centro
  title: const Row(
    mainAxisSize: MainAxisSize.min,  //ocupa o mínimo de espaço
    children: [
      Icon(
        Icons.sports_esports,
        color: Color(0xFF1A4B9F),
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
    );
  }
}