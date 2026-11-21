//Inserindo bibliotecas
import 'package:flutter/material.dart';
import 'tela_cadastro.dart';
import 'tela_perfil.dart';
import 'package:playzzo/services/auth_service.dart';
import 'tela_alterar_senha.dart';

const Color _azulPrimario = Color(0xFF1A4B9F);

//Criando a classe TelaLogin
class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  bool _senhaOculta = true;
  bool _lembrarAparelho = true;
  bool _carregando = false;

  //Mostra a mensagem na parte inferior da tela
  void _mostrarMensagem(String texto){
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  //Executa quando clica em "Entrar na Festa"
  Future<void> _entrar() async{
    final email = _emailController.text.trim();
    final senha = _senhaController.text;
  //Chama o método mostrar mensagem
  //Fazer mais verificações nesse if
    if(email.isEmpty || senha.isEmpty){
      _mostrarMensagem('Preencha todos os campos.');
      return;
    }
    if(!email.contains('@')){
      _mostrarMensagem('Digite um e-mail válida.');
      return;
    }
    setState(() => _carregando = true);
    try {
      await AuthService.login(email, senha);
      if (!mounted) return;
      Navigator.push(
      context,
      MaterialPageRoute(builder:(context) => const TelaPerfil()
        ),
      );
    }
    on ErroApi catch(erro) {
      _mostrarMensagem(erro.mensagem);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }
  
  //Controlador do campo de e-mail e senha 
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _senhaController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //barra de aplicativos
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true, //Alinha esse widget todo ao centro

        title: const Row(
          mainAxisSize: MainAxisSize.min, //ocupa o mínimo de espaço e atua junto com o centerTitle

          children: [
            Icon(
              Icons.sports_esports,
              color: Color(0xFF1A4B9F),
              size: 33,
            ),
            SizedBox(width: 8), //Esse sized box vai delimitar o espaço do ícone
            Text('PLAYZZO',
                style: TextStyle(
                    color: Color(0xFF1A4B9F), //cor padrão
                    fontWeight: FontWeight.bold //fonte em negrito
                    ))
          ],
        ),
      ),

      //Iniciando estrutura
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //Seção de boas vindas
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Bem-vindo de volta',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFF0A1B3F),
                          fontSize: 28,
                          fontWeight: FontWeight.w800),
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
                  ],
                ),

                const SizedBox(height: 24),

                //Email
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text(
                    'E-mail',
                    style: TextStyle(
                      color: Color(0xFF0A1B3F),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'seuemail@exemplo.com',
                      prefixIcon: const Icon(
                        Icons.mail_outline,
                        color: Color(0xFF737783),
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 232, 233, 236),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 16), // Adicionado espaçamento entre os campos

                //Senha
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Senha',
                        // CORRIGIDO: Cor alterada de cinza claro para a cor escura correta
                        style: TextStyle(
                          color: Color(0xFF0A1B3F),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _senhaController,
                    obscureText: _senhaOculta,
                    decoration: InputDecoration(
                      hintText: 'Sua senha',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF737783),
                      ),
                      // ADICIONADO: Ícone funcional para alternar a visibilidade da senha
                      suffixIcon: IconButton(
                        icon: Icon(
                          _senhaOculta ? Icons.visibility_off : Icons.visibility,
                          color: const Color(0xFF737783),
                        ),
                        onPressed: () {
                          setState(() {
                            _senhaOculta = !_senhaOculta;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 232, 233, 236),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 6),
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:(context) => const TelaAlterarSenha(esqueceuSenha: true),
                            ),
                          );
                        },
                        child: const Text(
                          'Esqueci a senha',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                //checkbox para lembrar deste aparelho
                Row(
                  children: [
                    Checkbox(
                      value: _lembrarAparelho,
                      activeColor: const Color(0xFF1A4B9F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (valor) {
                        setState(() {
                          _lembrarAparelho = valor ?? false;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'Lembrar deste aparelho',
                        style: TextStyle(color: Color(0xFF0A1B3F), fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                //Botão para entrar no aplicativo, entrar na festa
                //Aqui está chamando o método _entrar
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _carregando ? null : _entrar,
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: _azulPrimario,
                      backgroundColor: const Color(0xFF1A4B9F),
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
                          'Entrar',
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
                //Parte para a tela de cadastro, caso o usuário não tenha login
                Row (
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Ainda não tem uma conta?',
                      style: TextStyle(
                        color: Color(0xFF434652),
                        fontSize:14,
                      ),
                    ),
                      //Aqui fica o clicável Cadastra-se
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder:(context) => const TelaCadastro()),
                          );
                        },
                        child: const Text(
                          'Cadastrar-se',
                          style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}