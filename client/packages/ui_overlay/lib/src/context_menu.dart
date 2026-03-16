import 'package:flutter/material.dart';

/// 右键上下文菜单
///
/// 提供：切换角色、设置、关于、退出等选项。
class PetContextMenu extends StatelessWidget {
  final VoidCallback? onChangeCharacter;
  final VoidCallback? onSettings;
  final VoidCallback? onAbout;
  final VoidCallback? onQuit;

  const PetContextMenu({
    super.key,
    this.onChangeCharacter,
    this.onSettings,
    this.onAbout,
    this.onQuit,
  });

  /// 显示右键菜单
  static Future<void> show(
    BuildContext context,
    Offset position, {
    VoidCallback? onChangeCharacter,
    VoidCallback? onSettings,
    VoidCallback? onAbout,
    VoidCallback? onQuit,
  }) async {
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        const PopupMenuItem(value: 'character', child: Text('切换角色')),
        const PopupMenuItem(value: 'settings', child: Text('设置')),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'about', child: Text('关于 Santuan')),
        const PopupMenuItem(value: 'quit', child: Text('退出')),
      ],
    );

    switch (result) {
      case 'character':
        onChangeCharacter?.call();
        break;
      case 'settings':
        onSettings?.call();
        break;
      case 'about':
        onAbout?.call();
        break;
      case 'quit':
        onQuit?.call();
        break;
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
