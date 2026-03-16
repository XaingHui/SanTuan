import 'package:flutter/material.dart';
import 'chat_bubble.dart';
import 'context_menu.dart';

/// UI 覆盖层 — 浮在宠物之上的 UI 元素
///
/// 包含：对话气泡、右键菜单、设置面板入口等。
class OverlayLayer extends StatefulWidget {
  const OverlayLayer({super.key});

  @override
  State<OverlayLayer> createState() => _OverlayLayerState();
}

class _OverlayLayerState extends State<OverlayLayer> {
  String? _currentMessage;

  void showMessage(String message) {
    setState(() => _currentMessage = message);
    // 3 秒后自动消失
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _currentMessage = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_currentMessage != null) ChatBubble(message: _currentMessage!),
      ],
    );
  }
}
