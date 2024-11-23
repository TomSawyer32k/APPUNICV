import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_professor.dart'; 

class TelaLoginProfessor extends StatefulWidget {
  const TelaLoginProfessor({super.key});

  @override
  _TelaLoginProfessorState createState() => _TelaLoginProfessorState();
}

class _TelaLoginProfessorState extends State<TelaLoginProfessor> {
  final _chaveForm = GlobalKey<FormState>();
  var _emailInserido = '';
  var _senhaInserida = '';
  String? _mensagem;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _enviar() async {
    if (!_chaveForm.currentState!.validate()) {
      return;
    }

    _chaveForm.currentState!.save();

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailInserido,
        password: _senhaInserida,
      );

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final email = user.email ?? "";
        if (email.endsWith('@prof.unicv.edu.br')) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const ChatProfessor(),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String mensagem = 'Falha na autenticação.';
      if (e.code == 'user-not-found') {
        mensagem = 'Nenhum usuário encontrado com esse email.';
      } else if (e.code == 'wrong-password') {
        mensagem = 'Senha incorreta.';
      }
      setState(() {
        _mensagem = mensagem;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Login como Professor',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(20),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _chaveForm,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Email Institucional',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira um email.';
                              }
                              if (!RegExp(r'^[a-zA-Z]+\.[a-zA-Z]+@prof\.unicv\.edu\.br$').hasMatch(value)) {
                                return 'Insira um e-mail válido de professor.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _emailInserido = value!;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Senha',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return 'A senha deve ter pelo menos 6 caracteres.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _senhaInserida = value!;
                            },
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _enviar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Entrar como Professor'),
                          ),
                          if (_mensagem != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Text(
                                _mensagem!,
                                style: const TextStyle(color: Colors.red, fontSize: 16),
                              ),
                            ),
                        ],
                      ),
                    ),
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
