// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_state.dart';
import '../models.dart';
import '../widgets/widgets.dart';
import 'messaging_screens.dart';
import 'mail_screens.dart';
import '../services/audio_service.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late bool _isPanelOpen;
  bool _showEmailNotification = false;
  final TextEditingController _nameController = TextEditingController();
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    final gameState = Provider.of<GameState>(context, listen: false);
    _isPanelOpen = gameState.detectiveName == null;

    if (gameState.detectiveName != null && !gameState.emailsReceived) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerEmailArrival();
      });
    }
  }

  void _triggerEmailArrival() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final gameState = Provider.of<GameState>(context, listen: false);
    gameState.receiveForwardedEmails();
    _audioService.playRapidSfx('audio/message_tone.mp3', count: gameState.unreadEmailCount);

    setState(() => _showEmailNotification = true);
    Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showEmailNotification = false);
    });

    // FIXED: Trigger follow-up message after another delay
    await Future.delayed(const Duration(seconds: 5));
    if (mounted) {
      gameState.triggerLanchesterFollowUp();
      _audioService.playSfx('audio/message_tone.mp3');
      _showLanchesterFollowUpNotification();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  void _togglePanel() {
    setState(() {
      _isPanelOpen = !_isPanelOpen;
    });
  }

  void _submitName() {
    if (_nameController.text.trim().isNotEmpty) {
      Provider.of<GameState>(context, listen: false)
          .submitName(_nameController.text.trim());

      setState(() {
        _isPanelOpen = false;
      });
      FocusScope.of(context).unfocus();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showInitialNotificationDialog();
      });
    }
  }

  void _showInitialNotificationDialog() {
    _audioService.playSfx('audio/message_tone.mp3');

    final gameState = Provider.of<GameState>(context, listen: false);
    final message = gameState.conversations.first.messages.first;
    final sender = gameState.getContact(message.senderId);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NotificationPopup(
        sender: sender,
        message: message,
        onOpen: () {
          Navigator.of(context).pop();
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const MessagesListScreen()));
        },
      ),
    );
  }

  // ADDED: Separate notification for the follow-up
  void _showLanchesterFollowUpNotification() {
    final gameState = Provider.of<GameState>(context, listen: false);
    final message = gameState.conversations.first.messages.last;
    final sender = gameState.getContact(message.senderId);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NotificationPopup(
        sender: sender,
        message: message,
        onOpen: () {
          Navigator.of(context).pop();
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagesListScreen()));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final panelHeight = screenHeight * 0.4;
    final detectiveName = context.select((GameState gs) => gs.detectiveName);
    final unreadCount = context.select((GameState gs) => gs.unreadEmailCount);

    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity! > 500 && detectiveName != null) {
                setState(() => _isPanelOpen = true);
              } else if (details.primaryVelocity! < -500) {
                setState(() => _isPanelOpen = false);
              }
            },
            child: Stack(
              children: [
                Container(
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/wallpaper.png'),
                            fit: BoxFit.cover))),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(children: [
                      const SizedBox(height: 30),
                      Expanded(
                          child: GridView.count(
                            crossAxisCount: 4,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 24,
                            children: [
                              AppIcon(
                                  icon: Icons.email_rounded,
                                  label: 'Mail',
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const MailListScreen())),
                                  isLocked: detectiveName == null,
                                  badgeCount: unreadCount),
                              AppIcon(
                                  icon: Icons.photo_library_rounded,
                                  label: 'Gallery',
                                  onTap: () {},
                                  isLocked: detectiveName == null),
                              AppIcon(
                                  icon: Icons.contact_page_rounded,
                                  label: 'Contacts',
                                  onTap: () {},
                                  isLocked: detectiveName == null),
                              AppIcon(
                                  icon: Icons.message_rounded,
                                  label: 'Messages',
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const MessagesListScreen())),
                                  isLocked: detectiveName == null),
                              AppIcon(
                                  icon: Icons.note_alt_rounded,
                                  label: 'Notes',
                                  onTap: () {},
                                  isLocked: detectiveName == null),
                            ],
                          )),
                    ]),
                  ),
                ),
                PhoneStatusBar(onTimeTap: _togglePanel),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  top: _isPanelOpen ? 0 : -(panelHeight),
                  left: 0,
                  right: 0,
                  height: panelHeight,
                  child: NamePromptPanel(
                      controller: _nameController, onSubmit: _submitName),
                ),
              ],
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            top: _showEmailNotification ? MediaQuery.of(context).padding.top + 10 : -100,
            left: 20,
            right: 20,
            child: Material(
              elevation: 10,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.email, color: Colors.blue),
                    const SizedBox(width: 12),
                    Text(
                      "Forwarded Emails Received",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}