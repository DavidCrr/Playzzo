import 'package:flutter/material.dart';

//Já definindo as váriaveis das cores para poder reaproveitar, ver de fazer isso nas outras telas.
const Color _azulPrimario = Color(0xFF1A4B9F);
const Color _azulEscuro = Color(0xFF0A1B3F);
const Color _cinzaTexto = Color(0xFF434652);
const Color _fundoCampo = Color(0xFFF0F7FB);
const Color _rosaDestaque = Color(0xFFE8668A);


//Criação da classe TelaCadastro

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  //Controladores para campo do formulário
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  //Estado inicial tela
  bool _senhaOculta = true;
  bool _confirmarOculta = true;
  bool _aceitouTermos = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }
  //métodos
  //mostrar mensagem na parte inferior da tela snackbar
  void _mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }
  //Estilização de todos os campos do formulário
  InputDecoration _decoracaoCampo({
    required String dica,
    required IconData icone,
    Widget? sufixo,
  }) {
    return InputDecoration(
      hintText: dica,
      prefixIcon: Icon(icone, color: _azulPrimario),
      suffixIcon: sufixo,
      filled: true,
      fillColor: _fundoCampo,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
  void _criarConta() {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final senha = _senhaController.text;

    if(nome.isEmpty || email.isEmpty || senha.isEmpty){
      _mostrarMensagem('Preencha todos os campos.');
      return;
    }
    if(!email.contains('@')){
      _mostrarMensagem('Digite um e-mail válido');
      return;
    }
    if(senha.length < 8){
      _mostrarMensagem('A senha precisa ter no mínimo 8 caracteres.');
      return;
    }
    if (!_aceitouTermos){
      _mostrarMensagem('Você precisa aceitar os Termos de Uso.');
      return;
    }
    _mostrarMensagem('Conta criada com sucesso!');
    Navigator.pop(context);
  }
}