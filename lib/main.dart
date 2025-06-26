import 'dart:ui'; // Required for the blur effect.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// --- Main App Entry Point ---
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const DetectiveGameApp());
}

class DetectiveGameApp extends StatelessWidget {
  const DetectiveGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Detective Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

// --- Home Screen Widget (Now Stateful) ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State variables to manage the panel and detective's name
  bool _isPanelOpen = true; // Start with the panel open
  String _detectiveName = '';
  final TextEditingController _nameController = TextEditingController();

  // Toggles the visibility of the swipe-down panel
  void _togglePanel() {
    setState(() {
      _isPanelOpen = !_isPanelOpen;
    });
  }

  // Saves the name and closes the panel
  void _submitName() {
    if (_nameController.text.trim().isNotEmpty) {
      setState(() {
        _detectiveName = _nameController.text.trim();
        _isPanelOpen = false; // Close panel on submission
      });
      // Hide the keyboard
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final panelHeight = screenHeight * 0.4; // Panel takes 40% of screen height

    return Scaffold(
      body: GestureDetector(
        // Detects vertical swipes to open/close the panel
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! > 500) { // Swiping down
            setState(() => _isPanelOpen = true);
          } else if (details.primaryVelocity! < -500) { // Swiping up
            if (_detectiveName.isNotEmpty) {
              setState(() => _isPanelOpen = false);
            }
          }
        },
        child: Stack(
          children: [
            // 1. --- Background Wallpaper ---
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/wallpaper.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // 2. --- Main Content Area (Icons) ---
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 30), // Space for status bar
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 4,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 24,
                        children: [
                          AppIcon(
                            icon: Icons.email_rounded,
                            label: 'Mail',
                            onTap: () {
                              print('Mail app tapped!');
                            },
                            isLocked: _detectiveName.isEmpty,
                          ),
                          AppIcon(
                            icon: Icons.photo_library_rounded,
                            label: 'Gallery',
                            onTap: () {
                              print('Gallery app tapped!');
                            },
                            isLocked: _detectiveName.isEmpty,
                          ),
                          AppIcon(
                            icon: Icons.contact_page_rounded,
                            label: 'Contacts',
                            onTap: () {
                              print('Contacts app tapped!');
                            },
                            isLocked: _detectiveName.isEmpty,
                          ),
                          AppIcon(
                            icon: Icons.message_rounded,
                            label: 'Messages',
                            onTap: () {
                              print('Messages app tapped!');
                            },
                            isLocked: _detectiveName.isEmpty,
                          ),
                          AppIcon(
                            icon: Icons.note_alt_rounded,
                            label: 'Notes',
                            onTap: () {
                              print('Notes app tapped!');
                            },
                            isLocked: _detectiveName.isEmpty,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. --- Custom Status Bar ---
            PhoneStatusBar(onTimeTap: _togglePanel),

            // 4. --- Swipe-Down Name Prompt Panel ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              top: _isPanelOpen ? 0 : -(panelHeight), // Slides in from the top
              left: 0,
              right: 0,
              height: panelHeight,
              child: NamePromptPanel(
                nameController: _nameController,
                onSubmit: _submitName,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Custom Widget for App Icons (Now more beautiful!) ---
class AppIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLocked;

  const AppIcon({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLocked ? () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Enter your name to unlock the apps."),
            backgroundColor: Colors.redAccent,
          ),
        );
      } : onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.25),
                      Colors.white.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  isLocked ? Icons.lock_outline_rounded : icon,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(blurRadius: 5.0, color: Colors.black87, offset: Offset(1,1))
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// --- Custom Widget for the Phone Status Bar ---
class PhoneStatusBar extends StatelessWidget {
  final VoidCallback onTimeTap;
  const PhoneStatusBar({super.key, required this.onTimeTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top, left: 16, right: 16),
        child: SizedBox(
          height: 24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onTimeTap,
                child: const Text(
                  '9:41',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 1.0, color: Colors.black)]),
                ),
              ),
              Row(
                children: const [
                  Icon(Icons.wifi, color: Colors.white, size: 18),
                  SizedBox(width: 4),
                  Icon(Icons.signal_cellular_alt_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 4),
                  Icon(Icons.battery_full_rounded, color: Colors.white, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Custom Widget for the Name Prompt Panel ---
class NamePromptPanel extends StatelessWidget {
  final TextEditingController nameController;
  final VoidCallback onSubmit;

  const NamePromptPanel({
    super.key,
    required this.nameController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.2)),
              )
          ),
          child: SafeArea(
            bottom: false, // No padding at the bottom of the safe area
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Hello, Detective.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Please state your name to begin the investigation.",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Enter your name...",
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => onSubmit(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Start Investigation"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

