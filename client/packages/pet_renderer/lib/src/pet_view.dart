import 'package:flutter/material.dart';
import 'renderer_interface.dart';
import '../pet_renderer.dart';

/// 宠物渲染 Widget
///
/// 从 DI 中获取渲染器实例，构建宠物视图。
/// 这是外部使用的入口 Widget。
class PetView extends StatelessWidget {
  const PetView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: 从 DI 获取渲染器
    // final renderer = locator<PetRendererInterface>();
    // return renderer.build(context);

    // MVP placeholder
    return Container(
      width: 200,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🐱', style: TextStyle(fontSize: 80)),
          SizedBox(height: 8),
          Text(
            'Santuan',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          Text(
            'placeholder',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
