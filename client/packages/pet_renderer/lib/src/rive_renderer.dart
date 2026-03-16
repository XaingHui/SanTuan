import 'package:flutter/material.dart';
import 'renderer_interface.dart';
import 'character_pack.dart';

/// Rive 2.5D 渲染器实现
///
/// MVP 阶段的默认渲染器。使用 Rive 的状态机驱动 2.5D 角色动画。
/// Rive 优势：文件小、性能好、内置状态机、Flutter 支持成熟。
class RiveRenderer implements PetRendererInterface {
  CharacterPack? _currentPack;
  String? _currentAnimation;

  @override
  Future<void> loadCharacter(CharacterPack pack) async {
    _currentPack = pack;
    // TODO: 加载 .riv 文件
    // final data = await rootBundle.load(pack.modelPath);
    // final file = RiveFile.import(data);
    // _artboard = file.mainArtboard;
    // _stateMachineController = StateMachineController.fromArtboard(_artboard!);
  }

  @override
  Future<void> playAnimation(
    String name, {
    Duration blendDuration = const Duration(milliseconds: 300),
    bool loop = true,
  }) async {
    _currentAnimation = name;
    // TODO: 通过 Rive StateMachine inputs 触发动画切换
    // final trigger = _stateMachineController?.findInput<bool>(name);
    // trigger?.value = true;
  }

  @override
  Future<void> setEmotionBlend(Map<String, double> emotions) async {
    // TODO: 将情绪值映射到 Rive 的 number inputs
    // emotions.forEach((key, value) {
    //   final input = _stateMachineController?.findInput<double>(key);
    //   input?.value = value;
    // });
  }

  @override
  String? get currentAnimation => _currentAnimation;

  @override
  List<String> get availableAnimations {
    return _currentPack?.manifest.animations.keys.toList() ?? [];
  }

  @override
  Widget build(BuildContext context) {
    // TODO: 返回真实的 Rive widget
    // return Rive(artboard: _artboard!, fit: BoxFit.contain);

    // MVP placeholder: 显示一个可爱的占位符
    return Container(
      width: 200,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          _currentAnimation ?? 'idle',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: 释放 Rive 资源
  }
}
