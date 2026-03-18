import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'pet_sprite.dart';

// 悬浮窗入口点 - 必须在 main library 中可见
export 'overlay_main.dart';

/// 获取用户角色目录（跨平台）
Future<String> _getCharDir() async {
  if (Platform.isAndroid || Platform.isIOS) {
    final docs = await getApplicationDocumentsDirectory();
    return '${docs.path}/characters/mochi';
  }
  return '${Platform.environment['HOME'] ?? Platform.environment['USERPROFILE']}/Santuan/characters/mochi';
}

bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final charDir = await _getCharDir();
  Directory(charDir).createSync(recursive: true);

  if (Platform.isAndroid) {
    // Android: 显示控制面板，用户点击按钮启动悬浮窗宠物
    runApp(AndroidControlPanel(charDir: charDir));
  } else {
    // 桌面: 直接显示宠物（透明窗口由原生代码处理）
    runApp(SantuanDemo(charDir: charDir));
  }
}

// ══════════════════════════════════════════
// Android 控制面板
// ══════════════════════════════════════════

class AndroidControlPanel extends StatefulWidget {
  final String charDir;
  const AndroidControlPanel({super.key, required this.charDir});

  @override
  State<AndroidControlPanel> createState() => _AndroidControlPanelState();
}

class _AndroidControlPanelState extends State<AndroidControlPanel> {
  bool _overlayActive = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.pink,
        useMaterial3: true,
      ),
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // 预览宠物
                SizedBox(
                  height: 200,
                  child: PetSprite(mood: 'happy'),
                ),
                const SizedBox(height: 24),
                Text(
                  '三团桌面宠物',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '点击下方按钮，把宠物放到桌面上',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),
                // 启动/停止悬浮窗
                FilledButton.icon(
                  onPressed: _toggleOverlay,
                  icon: Icon(_overlayActive ? Icons.pets : Icons.rocket_launch),
                  label: Text(_overlayActive ? '收回宠物' : '放出宠物'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(200, 56),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 16),
                if (_overlayActive)
                  Text(
                    '宠物已在桌面上！\n点击宠物切换表情，长按收回',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.green[700], fontSize: 14),
                  ),
                const Spacer(),
                Text(
                  '提示：需要授予「显示在其他应用上层」权限',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleOverlay() async {
    if (_overlayActive) {
      // 关闭悬浮窗
      await FlutterOverlayWindow.closeOverlay();
      setState(() => _overlayActive = false);
    } else {
      // 检查并请求悬浮窗权限
      final hasPermission = await FlutterOverlayWindow.isPermissionGranted();
      if (!hasPermission) {
        await FlutterOverlayWindow.requestPermission();
        // 等用户从设置页回来后再检查
        final granted = await FlutterOverlayWindow.isPermissionGranted();
        if (!granted) return;
      }
      // 启动悬浮窗
      await FlutterOverlayWindow.showOverlay(
        height: 300,
        width: 300,
        alignment: OverlayAlignment.center,
        enableDrag: true,
      );
      setState(() => _overlayActive = true);
    }
  }
}

// ══════════════════════════════════════════
// 桌面端 - 直接显示宠物
// ══════════════════════════════════════════

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
              top: 4,
              right: 4,
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
          _btn(Icons.folder_open, '导入表情', _openCharDir),
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

  void _openCharDir() {
    if (Platform.isMacOS) {
      Process.run('open', [widget.charDir]);
    } else if (Platform.isWindows) {
      Process.run('explorer', [widget.charDir]);
    } else if (Platform.isLinux) {
      Process.run('xdg-open', [widget.charDir]);
    }
  }

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
        PopupMenuItem(value: 'quit', child: Text('退出')),
      ],
    );
    if (result == 'quit') {
      _quit();
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
