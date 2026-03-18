import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'pet_sprite.dart';

/// 悬浮窗入口 - Android 专用
/// 这个函数由 Android native 调用，运行在独立的 Flutter 引擎中
@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OverlayPet(),
  ));
}

class OverlayPet extends StatefulWidget {
  const OverlayPet({super.key});

  @override
  State<OverlayPet> createState() => _OverlayPetState();
}

class _OverlayPetState extends State<OverlayPet> {
  String _mood = 'idle';
  final _moods = ['idle', 'happy', 'love', 'sleepy', 'surprised', 'angry'];

  // 用户自定义表情目录（Android 外部存储）
  final String _customDir = '/storage/emulated/0/Santuan/characters/mochi';
  bool _useCustom = false;

  @override
  void initState() {
    super.initState();
    _checkCustomImages();
  }

  void _checkCustomImages() {
    try {
      final dir = Directory(_customDir);
      if (dir.existsSync()) {
        final hasImages = dir.listSync().any((f) =>
            f.path.endsWith('.gif') ||
            f.path.endsWith('.png') ||
            f.path.endsWith('.webp'));
        setState(() => _useCustom = hasImages);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: _cycleMood,
        onLongPress: () async {
          // 长按关闭悬浮窗
          await FlutterOverlayWindow.closeOverlay();
        },
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: PetSprite(
              mood: _mood,
              customDir: _useCustom ? _customDir : null,
            ),
          ),
        ),
      ),
    );
  }

  void _cycleMood() {
    setState(() {
      final idx = _moods.indexOf(_mood);
      _mood = _moods[(idx + 1) % _moods.length];
    });
  }
}
