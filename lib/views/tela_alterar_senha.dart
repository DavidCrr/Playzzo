import 'package:flutter/material.dart';
import 'package:playzzo/services/auth_service.dart';

const Color _azulPrimario = Color(0xFF1A4B9F);
const Color _azulEscuro = Color(0xFF0A1B3F);
const Color _cinzaTexto = Color(0xFF434652);
const Color _cinzaIcone = Color(0xFF737783);
const Color _fundoCampo = Color.fromARGB(255, 232, 233, 236);

class TelaAlterarSenha extends StatefulWidget {
  // true  = veio do login ("Esqueceu a senha?")
  // false = veio do perfil (usuário já está logado)
  final bool esqueceuSenha;

  const TelaAlterarSenha({super.key, required this.esqueceuSenha});

  @override
  State<TelaAlterarSenha> createState() => _TelaAlterarSenhaState();
}

class _TelaAlterarSenhaState extends State<TelaAlterarSenha> {
  final _emailController = TextEditingController();
  final _senhaAtualController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarController = TextEditingController();

  bool _senhasOcultas = true;
  bool _carregando = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _confirmarController.dispose();
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
      child: Text(
        texto,
        style: const TextStyle(
          color: _azulEscuro,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _decoracaoCampo({
    required String dica,
    required IconData icone,
    Widget? sufixo,
  }) {
    return InputDecoration(
      hintText: dica,
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

  // Ícone de olho (reaproveitado nos campos de senha)
  Widget _botaoOlho() {
    return IconButton(
      icon: Icon(
        _senhasOcultas ? Icons.visibility_off : Icons.visibility,
        color: _cinzaIcone,
      ),
      onPressed: () => setState(() => _senhasOcultas = !_senhasOcultas),
    );
  }

  Future<void> _alterarSenha() async{
    final novaSenha = _novaSenhaController.text;
    final confirmar = _confirmarController.text;
  
    // Verificações iguais para os dois casos
    if (novaSenha.length < 8) {
      _mostrarMensagem('A nova senha precisa ter no mínimo 8 caracteres.');
      return;
    }
    if (novaSenha != confirmar) {
      _mostrarMensagem('As senhas não coincidem.');
      return;
    }

    setState(() => _carregando = true);
    try{
      if(widget.esqueceuSenha) {
        await AuthService.redefinirSenha(
          _emailController.text.trim(), novaSenha
        );
      } else {
        await AuthService.alterarSenha(
          _senhaAtualController.text, novaSenha
        );
      }
    _mostrarMensagem('Senha alterada com sucesso!');
    if (mounted) Navigator.pop(context);
    }
    on ErroApi catch (erro) {
      _mostrarMensagem(erro.mensagem);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                Text(
                  widget.esqueceuSenha
                      ? 'Informe o e-mail da sua conta e escolha uma nova senha.'
                      : 'Confirme sua senha atual e escolha uma nova senha.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _cinzaTexto,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                // Primeiro campo: muda conforme a origem
                if (widget.esqueceuSenha) ...[
                  _rotulo('E-mail da conta'),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _decoracaoCampo(
                      dica: 'seuemail@exemplo.com',
                      icone: Icons.mail_outline,
                    ),
                  ),
                ] else ...[
                  _rotulo('Senha atual'),
                  TextField(
                    controller: _senhaAtualController,
                    obscureText: _senhasOcultas,
                    decoration: _decoracaoCampo(
                      dica: 'Digite sua senha atual',
                      icone: Icons.lock_outline,
                      sufixo: _botaoOlho(),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                _rotulo('Nova senha'),
                TextField(
                  controller: _novaSenhaController,
                  obscureText: _senhasOcultas,
                  decoration: _decoracaoCampo(
                    dica: 'Mínimo 6 caracteres',
                    icone: Icons.lock_outline,
                    sufixo: _botaoOlho(),
                  ),
                ),

                const SizedBox(height: 16),

                _rotulo('Confirmar nova senha'),
                TextField(
                  controller: _confirmarController,
                  obscureText: _senhasOcultas,
                  decoration: _decoracaoCampo(
                    dica: 'Repita a nova senha',
                    icone: Icons.check_circle_outline,
                    sufixo: _botaoOlho(),
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _carregando ? null : _alterarSenha,
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
                    : const Text(
                      'Salvar nova senha',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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