import 'package:flutter/material.dart';
import 'character_pack.dart';

/// 宠物渲染器抽象接口
///
/// 所有渲染器（Rive 2.5D / Thermion 3D / 未来其他方案）必须实现此接口。
/// 切换角色 = 切换渲染器实现 + 加载不同角色包。
abstract class PetRendererInterface {
  /// 加载角色包
  Future<void> loadCharacter(CharacterPack pack);

  /// 播放指定动画
  ///
  /// [name] 动画名称（需在角色包 manifest 中定义）
  /// [blendDuration] 过渡时间
  /// [loop] 是否循环
  Future<void> playAnimation(
    String name, {
    Duration blendDuration = const Duration(milliseconds: 300),
    bool loop = true,
  });

  /// 按情绪混合权重驱动表情/动画
  ///
  /// emotions: {"happy": 0.8, "sad": 0.1, ...}
  Future<void> setEmotionBlend(Map<String, double> emotions);

  /// 获取当前正在播放的动画名称
  String? get currentAnimation;

  /// 获取可用的动画列表
  List<String> get availableAnimations;

  /// 构建渲染 Widget
  Widget build(BuildContext context);

  /// 释放资源
  void dispose();
}
