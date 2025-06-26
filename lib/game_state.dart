// lib/game_state.dart

import 'package:flutter/material.dart';
import 'models.dart';

class GameState with ChangeNotifier {
  String? detectiveName;
  final List<Contact> _contacts = [];
  final List<Conversation> _conversations = [];
  final List<Email> _emails = [];
  bool emailsReceived = false;
  bool showLanchesterReplyOptions = false;

  GameState() { _initializeGameData(); }

  List<Conversation> get conversations => _conversations;
  List<Email> get emails => _emails;
  int get unreadEmailCount => _emails.where((e) => !e.isRead).length;

  Contact getContact(String id) => _contacts.firstWhere((c) => c.id == id, orElse: () => Contact(id: '0', number: 'Error', avatarAsset: ''));

  void _initializeGameData() {
    var officer = Contact(id: '1', name: 'Unknown', number: '555-0123', avatarAsset: 'assets/officer_lanchester.png');
    _contacts.add(officer);

    _conversations.add(
        Conversation(id: 'conv1', participantIds: ['player', '1'], messages: [
          ChatMessage(
            senderId: '1',
            text: "Detective. Got a hold of Eleanor's personal data. This isn't official, so keep it that way. You'll find what you need in her emails. Be careful who you talk to.",
            timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
            imageAttachmentAsset: 'assets/eleanor_vance.png',
          )
        ],
        )
    );
  }

  void submitName(String name) {
    detectiveName = name;
    notifyListeners();
  }

  void saveContact(String contactId, String newName) {
    try {
      final contact = _contacts.firstWhere((c) => c.id == contactId);
      contact.name = newName;
      notifyListeners();
    } catch (e) { print("Error saving contact: $e"); }
  }

  void markEmailAsRead(Email email) {
    final index = _emails.indexOf(email);
    if (index != -1 && !_emails[index].isRead) {
      _emails[index] = email.copyWith(isRead: true);
      notifyListeners();
    }
  }

  void triggerLanchesterFollowUp() {
    final conversation = _conversations.firstWhere((c) => c.id == 'conv1');
    conversation.messages.add(
        ChatMessage(
          senderId: '1',
          text: "Did you recieve the emails?",
          timestamp: DateTime.now(),
        )
    );
    showLanchesterReplyOptions = true;
    notifyListeners();
  }

  void sendPlayerReply(String text) {
    final conversation = _conversations.firstWhere((c) => c.id == 'conv1');
    conversation.messages.add(
        ChatMessage(
          senderId: 'player',
          text: text,
          timestamp: DateTime.now(),
        )
    );
    showLanchesterReplyOptions = false;
    notifyListeners();
  }

  void receiveForwardedEmails() {
    if (emailsReceived) return;

    final newEmails = [
      Email(
          from: "Just Me <no-sender-id@proton.me>",
          subject: "That little cafe",
          timestamp: DateTime.now().subtract(const Duration(days: 90)),
          body: "Ellie,\n\nStill think about that rainy afternoon at 'The Daily Grind'. The way you looked when you were arguing with the barista about the temperature of his steamed milk... classic Eleanor. A force of nature.\n\nHope you're taking over the world, one courtroom at a time. Miss that fire.\n\n- J"
      ),
      Email(
          from: "Vista Realty <no-reply@vistarealty-deals.com>",
          subject: "Your Dream Home Awaits! Unbeatable Prices in Northwood.",
          timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
          imageAttachmentAsset: 'assets/real_estate_ad.png',
          body: "Dear Eleanor Vance,\n\nAre you tired of the city bustle? Imagine waking up to serene landscapes and tranquil surroundings. At Vista Realty, we turn dreams into addresses. We are excited to present an exclusive, limited-time offer on our new luxury developments in the prestigious Northwood district. These stunning properties offer the perfect blend of modern architecture and natural beauty.\n\nDon't miss this opportunity to invest in a lifestyle of comfort and elegance. Our team is ready to arrange a private viewing at your convenience.\n\nClick here to explore our portfolio or schedule a visit.\n\nSincerely,\nThe Vista Realty Team"
      ),
      Email(
          from: "Maya Singh <m.singh.intern@jenningslaw.com>",
          subject: "Thank You",
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
          body: "Dear Ms. Vance,\n\nI hope this email finds you well.\n\nAs my internship at Jennings & Associates comes to a close, I wanted to take a moment to express my sincere gratitude for the opportunity to work under your guidance. The experience has been incredibly insightful, and I've learned more in these past few months than in any of my law school classes.\n\nYour dedication, sharp legal mind, and the way you command a courtroom are truly inspiring. Observing you prepare for the Ashford case was a masterclass in itself. Thank you for taking the time to answer my questions and for entrusting me with meaningful work.\n\nI wish you the very best, both personally and professionally. I hope our paths cross again in the future.\n\nWarmly,\nMaya Singh\nLegal Intern"
      ),
      Email(
          from: "S.M. <private@securemail.net>",
          subject: "Our Arrangement",
          timestamp: DateTime.now().subtract(const Duration(hours: 18)),
          body: "Eleanor,\n\nI trust you've had time to reflect on our last conversation. I was very pleased to hear you've decided to see things our way. It shows you're a reasonable woman who understands how delicate certain situations can be.\n\nCooperation is a two-way street. You help us, we help you. It's simple. Let's ensure there are no... misunderstandings... moving forward. My associates value loyalty and discretion above all else. They are not as forgiving as I am when it comes to loose ends.\n\nConsider this a confirmation of our mutual understanding. We will be in touch regarding the next steps. Don't do anything to jeopardize this newfound partnership.\n\n- S.M."
      ),
      Email(
          from: "Arthur Jennings <a.jennings@jenningslaw.com>",
          subject: "URGENT: The Ashford Case - Physical Evidence",
          timestamp: DateTime.now().subtract(const Duration(hours: 12)),
          body: "Eleanor,\n\nFollowing up on our conversation this morning. I need a final decision on the physical evidence against Dr. Ashford. I know you've been hesitant to use it, citing concerns about its chain of custody. However, the prosecution is weak on motive, and this could be the key to securing a conviction.\n\nThe trial starts tomorrow, and I can't have you going in undecided. The partners are getting nervous, and the firm's reputation is on the line with this one. Are you presenting the evidence, or are we proceeding without it?\n\nI need your official stance by end of day. No more delays.\n\nRegards,\nArthur Jennings\nSenior Partner\nJennings & Associates"
      )
    ];

    _emails.addAll(newEmails);
    _emails.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    emailsReceived = true;
    notifyListeners();
  }
}
