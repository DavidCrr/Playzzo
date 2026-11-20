import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:playzzo/models/usuario.dart';

class ErroApi implements Exception {
  final String mensagem;
  ErroApi(this.mensagem);
}

class AuthService {
  static SupabaseClient get _supabase => Supabase.instance.client;

  static Usuario? usuarioAtual;
  //Traduz os erros do supabase
  static ErroApi _erro(Object e) {
    if (e is ErroApi) return e;

    if (e is AuthException) {
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid login credentials')) {
        return ErroApi('E-mail ou senha incorretos.');
      }
      if (msg.contains('already registered')) {
        return ErroApi('Este e-mail já está cadastrado.');
      }
      if (msg.contains('password should be')) {
        return ErroApi('Senha fraca: use no mínimo 6 caracteres.');
      }
      if (msg.contains('different from the old')) {
        return ErroApi('A nova senha deve ser diferente da atual.');
      }
      if (msg.contains('email not confirmed')) {
        return ErroApi('Confirme seu e-mail antes de entrar.');
      }
      return ErroApi(e.message);
    }

    return ErroApi('Erro de conexão. Verifique a internet e tente novamente.');
  }

  static Future<Us
}