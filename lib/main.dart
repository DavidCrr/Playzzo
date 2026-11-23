import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:playzzo/views/tela_login.dart';
import 'models/setup_jogo_impostor_model.dart';
import 'views/tela_selecao_jogo.dart';
import 'views/tela_setup_impostor.dart';
import 'views/tela_jogo_impostor.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://uiwwoeuwidbizktkpaxm.supabase.co',
    anonKey: 'sb_publishable_YmjSf9xR0DuZtn5xdajeTA_yRskVoCI',
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const TelaLogin(),
      routes: {
        '/login': (context) => const TelaLogin(),
        '/game': (context) => const GameSelectionScreen(),
        '/impostor/setup': (context) => const TelaSetupImpostor(),
        '/impostor': (context) => const TelaJogoImpostor(),
      },
    );
  }
}