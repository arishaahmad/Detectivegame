// lib/screens/messaging_screens.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_state.dart';
import '../models.dart';
import '../widgets/widgets.dart';
import 'splash_screen.dart';

class MessagesListScreen extends StatelessWidget {
  const MessagesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final conversations = context.watch<GameState>().conversations;
    final gameState = context.watch<GameState>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Messages", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView.separated(
        itemCount: conversations.length,
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 80),
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          final contactId = conversation.participantIds.firstWhere((id) => id != 'player');
          final contact = gameState.getContact(contactId);
          final lastMessage = conversation.messages.last;

          return ListTile(
            leading: CircleAvatar(backgroundImage: AssetImage(contact.avatarAsset), radius: 28),
            title: Text(contact.name, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            subtitle: Text(
              lastMessage.text,
              style: TextStyle(color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(conversation: conversation)));
            },
          );
        },
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  final Conversation conversation;
  const ChatScreen({super.key, required this.conversation});

  void _showAddContactDialog(BuildContext context, Contact contact) {
    final nameController = TextEditingController(text: "Officer Lanchester");
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Add to Contacts"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: "Enter name..."),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Provider.of<GameState>(context, listen: false).saveContact(contact.id, nameController.text.trim());

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const EpisodeSplashScreen()),
                      (Route<dynamic> route) => false,
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      color: Colors.grey[100],
      child: Row(
        children: [
          IconButton(icon: Icon(Icons.photo_camera, color: Colors.grey[500]), onPressed: () {}),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const TextField(
                enabled: false,
                decoration: InputDecoration(
                  hintText: "Message",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          IconButton(icon: Icon(Icons.send, color: Colors.blue), onPressed: () {}),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final contactId = conversation.participantIds.firstWhere((id) => id != 'player');
    final contact = gameState.getContact(contactId);
    final showReplyOptions = gameState.showLanchesterReplyOptions && conversation.id == 'conv1';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: GestureDetector(
          onTap: () {
            if (contact.name == 'Unknown') {
              _showAddContactDialog(context, contact);
            }
          },
          child: Row(
            children: [
              CircleAvatar(backgroundImage: AssetImage(contact.avatarAsset)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contact.name, style: const TextStyle(fontSize: 16, color: Colors.black)),
                  if (contact.name == 'Unknown')
                    Text(contact.number, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              )
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(8.0),
              itemCount: conversation.messages.length,
              itemBuilder: (context, index) {
                final message = conversation.messages.reversed.toList()[index];
                final isFromPlayer = message.senderId == 'player';
                return ChatBubble(message: message, isFromPlayer: isFromPlayer);
              },
            ),
          ),
          if (showReplyOptions)
            ReplyOptionsWidget(
              onReplySelected: (text) {
                Provider.of<GameState>(context, listen: false).sendPlayerReply(text);
              },
            )
          else
            _buildMessageComposer(),
        ],
      ),
    );
  }
}