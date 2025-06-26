// lib/game_state.dart

import 'package:flutter/material.dart';
import 'models.dart';

class GameState with ChangeNotifier {
  String? detectiveName;
  final List<Contact> _contacts = [];
  final List<Conversation> _conversations = [];

  GameState() { _initializeGameData(); }

  List<Conversation> get conversations => _conversations;
  Contact getContact(String id) => _contacts.firstWhere((c) => c.id == id, orElse: () => Contact(id: '0', number: 'Error', avatarAsset: ''));

  void _initializeGameData() {
    var officer = Contact(id: '1', name: 'Unknown', number: '555-0123', avatarAsset: 'assets/officer_lanchester.png');
    _contacts.add(officer);

    _conversations.add(
        Conversation(id: 'conv1', participantIds: ['player', '1'], messages: [
          ChatMessage(
            senderId: '1',
            text: "Detective. Got a hold of Eleanor's personal data. This isn't official, so keep it that way. You'll find what you need in her emails. Be careful who you talk to.",
            timestamp: DateTime.now(),
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
}