// lib/widgets/widgets.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import '../models.dart';

class NotificationPopup extends StatelessWidget {
  final Contact sender;
  final ChatMessage message;
  final VoidCallback onOpen;

  const NotificationPopup({super.key, required this.sender, required this.message, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(children: [
        CircleAvatar(backgroundImage: AssetImage(sender.avatarAsset)),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("New Message", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(sender.name == 'Unknown' ? sender.number : sender.name, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ]),
      ]),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message.text, style: const TextStyle(color: Colors.black87)),
          if (message.imageAttachmentAsset != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(message.imageAttachmentAsset!),
            ),
          ]
        ],
      ),
      actions: [
        TextButton(onPressed: onOpen, child: const Text("Open Messages")),
      ],
    );
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isFromPlayer;
  const ChatBubble({super.key, required this.message, required this.isFromPlayer});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isFromPlayer ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isFromPlayer ? Colors.blue : const Color(0xFFE9E9EB),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: isFromPlayer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(message.text, style: TextStyle(color: isFromPlayer ? Colors.white : Colors.black)),
            if (message.imageAttachmentAsset != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(message.imageAttachmentAsset!),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class AppIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLocked;
  final int badgeCount;

  const AppIcon({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLocked = false,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLocked ? () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter your name to unlock the apps."), backgroundColor: Colors.redAccent));
      } : onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            ClipRRect(borderRadius: BorderRadius.circular(18), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.white.withOpacity(0.25), Colors.white.withOpacity(0.1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
              ),
              child: Icon(isLocked ? Icons.lock_outline_rounded : icon, color: Colors.white, size: 30),
            ))),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, shadows: [Shadow(blurRadius: 5.0, color: Colors.black87, offset: Offset(1,1))]), maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
          if (badgeCount > 0)
            Positioned(
              top: 0,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PhoneStatusBar extends StatelessWidget {
  final VoidCallback onTimeTap;
  const PhoneStatusBar({super.key, required this.onTimeTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(top: 0, left: 0, right: 0, child: Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 16, right: 16),
      child: SizedBox(height: 24, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        GestureDetector(onTap: onTimeTap, child: const Text('9:41', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 1.0, color: Colors.black)]))),
        Row(children: const [Icon(Icons.wifi, color: Colors.white, size: 18), SizedBox(width: 4), Icon(Icons.signal_cellular_alt_rounded, color: Colors.white, size: 18), SizedBox(width: 4), Icon(Icons.battery_full_rounded, color: Colors.white, size: 18)]),
      ])),
    ));
  }
}

class NamePromptPanel extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  const NamePromptPanel({super.key, required this.controller, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Container(
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.2)))),
      child: SafeArea(bottom: false, child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text("Hello, Detective.", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Please state your name to begin the investigation.", style: TextStyle(color: Colors.white70, fontSize: 16), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          TextField(controller: controller, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "Enter your name...", hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)), filled: true, fillColor: Colors.white.withOpacity(0.1), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)), onSubmitted: (_) => onSubmit),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onSubmit, style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("Start Investigation")),
        ]),
      )),
    )));
  }
}

class ReplyOptionsWidget extends StatelessWidget {
  final Function(String) onReplySelected;
  const ReplyOptionsWidget({super.key, required this.onReplySelected});

  @override
  Widget build(BuildContext context) {
    final options = ["Yes, I received them.", "Thank you."];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: options.map((text) {
          return ActionChip(
            onPressed: () => onReplySelected(text),
            backgroundColor: Colors.blue.withOpacity(0.1),
            label: Text(
              text,
              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
            ),
          );
        }).toList(),
      ),
    );
  }
}