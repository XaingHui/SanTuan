import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'pet_sprite.dart';

/// 悬浮窗入口 - Android 专用
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
  bool _showControls = false;
  bool _locked = false;
  double _scale = 1.0;

  static const _minScale = 0.5;
  static const _maxScale = 2.5;

  final _moods = ['idle', 'happy', 'love', 'sleepy', 'surprised', 'angry'];

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
        onTap: () {
          if (_showControls) {
            _cycleMood();
          } else {
            setState(() => _showControls = true);
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 控制按钮栏（顶部）
            if (_showControls) _buildButtons(),
            // 宠物本体
            Expanded(
              child: Center(
                child: Transform.scale(
                  scale: _scale,
                  child: PetSprite(
                    mood: _mood,
                    customDir: _useCustom ? _customDir : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          _btn(Icons.remove, () => _adjustScale(-0.15)),
          _btn(Icons.add, () => _adjustScale(0.15)),
          _btn(Icons.emoji_emotions, _cycleMood),
          _btn(_locked ? Icons.lock : Icons.lock_open, _toggleLock),
          _btn(Icons.keyboard_arrow_up, () {
            setState(() => _showControls = false);
          }),
          _btn(Icons.close, () async {
            await FlutterOverlayWindow.closeOverlay();
          }),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(icon, size: 14, color: Colors.white70),
      ),
    );
  }

  void _adjustScale(double delta) {
    setState(() {
      _scale = (_scale + delta).clamp(_minScale, _maxScale);
    });
  }

  void _toggleLock() {
    setState(() => _locked = !_locked);
    final size = (300 * _scale).round().clamp(200, 800);
    FlutterOverlayWindow.resizeOverlay(size, size, !_locked);
  }

  void _cycleMood() {
    setState(() {
      final idx = _moods.indexOf(_mood);
      _mood = _moods[(idx + 1) % _moods.length];
    });
  }
}
