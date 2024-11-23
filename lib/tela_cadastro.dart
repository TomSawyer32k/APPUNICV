import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  _TelaCadastroState createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _formKey = GlobalKey<FormState>();
  var _emailInserido = '';
  var _senhaInserida = '';
  var _nomeInserido = '';
  String? _mensagemErro;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref(); 

  void _enviar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailInserido,
        password: _senhaInserida,
      );

      String userType = '';

      if (_emailInserido.endsWith('@coordenador.unicv.edu.br')) {
        userType = 'coordenador';
      } else if (_emailInserido.contains('@aluno.unicv.edu.br')) {
        userType = 'alunos';
      } else if (_emailInserido.contains('@prof.unicv.edu.br')) {
        userType = 'professores';
      }

      final userTypeRef = _dbRef.child('usuarios/$userType');

      final snapshot = await userTypeRef.get();
      if (!snapshot.exists) {
        await userTypeRef.set({}); 
      }

      await userTypeRef.child(userCredential.user!.uid).set({
        'nome': _nomeInserido,
        'email': _emailInserido,
      });

      setState(() {
        _mensagemErro = 'Cadastro realizado com sucesso!';
      });

      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _mensagemErro = e.message ?? 'Erro ao realizar cadastro.';
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Cadastre-se',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Nome Completo',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira seu nome.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _nomeInserido = value!; 
                    },
                  ),
                  const SizedBox(height: 12),
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
                      if (!RegExp(r'^[a-zA-Z]+\.[0-9]{5}-[0-9]{4}@aluno\.unicv\.edu\.br$')
                              .hasMatch(value) &&
                          !RegExp(r'^[a-zA-Z]+\.[a-zA-Z]+@prof\.unicv\.edu\.br$').hasMatch(value) &&
                          !RegExp(r'^[a-zA-Z]+\.[a-zA-Z]+@coordenador\.unicv\.edu\.br$').hasMatch(value)) {
                        return 'Insira um e-mail válido institucional.';
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
                      padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.green,
                    ),
                    child: const Text('Cadastrar'),
                  ),
                  if (_mensagemErro != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        _mensagemErro!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}