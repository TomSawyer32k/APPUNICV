import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'chat_coordenador.dart'; 

class LoginCoordenador extends StatefulWidget {
  const LoginCoordenador({super.key});

  @override
  _LoginCoordenadorState createState() => _LoginCoordenadorState();
}

class _LoginCoordenadorState extends State<LoginCoordenador> {
  final _auth = FirebaseAuth.instance;
  final _dbRef = FirebaseDatabase.instance.ref();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  String _mensagemErro = '';

  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _senhaController.text,
      );

      final user = userCredential.user;
      final snapshot = await _dbRef.child('usuarios/coordenador/${user!.uid}').get();

      if (snapshot.exists) {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatCoordenador(), 
          ),
        );
      } else {
        setState(() {
          _mensagemErro = 'Você não é um coordenador.';
        });
      }
    } catch (e) {
      setState(() {
        _mensagemErro = 'Erro ao fazer login: $e';
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
                  'Login como Coordenador',
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
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Institucional',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _senhaController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Entrar como Coordenador'),
                      ),
                      if (_mensagemErro.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text(
                          _mensagemErro,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ]
                    ],
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
