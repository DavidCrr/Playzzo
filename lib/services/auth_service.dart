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

  static Future<Usuario> _carregarUsuario() async {
    final user = _supabase.auth.currentUser!;

    final dados = await _supabase
    .from('usuario')
    .select()
    .eq('id', user.id)
    .single();

    if (dados['ativo'] == false) {
      await _supabase.auth.signOut();
      throw ErroApi('Esta conta está desativada.');
    }
    usuarioAtual = Usuario(
      id: dados['id'],
      nome: dados['nome'],
      email: dados['email'],
    );
    return usuarioAtual!;
  }
  //login
  static Future<void> login(String email, String senha) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: senha,
      );
      return await _carregarUsuario();
    }
    catch (e) {
      throw _erro(e);
    }
  }
  //cadatro
  static Future<void> cadastrar(String nome, String email, String senha) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: senha,
        data: {'nome': nome}, //trigger
      );
      await _supabase.auth.signOut(); //signOut para o usuário logar novamente
    }
    catch (e) {
      throw _erro(e);
    }
  }
  //atualizar o nome
  static Future<void> atualizarPerfil(String nome) async {
    try {
      final id = usuarioAtual!.id;
      await _supabase.from('usuario').update({'nome': nome}).eq('id', id);
      usuarioAtual = Usuario(id: id, nome: nome, email: usuarioAtual!.email);
    }
    catch (e){
      throw _erro(e);
    }
  }
  //alteração de senha
  static Future<void> alterarSenha(String senhaAtual, novaSenha) async {
    try{
      await _supabase.auth.signInWithPassword(
        email: usuarioAtual!.email,
        password: senhaAtual,
      );
    }
    catch (_){
      throw ErroApi('Senha atual incorreta');
    }
    try{
      await _supabase.auth.updateUser(UserAttributes(password: novaSenha));
    }
    catch (e){
      throw _erro(e);
    }
  }
  //sair
  static Future<void> logout() async{
    await _supabase.auth.signOut();
    usuarioAtual = null;
  }
  
}