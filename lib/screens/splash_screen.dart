// lib/screens/splash_screen.dart

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import 'home_screen.dart';

class EpisodeSplashScreen extends StatefulWidget {
  const EpisodeSplashScreen({super.key});

  @override
  State<EpisodeSplashScreen> createState() => _EpisodeSplashScreenState();
}

class _EpisodeSplashScreenState extends State<EpisodeSplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _blurAnimation;
  late Animation<double> _opacityAnimation;
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();

    _audioService.playMusic('audio/eerie_music.mp3');

    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _blurAnimation = Tween<double>(begin: 5.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7, curve: Curves.easeIn)),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();

    // Navigate to home screen after animation + delay
    Timer(const Duration(seconds: 5), () {
      // Fade out music and then navigate
      _audioService.fadeOutMusic().then((_) {
        if (mounted) {
          // Replace the entire screen stack with the HomeScreen
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
                (Route<dynamic> route) => false, // This predicate removes all routes below
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: _blurAnimation.value, sigmaY: _blurAnimation.value),
                child: Text(
                  'Episode 1',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}