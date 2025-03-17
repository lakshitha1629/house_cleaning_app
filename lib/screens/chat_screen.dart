import 'package:flutter/material.dart';
import 'package:house_cleaning_app/models/house.dart';
import 'package:house_cleaning_app/services/mock_data_service.dart';

class ChatScreen extends StatefulWidget {
  final House house;

  const ChatScreen({Key? key, required this.house}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textCtrl = TextEditingController();
  final mockService = MockDataService();

  void _sendMessage() {
    final text = _textCtrl.text.trim();
    if (text.isNotEmpty) {
      mockService.sendMessage(widget.house.id, mockService.currentUser!.id, text);
      _textCtrl.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.house.messages;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat: ${widget.house.title}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (ctx, i) {
                final msg = messages[i];
                final isMe = msg['senderId'] == mockService.currentUser?.id;
                final senderId = msg['senderId'];
                final text = msg['text'] ?? '';
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('$senderId: $text'),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

