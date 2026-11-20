import 'package:flutter/material.dart';
import 'dados_usuario.dart';
import 'tela_alterar_senha.dart';
import 'tela_game_quem_sou_eu.dart';

const Color _azulPrimario = Color(0xFF1A4B9F);
const Color _azulEscuro = Color(0xFF0A1B3F);
const Color _cinzaTexto = Color(0xFF434652);
const Color _cinzaIcone = Color(0xFF737783);
const Color _fundoCampo = Color.fromARGB(255, 232, 233, 236);
const Color _rosaDestaque = Color(0xFFE8668A);

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  final _nomeController = TextEditingController(text: DadosUsuario.nome);
  final _emailController = TextEditingController(text: DadosUsuario.email);

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }
    void _mostrarMensagem(String texto) {
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
  InputDecoration _decoracaoCampo({
    required IconData icone,
    Widget? sufixo,
  }) {
    return InputDecoration(
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
  void _salvar() {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();

    if (nome.isEmpty || email.isEmpty) {
      _mostrarMensagem('Os campos não podem ficar vazios.');
      return;
    }
    if (!email.contains('@')) {
      _mostrarMensagem('Digite um e-mail válido.');
      return;
    }

    DadosUsuario.nome = nome;
    DadosUsuario.email = email;
    _mostrarMensagem('Alterações salvas!');
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sports_esports,
            color: _azulPrimario,
            size: 33,
            ),
            SizedBox(width: 8),
            Text(
              'PLAYZZO',
              style: TextStyle(
                color: _azulPrimario,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal:20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Container (
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const CircleAvatar(
                          radius: 46,
                          backgroundColor: _azulEscuro,
                          child: Icon(Icons.person,
                          color: Colors.white,
                          size: 48,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: -4,
                          child: GestureDetector(
                            onTap: () => _mostrarMensagem('teste'),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: _azulPrimario,
                                shape: BoxShape.circle,
                                border:
                                  Border.all(color: Colors.white, width: 3),
                              ),
                              child: const Icon(Icons.edit,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
                const Text(
                  'Dados pessoais',
                  style: TextStyle(
                  color: _azulEscuro,
                  fontWeight: FontWeight.w600,
                  fontSize: 20
                  ),
                ),
                const SizedBox(height: 8),
                _rotulo('Nome'),
                TextField(
                  controller: _nomeController,
                  decoration: _decoracaoCampo(
                    icone: Icons.badge_outlined
                  ),
                ),
                const SizedBox(height:16),
                _rotulo('E-mail'),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _decoracaoCampo(
                    icone: Icons.mail_outline
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Dados de segurança',
                  style: TextStyle(
                  color: _azulEscuro,
                  fontWeight: FontWeight.w600,
                  fontSize: 20
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector (
                  onTap: () {
                    Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder:(context) =>
                        const TelaAlterarSenha(esqueceuSenha: false),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _fundoCampo,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.password,
                          color: _azulPrimario,
                          size: 20,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Alterar senha',
                              style: TextStyle(
                                color: _azulEscuro,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(Icons.chevron_right, color: _azulEscuro),
                      ],
                    ),
                  ),   
                ),                
                const SizedBox(height: 50),
                SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _azulPrimario,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Atualizar perfil',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TelaQuemSouEu()),
                  ),
                  child: const Text('Testar: Quem Sou Eu'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

