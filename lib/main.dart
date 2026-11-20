import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:playzzo/views/tela_login.dart';
import 'models/setup_jogo_impostor_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://uiwwoeuwidbizktkpaxm.supabase.co',
    publishableKey: 'sb_publishable_YmjSf9xR0DuZtn5xdajeTA_yRskVoCI',
  );

  runApp(
    ChangeNotifierProvider<SetupState>(
      create: (_) => SetupState(),
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
        ],
      ),
    );
  }
}