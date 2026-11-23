import 'package:flutter/material.dart';
import 'package:playzzo/services/auth_service.dart';
import 'tela_alterar_senha.dart';
import 'tela_game_quem_sou_eu.dart';
import 'tela_jogo_impostor.dart';

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
  final _nomeController = TextEditingController(text: AuthService.usuarioAtual?.nome ?? '');
  final _emailController = TextEditingController(text: AuthService.usuarioAtual?.email ?? '');

  bool _carregando = false;
  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }
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
  Future<void> _salvar() async{
    final nome = _nomeController.text.trim();

    if (nome.isEmpty) {
      _mostrarMensagem('O nome não podem ficar vazio.');
      return;
    }
    setState(() => _carregando = true);
    try {
      await AuthService.atualizarPerfil(nome);
    _mostrarMensagem('Alterações salvas!');
    }
    on ErroApi catch (erro) {
      _mostrarMensagem(erro.mensagem);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
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
                  readOnly: true,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _decoracaoCampo(
                    icone: Icons.mail_outline
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Dados de segurança',
                  style: TextStyle(
                  color: _azulEscuro,
                  fontWeight: FontWeight.w600,
                  fontSize: 20
                  ),
                ),
                const SizedBox(height: 16),
                _rotulo('Senha'),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const TelaAlterarSenha(esqueceuSenha: false),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: _fundoCampo,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.vpn_key_outlined, color: _cinzaIcone),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Alterar senha',
                            style: TextStyle(
                              color: _azulEscuro,
                              fontSize: 16,
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
                  onPressed: _carregando ? null : _salvar,
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
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () async {
                    await AuthService.logout();
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Sair da conta'),
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
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TelaJogoImpostor()),
                  ),
                  icon: const Icon(Icons.theater_comedy),
                  label: const Text('Testar: Jogo Impostor'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

