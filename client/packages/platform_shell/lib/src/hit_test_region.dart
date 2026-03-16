import 'package:flutter/material.dart';
import 'shell_controller.dart';

/// 点击穿透切换区域
///
/// 核心原理：
/// 1. 窗口默认 ignoreMouseEvents=true (穿透)
/// 2. 鼠标进入此区域 → ignoreMouseEvents=false (捕获)
/// 3. 鼠标离开此区域 → ignoreMouseEvents=true (穿透)
///
/// 这样背景区域的点击穿透到桌面，宠物区域的点击被捕获。
class HitTestRegion extends StatelessWidget {
  final ShellController shellController;
  final Widget child;

  const HitTestRegion({
    super.key,
    required this.shellController,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // 移动端不需要点击穿透逻辑
    if (!shellController.isDesktop) return child;

    return MouseRegion(
      onEnter: (_) => shellController.setIgnoreMouseEvents(false),
      onExit: (_) => shellController.setIgnoreMouseEvents(true),
      child: GestureDetector(
        // 长按拖拽窗口
        onPanStart: (_) => shellController.startDragging(),
        child: child,
      ),
    );
  }
}
