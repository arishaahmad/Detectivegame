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

class Email {
  final String from;
  final String subject;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String? imageAttachmentAsset;

  Email({
    required this.from,
    required this.subject,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.imageAttachmentAsset,
  });

  Email copyWith({bool? isRead}) {
    return Email(
      from: from,
      subject: subject,
      body: body,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      imageAttachmentAsset: imageAttachmentAsset,
    );
  }
}
