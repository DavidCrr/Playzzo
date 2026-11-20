import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:playzzo/views/tela_login.dart';
import 'package:provider/provider.dart';
import 'models/setup_jogo_impostor_model.dart';
import 'views/tela_de_setup_jogo_impostor.dart';

void main() {
  runApp(
    // Provider que disponibiliza o SetupState para toda a aplicação
    ChangeNotifierProvider<SetupJogoImpostorModel>(
      create: (_) => SetupJogoImpostorModel(),
      child: const MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Playzzo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const TelaLogin(),
    );
  }
}

// ---------------------------------------------------
// Tela que lista os mini‑games disponíveis (após o login)
// ---------------------------------------------------
class GameSelectionScreen extends StatelessWidget {
  const GameSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escolha um Jogo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.theater_comedy),
            title: const Text('Impostor'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => Navigator.of(context).pushNamed('/impostor/setup'),
          ),
          // OBS*: adicionar outras opções de mini‑games aqui
        ],
      ),
    );
  }
}

// ---------------------------------------------------
// (código de exemplo do contador, mas agora fora da navegação principal)
// ---------------------------------------------------
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escolha um Jogo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.theater_comedy),
            title: const Text('Impostor'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => Navigator.of(context).pushNamed('/impostor/setup'),
          ),
        ],
      ),
    );
  }
}