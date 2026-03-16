import 'package:flutter/material.dart';
import 'package:platform_shell/platform_shell.dart';
import 'package:pet_renderer/pet_renderer.dart';
import 'package:animation_engine/animation_engine.dart';
import 'package:emotion_bridge/emotion_bridge.dart';
import 'package:ui_overlay/ui_overlay.dart';
import 'package:santuan/di/service_locator.dart';

class SantuanApp extends StatelessWidget {
  const SantuanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Santuan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const SantuanShell(),
    );
  }
}

/// 顶层壳：透明窗口 + 宠物 + UI覆盖层
class SantuanShell extends StatefulWidget {
  const SantuanShell({super.key});

  @override
  State<SantuanShell> createState() => _SantuanShellState();
}

class _SantuanShellState extends State<SantuanShell> {
  late final ShellController _shell;
  late final EmotionBridgeInterface _bridge;
  late final AnimationController _animEngine;

  @override
  void initState() {
    super.initState();
    _shell = locator<ShellController>();
    _bridge = locator<EmotionBridgeInterface>();
    _animEngine = locator<AnimationController>();

    _shell.initialize();
    _bridge.connect();
  }

  @override
  void dispose() {
    _bridge.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 宠物渲染层 — 被 HitTestRegion 包裹实现点击穿透
          Center(
            child: HitTestRegion(
              shellController: _shell,
              child: const PetView(),
            ),
          ),
          // UI 覆盖层 — 气泡、菜单等
          const Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: OverlayLayer(),
          ),
        ],
      ),
    );
  }
}
