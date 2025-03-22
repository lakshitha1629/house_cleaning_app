import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:house_cleaning_app/models/house.dart';
import 'package:house_cleaning_app/services/firebaseService.dart';

class ChatScreen extends StatefulWidget {
  final House house;

  const ChatScreen({Key? key, required this.house}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textCtrl = TextEditingController();
  final firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    final houseId = widget.house.id;
    if (houseId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: const Center(child: Text('Error: No valid house ID.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat - ${widget.house.title}'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // 1) Chat History
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('houses')
                  .doc(houseId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final doc = snapshot.data;
                if (doc == null || !doc.exists) {
                  return const Center(child: Text('House doc not found.'));
                }
                final data = doc.data() as Map<String, dynamic>;
                final msgs = data['messages'] as List<dynamic>? ?? [];

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: msgs.length,
                  itemBuilder: (context, index) {
                    final msg = msgs[index] as Map<String, dynamic>;
                    final senderId = msg['senderId'] ?? '';
                    final text = msg['text'] ?? '';
                    
                    // Distinguish if this is the current user's message
                    final isMe = senderId == firebaseService.currentUser?.id;

                    // Check if it's a "Review:" message
                    final isReview = text.startsWith('Review:');

                    if (isReview) {
                      return _buildReviewBubble(text);
                    } else {
                      // Normal message bubble
                      return _buildMessageBubble(text, isMe);
                    }
                  },
                );
              },
            ),
          ),

          // 2) Message input area
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Builds a normal chat bubble for non-review messages
  Widget _buildMessageBubble(String text, bool isMe) {
    return Container(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text),
      ),
    );
  }

  // Builds a special "review" card in the center of the chat
  Widget _buildReviewBubble(String text) {
    // Example text: "Review: Customer Feedback: Great job! (Rating: 4)"
    // 1) Remove "Review: "
    String displayText = text.replaceFirst('Review: ', '');

    // 2) Extract rating from something like "(Rating: 4)" or "(Rating: 4.5)"
    final ratingRegEx = RegExp(r'\(Rating:\s*([\d\.]+)\)');
    final match = ratingRegEx.firstMatch(displayText);
    double ratingValue = 0.0;
    if (match != null) {
      ratingValue = double.tryParse(match.group(1)!) ?? 0.0;
      // Also remove the "(Rating: X)" portion from the display text
      displayText = displayText.replaceRange(match.start, match.end, '').trim();
    }

    return Container(
      alignment: Alignment.center, // center in chat
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        color: Colors.orange[50],
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayText,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildStarRow(ratingValue),
            ],
          ),
        ),
      ),
    );
  }

  // Builds a row of stars for the given rating (0 - 5)
  Widget _buildStarRow(double rating) {
    // For simplicity, let's do integer-based stars only
    // If you want half-stars, you'll need more logic
    final int ratingInt = rating.round(); 
    // Build a row of 5 stars
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < ratingInt) {
          return const Icon(Icons.star, color: Colors.orange);
        } else {
          return const Icon(Icons.star_border, color: Colors.orange);
        }
      }),
    );
  }

  Future<void> _sendMessage() async {
    final text = _textCtrl.text.trim();
    _textCtrl.clear();
    if (text.isEmpty) return;

    final currentUser = firebaseService.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user signed in.')),
      );
      return;
    }

    try {
      await firebaseService.sendMessage(widget.house.id, currentUser.id, text);
    } catch (e) {
      print('Send message error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }
}
