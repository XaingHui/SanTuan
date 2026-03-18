import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'pet_sprite.dart';

/// 获取用户角色目录（跨平台）
/// - 桌面: ~/Santuan/characters/mochi
/// - 移动端: 应用文档目录/characters/mochi
Future<String> _getCharDir() async {
  if (Platform.isAndroid || Platform.isIOS) {
    final docs = await getApplicationDocumentsDirectory();
    return '${docs.path}/characters/mochi';
  }
  // 桌面平台
  return '${Platform.environment['HOME'] ?? Platform.environment['USERPROFILE']}/Santuan/characters/mochi';
}

/// 是否为桌面平台
bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final charDir = await _getCharDir();
  Directory(charDir).createSync(recursive: true);
  runApp(SantuanDemo(charDir: charDir));
}

class SantuanDemo extends StatelessWidget {
  final String charDir;
  const SantuanDemo({super.key, required this.charDir});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: PetStage(charDir: charDir)),
      ),
    );
  }
}

class PetStage extends StatefulWidget {
  final String charDir;
  const PetStage({super.key, required this.charDir});

  @override
  State<PetStage> createState() => _PetStageState();
}

class _PetStageState extends State<PetStage> {
  String _mood = 'idle';
  bool _showControls = false;
  bool _useCustom = false;
  double _scale = 1.0;

  static const _minScale = 0.5;
  static const _maxScale = 2.5;

  final moods = ['idle', 'happy', 'love', 'sleepy', 'surprised', 'angry'];

  @override
  void initState() {
    super.initState();
    _checkCustomImages();
  }

  void _checkCustomImages() {
    final dir = Directory(widget.charDir);
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
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          setState(() {
            _scale -= event.scrollDelta.dy * 0.002;
            _scale = _scale.clamp(_minScale, _maxScale);
          });
        }
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _showControls = true),
        onExit: (_) => setState(() => _showControls = false),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: _cycleMood,
              onSecondaryTapUp: (d) => _showMenu(context, d),
              onScaleUpdate: (details) {
                if (details.pointerCount >= 2) {
                  setState(() {
                    _scale = (_scale * details.scale).clamp(_minScale, _maxScale);
                  });
                }
              },
              child: Transform.scale(
                scale: _scale,
                child: PetSprite(
                  mood: _mood,
                  customDir: _useCustom ? widget.charDir : null,
                ),
              ),
            ),
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
          _btn(Icons.remove, '缩小', () => _adjustScale(-0.15)),
          _btn(Icons.add, '放大', () => _adjustScale(0.15)),
          _btn(Icons.emoji_emotions, '表情', _cycleMood),
          if (isDesktop) _btn(Icons.folder_open, '导入表情', _openCharDir),
          _btn(Icons.refresh, '刷新', _checkCustomImages),
          _btn(Icons.close, '退出', _quit),
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

  void _adjustScale(double delta) {
    setState(() => _scale = (_scale + delta).clamp(_minScale, _maxScale));
  }

  /// 打开角色目录（仅桌面平台）
  void _openCharDir() {
    if (Platform.isMacOS) {
      Process.run('open', [widget.charDir]);
    } else if (Platform.isWindows) {
      Process.run('explorer', [widget.charDir]);
    } else if (Platform.isLinux) {
      Process.run('xdg-open', [widget.charDir]);
    }
  }

  /// 跨平台退出
  void _quit() {
    if (isDesktop) {
      exit(0);
    } else {
      SystemNavigator.pop();
    }
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
        if (isDesktop)
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
      _quit();
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
