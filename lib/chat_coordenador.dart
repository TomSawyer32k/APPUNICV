import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatCoordenador extends StatefulWidget {
  const ChatCoordenador({super.key});

  @override
  _ChatCoordenadorState createState() => _ChatCoordenadorState();
}

class _ChatCoordenadorState extends State<ChatCoordenador> {
  final DatabaseReference _messagesRef =
      FirebaseDatabase.instance.ref().child('chats/mensagens');
  final TextEditingController _messageController = TextEditingController();
  String _selectedDestinatario = 'todos'; 
  List<Map<dynamic, dynamic>> _messages = []; 
  String? _nomeUsuario = "Coordenador"; 
  String? _emailUsuario = "coordenador@unicv.edu.br"; 
  String? _messageIdToEdit; 

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    _messagesRef.child('mensagens').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        setState(() {
          _messages = data.entries
              .map((e) {
                var message = e.value as Map<dynamic, dynamic>;
                message['id'] = e.key; 
                return message;
              })
              .toList();
          _messages.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
        });
      }
    });
  }

  void _sendMessage() async {
    String messageText = _messageController.text.trim();

    if (messageText.isNotEmpty) {
      final messageData = {
        'texto': messageText,
        'autor': 'Coordenador',
        'destinatario': _selectedDestinatario,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      if (_messageIdToEdit != null) {
        await _messagesRef.child('mensagens').child(_messageIdToEdit!).update(messageData);
        setState(() {
          _messageIdToEdit = null;
        });
      } else {
        await _messagesRef.child('mensagens').push().set(messageData);
      }

      _messageController.clear();
    }
  }

  void _deleteMessage(String messageId) async {
    await _messagesRef.child('mensagens').child(messageId).remove();
  }

  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/'); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat do Coordenador')),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_nomeUsuario ?? "Usuário"),
              accountEmail: Text(_emailUsuario ?? "E-mail não encontrado"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  (_nomeUsuario?.substring(0, 1) ?? "C").toUpperCase(),
                  style: const TextStyle(fontSize: 40.0, color: Colors.green),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isNotEmpty
                ? ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final timestamp = DateTime.fromMillisecondsSinceEpoch(
                          message['timestamp']);
                      final formattedTime = '${timestamp.hour}:${timestamp.minute}';
                      final messageId = message['id'];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Text(
                            message['texto'] ?? 'Mensagem sem conteúdo',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Enviado para: ${message['destinatario']}'),
                              Text(
                                'Hora: $formattedTime',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _messageController.text = message['texto'] ?? '';
                                  setState(() {
                                    _messageIdToEdit = messageId;
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteMessage(messageId),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text('Nenhuma mensagem enviada ainda.'),
                  ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    labelText: 'Escreva sua mensagem',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton<String>(
                      value: _selectedDestinatario,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedDestinatario = newValue!;
                        });
                      },
                      items: <String>['todos', 'alunos', 'professores']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value.capitalize()),
                        );
                      }).toList(),
                    ),
                    ElevatedButton(
                      onPressed: _sendMessage,
                      child: const Text('Enviar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension StringCapitalize on String {
  String capitalize() {
    return this[0].toUpperCase() + this.substring(1).toLowerCase();
  }
}
