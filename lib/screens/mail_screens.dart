// lib/screens/mail_screens.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_state.dart';
import '../models.dart';
import 'package:intl/intl.dart';

class MailListScreen extends StatelessWidget {
  const MailListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emails = context.watch<GameState>().emails;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Inbox", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: emails.isEmpty
          ? const Center(child: Text("No mail."))
          : ListView.separated(
        itemCount: emails.length,
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 80),
        itemBuilder: (context, index) {
          final email = emails[index];
          final isUnread = !email.isRead;
          return ListTile(
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.transparent,
              child: isUnread
                  ? const CircleAvatar(radius: 5, backgroundColor: Colors.blue)
                  : const CircleAvatar(radius: 28, backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
            ),
            title: Text(email.from, style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.normal)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(email.subject, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(email.body, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            isThreeLine: true,
            trailing: Text(DateFormat('MMM d').format(email.timestamp)),
            onTap: () {
              Provider.of<GameState>(context, listen: false).markEmailAsRead(email);
              Navigator.push(context, MaterialPageRoute(builder: (_) => MailDetailScreen(email: email)));
            },
          );
        },
      ),
    );
  }
}

// MailDetailScreen remains the same
class MailDetailScreen extends StatelessWidget {
  final Email email;
  const MailDetailScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email.subject, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.person, color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(email.from, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("to me", style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
                Text(
                  DateFormat('MMM d, yyyy, h:mm a').format(email.timestamp),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const Divider(height: 32),
            if (email.imageAttachmentAsset != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(email.imageAttachmentAsset!),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              email.body,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}