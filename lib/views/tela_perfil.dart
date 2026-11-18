import 'package:flutter/material.dart';

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
  final _nomeController = TextEditingController(text: 'Nome de teste');
  final _emailController = TextEditingController(text: 'emailteste@gmail.com');

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
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
    if (_nomeController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      _mostrarMensagem('Os campos não podem ficar vazios.');
      return;
    }
    setState(() {});
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
            SizedBox(height: 8),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

