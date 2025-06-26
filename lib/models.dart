// lib/models.dart

class Contact {
  String id;
  String name;
  final String number;
  final String avatarAsset;

  Contact({
    required this.id,
    this.name = 'Unknown',
    required this.number,
    required this.avatarAsset,
  });
}

class ChatMessage {
  final String senderId;
  final String text;
  final DateTime timestamp;
  final String? imageAttachmentAsset;

  ChatMessage({
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.imageAttachmentAsset,
  });
}

class Conversation {
  final String id;
  final List<String> participantIds;
  final List<ChatMessage> messages;

  Conversation({
    required this.id,
    required this.participantIds,
    required this.messages,
  });
}
