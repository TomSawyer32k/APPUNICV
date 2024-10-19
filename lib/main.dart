import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TelaLogin());
}

class TelaLogin extends StatefulWidget {
  const TelaLogin({Key? key}) : super(key: key);

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _chaveForm = GlobalKey<FormState>();
  var _modoLogin = true;
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
      if (_modoLogin) {
      
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailInserido,
          password: _senhaInserida,
        );
        setState(() {
          _mensagem = 'Login feito com sucesso! Usuário: ${userCredential.user?.email}';
        });
      } else {
      
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailInserido,
          password: _senhaInserida,
        );
        setState(() {
          _mensagem = 'Usuário Criado: ${userCredential.user?.email}';
          _modoLogin = true; 
        });
      }
    } on FirebaseAuthException catch (e) {
      String mensagem = 'Falha na autenticação.';
      if (e.code == 'weak-password') {
        mensagem = 'A senha fornecida é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        mensagem = 'A conta já existe para esse email.';
      } else if (e.code == 'user-not-found') {
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
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.green, 
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 30, bottom: 20, left: 20, right: 20),
                  width: 200,
                  
                  child: Image.network(
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQYtHHg240d9Z6cNuwnCxratgc--TDPLvbZBppuw-jYWMUJOx4hGRe9nsiMLuK5OfG3UKQ&usqp=CAU',
                    fit: BoxFit.cover,
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _chaveForm,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(labelText: 'Endereço de Email'),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty || !value.contains('@')) {
                                  return 'Por favor, insira um endereço de email válido.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _emailInserido = value!;
                              },
                            ),
                            if (!_modoLogin)
                              TextFormField(
                                decoration: const InputDecoration(labelText: 'Nome de Usuário'),
                                enableSuggestions: false,
                                validator: (value) {
                                  if (value == null || value.isEmpty || value.trim().length < 4) {
                                    return 'Por favor, insira pelo menos 4 caracteres.';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                },
                              ),
                            TextFormField(
                              decoration: const InputDecoration(labelText: 'Senha'),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return 'A senha deve ter pelo menos 6 caracteres.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _senhaInserida = value!;
                              },
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _enviar,
                              child: Text(_modoLogin ? 'Entrar' : 'Cadastrar'),
                            ),
                            const SizedBox(height: 6),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _modoLogin = !_modoLogin;
                                  _mensagem = null; 
                                });
                              },
                              child: Text(_modoLogin ? 'Criar uma conta' : 'Já tenho uma conta'),
                            ),
                            const SizedBox(height: 12),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
