import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatAluno extends StatefulWidget {
  const ChatAluno({super.key});

  @override
  _ChatAlunoState createState() => _ChatAlunoState();
}

class _ChatAlunoState extends State<ChatAluno> {
  final DatabaseReference _messagesRef =
      FirebaseDatabase.instance.ref().child('chats/mensagens/mensagens');
  List<Map<dynamic, dynamic>> _messages = [];
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String _nome = 'Nome não disponível';
  String _email = 'Email não disponível';
  final String _photoURL = 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSaMobjNkxrRxHsbQ6MpCqfg2j2XJYKk9-UGQ&s'; 

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotifications();
    _loadMessages();
    _loadUserData();
  }

  void _loadUserData() async {
    _user = _auth.currentUser;

    if (_user != null) {
      final userRef = FirebaseDatabase.instance.ref().child('usuarios/${_user!.uid}');
      userRef.once().then((snapshot) {
        final userData = snapshot.snapshot.value as Map<dynamic, dynamic>?;
        if (userData != null) {
          setState(() {
            _email = userData['email'] ?? 'Email não disponível';
            _nome = userData['nome'] ?? 'Nome não disponível';
          });
        }
      });
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _loadMessages() {
    _messagesRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        setState(() {
          _messages = data.entries
              .map((e) => e.value as Map<dynamic, dynamic>)
              .where((message) =>
                  message['autor'] == 'Coordenador' &&
                  (message['destinatario'] == 'todos' || message['destinatario'] == 'alunos'))
              .toList();
        });

        _showNotificationForMessages(data);
      }
    });
  }

  void _showNotificationForMessages(Map<dynamic, dynamic> data) {
    for (var message in data.values) {
      if (message['autor'] == 'Coordenador') {
        _showNotification(
          title: 'Mensagem do Coordenador',
          body: message['texto'] ?? 'Mensagem sem conteúdo',
        );
      }
    }
  }

  Future<void> _showNotification({required String title, required String body}) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0, 
      title,
      body, 
      platformDetails,
      payload: 'message', 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat para Alunos')),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_nome),
              accountEmail: Text(_email),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(_photoURL),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _messages.isEmpty
          ? const Center(child: Text('Nenhuma mensagem disponível'))
          : ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final timestamp = message['timestamp'] != null
                    ? DateTime.fromMillisecondsSinceEpoch(message['timestamp']).toString()
                    : 'Sem hora';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      message['texto'] ?? 'Mensagem sem conteúdo',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Enviado por: ${message['autor'] ?? 'Desconhecido'}'),
                        Text(
                          'Hora: $timestamp',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
