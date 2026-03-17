import 'dart:io';
import 'package:flutter/material.dart';
import 'pet_sprite.dart';

/// 用户自定义角色图片目录
/// 用户把 GIF/PNG 放到这个目录，命名为 idle.gif / happy.gif / ... 即可
final _userCharDir = '${Platform.environment['HOME']}/Santuan/characters/mochi';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 确保用户目录存在
  Directory(_userCharDir).createSync(recursive: true);
  runApp(const SantuanDemo());
}

class SantuanDemo extends StatelessWidget {
  const SantuanDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: PetStage()),
      ),
    );
  }
}

class PetStage extends StatefulWidget {
  const PetStage({super.key});

  @override
  State<PetStage> createState() => _PetStageState();
}

class _PetStageState extends State<PetStage> {
  String _mood = 'idle';
  bool _showControls = false;
  bool _useCustom = false; // 是否检测到用户自定义图片

  final moods = ['idle', 'happy', 'love', 'sleepy', 'surprised', 'angry'];

  @override
  void initState() {
    super.initState();
    _checkCustomImages();
  }

  /// 检查用户目录下是否有图片
  void _checkCustomImages() {
    final dir = Directory(_userCharDir);
    if (dir.existsSync()) {
      final hasImages = dir.listSync().any((f) =>
          f.path.endsWith('.gif') ||
          f.path.endsWith('.png') ||
          f.path.endsWith('.webp'));
      setState(() => _useCustom = hasImages);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _showControls = true),
      onExit: (_) => setState(() => _showControls = false),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: _cycleMood,
            onSecondaryTapUp: (d) => _showMenu(context, d),
            child: PetSprite(
              mood: _mood,
              customDir: _useCustom ? _userCharDir : null,
            ),
          ),
          // 悬浮控制按钮
          Positioned(
            top: -6,
            right: -6,
            child: AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: _buildButtons(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Icons.emoji_emotions, '表情', _cycleMood),
          _btn(Icons.folder_open, '导入表情', _openCharDir),
          _btn(Icons.refresh, '刷新', _checkCustomImages),
          _btn(Icons.close, '退出', () => exit(0)),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, String tip, VoidCallback onTap) {
    return Tooltip(
      message: tip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(icon, size: 13, color: Colors.white70),
        ),
      ),
    );
  }

  /// 打开 Finder 到角色目录，让用户放入 GIF
  void _openCharDir() {
    Process.run('open', [_userCharDir]);
  }

  void _cycleMood() {
    setState(() {
      final idx = moods.indexOf(_mood);
      _mood = moods[(idx + 1) % moods.length];
    });
  }

  void _showMenu(BuildContext context, TapUpDetails d) async {
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        d.globalPosition.dx, d.globalPosition.dy,
        d.globalPosition.dx + 1, d.globalPosition.dy + 1,
      ),
      color: Colors.white.withValues(alpha: 0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        for (final m in moods)
          PopupMenuItem(value: m, child: Row(children: [
            Icon(m == _mood ? Icons.check_circle : Icons.circle_outlined,
                size: 15, color: m == _mood ? Colors.blue : Colors.grey),
            const SizedBox(width: 8),
            Text(_moodLabel(m)),
          ])),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'import',
          child: Row(children: [
            Icon(Icons.folder_open, size: 15, color: Colors.orange),
            const SizedBox(width: 8),
            Text('导入表情包...'),
          ]),
        ),
        PopupMenuItem(value: 'quit', child: Text('退出')),
      ],
    );
    if (result == 'quit') {
      exit(0);
    } else if (result == 'import') {
      _openCharDir();
    } else if (result != null) {
      setState(() => _mood = result);
    }
  }

  String _moodLabel(String mood) => switch (mood) {
    'idle' => '待机',
    'happy' => '开心',
    'love' => '比心',
    'sleepy' => '困了',
    'surprised' => '惊讶',
    'angry' => '生气',
    _ => mood,
  };
}
