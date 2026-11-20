import 'package:flutter/material.dart';
import 'package:playzzo/services/auth_service.dart';

//Já definindo as váriaveis das cores para poder reaproveitar, ver de fazer isso nas outras telas.
const Color _azulPrimario = Color(0xFF1A4B9F);
const Color _azulEscuro = Color(0xFF0A1B3F);
const Color _cinzaTexto = Color(0xFF434652);
const Color _cinzaIcone = Color(0xFF737783);
const Color _fundoCampo = Color.fromARGB(255, 232, 233, 236);
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
  final _confirmarController = TextEditingController();

  //Estado inicial tela
  bool _senhaOculta = true;
  bool _confirmarOculta = true;
  bool _carregando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }
  //métodos
  //mostrar mensagem na parte inferior da tela snackbar
  void _mostrarMensagem(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }
  Widget _rotulo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          text: texto,
          style: const TextStyle(
            color: _azulEscuro,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
  //Estilização de todos os campos do formulário
  InputDecoration _decoracaoCampo({
    required IconData icone,
    required String texto,
    Widget? sufixo,
  }) {
    return InputDecoration(
      hintText: texto,
      prefixIcon: Icon(icone, color: _cinzaIcone),
      suffixIcon: sufixo,
      filled: true,
      fillColor: _fundoCampo,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
  Future<void> _criarConta() async{
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final senha = _senhaController.text;
    final confirmar = _confirmarController.text;

    if(nome.isEmpty || email.isEmpty || senha.isEmpty || confirmar.isEmpty){
      _mostrarMensagem('Preencha todos os campos.');
      return;
    }
    if(!email.contains('@')){
      _mostrarMensagem('Digite um e-mail válido');
      return;
    }
    if (senha != confirmar) {
      _mostrarMensagem('AS senhas não coincidem');
      return;
    }
    if(senha.length < 8){
      _mostrarMensagem('A senha precisa ter no mínimo 8 caracteres.');
      return;
    }
    setState(() => _carregando = true);
    try {
      await AuthService.cadastrar(nome, email, senha);
    //Cadastro deu certo, ele vai voltar para tela de login, conforme última página da pilha
    _mostrarMensagem('Conta criada com sucesso!');
    if (mounted) Navigator.pop(context);
    }
    on ErroApi catch (erro){
      _mostrarMensagem(erro.mensagem);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Appbar como icon e nome do sistema
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          //clicou na flecha de voltar, ele volta para a primeira página pilha
          icon: const Icon(
            Icons.arrow_back,
            color: _azulEscuro
            ),
          onPressed:() => Navigator.maybePop(context),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sports_esports,
              color: _azulPrimario,
              size: 33
            ),
            SizedBox(width: 8),
            Text(
              'PLAYZZO',
              style: TextStyle(
                color: _azulPrimario,
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
      ),
      //Body iniciando com os textos de apresentação e partindo para o formulário
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Criar conta',
                  style: TextStyle(
                    color: _azulEscuro,
                    fontWeight: FontWeight.w800,
                    fontSize: 26
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Crie seu perfil e reúna com os seus amigos para jogar no mesmo dispositivo.',
                  style: TextStyle(
                    color: _cinzaTexto,
                    fontSize: 15,
                    height: 1.5
                  ),
                ),
                const SizedBox(height: 20),

                //Iniciando formulário
                _rotulo('Nome'),
                TextField(
                  controller: _nomeController,
                  decoration: _decoracaoCampo(
                    texto: 'Marcus...',
                    icone: Icons.badge_outlined,
                  ),
                ),
                const SizedBox(height: 16),

                _rotulo('E-mail'),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _decoracaoCampo(
                    texto:  'seuemail@exemplo.com',
                    icone: Icons.mail_outline
                  ),
                ),
                const SizedBox(height: 16),

                _rotulo('Senha'),
                TextField(
                  controller: _senhaController,
                  obscureText: _senhaOculta,
                  decoration: _decoracaoCampo(
                    texto: 'Sua senha',
                    icone: Icons.lock_outline,
                    sufixo: IconButton(
                      icon: Icon(
                        _senhaOculta ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      //clicou _senhaOculta que estava true fica diferente de true, portanto false, então a senha fica visível
                      onPressed:() => 
                        setState(() => _senhaOculta = !_senhaOculta),
                    ),
                  ),
                ),
                                const SizedBox(height: 16),
                _rotulo('Confirmar senha'),
                TextField(
                  controller: _confirmarController,
                  obscureText: _confirmarOculta,
                  decoration: _decoracaoCampo(
                    texto: 'Repita sua senha',
                    icone: Icons.check_circle_outline,
                    sufixo: IconButton(
                      icon: Icon(
                        _confirmarOculta ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () =>
                          setState(() => _confirmarOculta = !_confirmarOculta),
                    ),
                  ),
                ),
                const SizedBox(height: 50),

                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _carregando ? null : _criarConta,
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: _azulPrimario,
                        backgroundColor: _azulPrimario,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                      child: _carregando
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                    : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Criar Minha Conta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Já possui uma conta?',
                      style: TextStyle(color: _cinzaTexto, fontSize: 14),
                    ),
                    TextButton(
                      onPressed:() => Navigator.pop(context),
                      child: const Text(
                        'Fazer login',
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),
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