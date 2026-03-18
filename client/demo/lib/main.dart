import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:path_provider/path_provider.dart';
import 'pet_sprite.dart';

/// 获取用户角色目录（跨平台）
/// - macOS/Linux: ~/Santuan/characters/mochi
/// - Windows:     C:\Users\xxx\Santuan\characters\mochi
/// - Android:     /storage/emulated/0/Santuan/characters/mochi（外部存储，用户可见）
/// - iOS:         应用文档目录/characters/mochi
Future<String> _getCharDir() async {
  if (Platform.isAndroid) {
    return '/storage/emulated/0/Santuan/characters/mochi';
  }
  if (Platform.isIOS) {
    final docs = await getApplicationDocumentsDirectory();
    return '${docs.path}/characters/mochi';
  }
  return '${Platform.environment['HOME'] ?? Platform.environment['USERPROFILE']}/Santuan/characters/mochi';
}

/// 是否为桌面平台
bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final charDir = await _getCharDir();
  Directory(charDir).createSync(recursive: true);

  if (Platform.isAndroid) {
    // Android: 显示控制面板，宠物通过悬浮窗显示
    runApp(SantuanAndroidLauncher(charDir: charDir));
  } else {
    // 桌面: 直接显示宠物（透明窗口）
    runApp(SantuanDemo(charDir: charDir));
  }
}

// ============================================================
// Android 控制面板 - 启动/停止悬浮窗宠物
// ============================================================

class SantuanAndroidLauncher extends StatelessWidget {
  final String charDir;
  const SantuanAndroidLauncher({super.key, required this.charDir});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: AndroidControlPanel(charDir: charDir),
    );
  }
}

class AndroidControlPanel extends StatefulWidget {
  final String charDir;
  const AndroidControlPanel({super.key, required this.charDir});

  @override
  State<AndroidControlPanel> createState() => _AndroidControlPanelState();
}

class _AndroidControlPanelState extends State<AndroidControlPanel> {
  bool _isOverlayActive = false;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final permission = await FlutterOverlayWindow.isPermissionGranted();
    final active = await FlutterOverlayWindow.isActive();
    setState(() {
      _hasPermission = permission;
      _isOverlayActive = active;
    });
  }

  Future<void> _requestPermission() async {
    await FlutterOverlayWindow.requestPermission();
    // 用户从设置页面返回后重新检查
    await Future.delayed(const Duration(milliseconds: 500));
    await _checkStatus();
  }

  Future<void> _startPet() async {
    if (!_hasPermission) {
      await _requestPermission();
      if (!_hasPermission) return;
    }

    await FlutterOverlayWindow.showOverlay(
      height: 300,
      width: 300,
      alignment: OverlayAlignment.bottomCenter,
      flag: OverlayFlag.defaultFlag,
      visibility: NotificationVisibility.visibilityPublic,
      overlayTitle: "三团",
      overlayContent: "你的桌面宠物正在运行",
      enableDrag: true,
      positionGravity: PositionGravity.none,
    );
    setState(() => _isOverlayActive = true);
  }

  Future<void> _stopPet() async {
    await FlutterOverlayWindow.closeOverlay();
    setState(() => _isOverlayActive = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        title: const Text('三团 - 桌面宠物'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 预览宠物
              SizedBox(
                width: 200,
                height: 200,
                child: PetSprite(mood: 'idle'),
              ),
              const SizedBox(height: 32),

              // 状态指示
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _isOverlayActive ? Colors.green.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isOverlayActive ? Colors.green : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isOverlayActive ? Icons.pets : Icons.pets_outlined,
                      color: _isOverlayActive ? Colors.green : Colors.grey,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isOverlayActive ? '宠物正在桌面上' : '宠物休息中',
                      style: TextStyle(
                        color: _isOverlayActive ? Colors.green.shade700 : Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 启动/停止按钮
              FilledButton.icon(
                onPressed: _isOverlayActive ? _stopPet : _startPet,
                icon: Icon(_isOverlayActive ? Icons.stop : Icons.play_arrow),
                label: Text(_isOverlayActive ? '收回宠物' : '放出宠物'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: _isOverlayActive ? Colors.red.shade400 : Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 16),

              if (!_hasPermission)
                TextButton.icon(
                  onPressed: _requestPermission,
                  icon: const Icon(Icons.settings, size: 16),
                  label: const Text('授予悬浮窗权限'),
                ),

              const SizedBox(height: 32),

              // 提示
              Text(
                '点击宠物可切换表情\n长按宠物可收回\n宠物可以自由拖动',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),

              const SizedBox(height: 16),
              Text(
                '自定义表情目录:\n/Santuan/characters/mochi/',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 桌面端 - 透明窗口宠物（macOS / Windows / Linux）
// ============================================================

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
