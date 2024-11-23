import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'tela_login_aluno.dart';
import 'tela_login_professor.dart';
import 'login_coordenador.dart';
import 'tela_cadastro.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const AppUnicv());
}

class AppUnicv extends StatelessWidget {
  const AppUnicv({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const TelaEscolhaLogin(),
      routes: {
        '/login_coordenador': (context) => const LoginCoordenador(),
        '/login_aluno': (context) => const TelaLoginAluno(),
        '/login_professor': (context) => const TelaLoginProfessor(),
        '/cadastro': (context) => const TelaCadastro(),
      },
    );
  }
}

class TelaEscolhaLogin extends StatefulWidget {
  const TelaEscolhaLogin({super.key});

  @override
  _TelaEscolhaLoginState createState() => _TelaEscolhaLoginState();
}

class _TelaEscolhaLoginState extends State<TelaEscolhaLogin> {
  void _navigateToLogin(BuildContext context, String userType) {
    
    switch (userType) {
      case 'Aluno':
        Navigator.pushNamed(context, '/login_aluno');
        break;
      case 'Professor':
        Navigator.pushNamed(context, '/login_professor');
        break;
      case 'Coordenador':
        Navigator.pushNamed(context, '/login_coordenador');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
              Image.network(
                'https://unicv.curitiba.br/wp-content/uploads/2023/05/cropped-FAVICON.png',
                height: 150,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child; 
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    ); 
                  }
                },
              ),
              const SizedBox(height: 100), 
              const Text(
                'Bem-vindo ao App UniCV!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 30),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Escolha o tipo de usuário',
                ),
                items: const [
                  DropdownMenuItem(value: 'Aluno', child: Text('Aluno')),
                  DropdownMenuItem(value: 'Professor', child: Text('Professor')),
                  DropdownMenuItem(value: 'Coordenador', child: Text('Coordenador')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _navigateToLogin(context, value);
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/cadastro');
                },
                icon: const Icon(Icons.app_registration),
                label: const Text('Cadastrar-se'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
