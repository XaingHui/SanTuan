import 'package:flutter/material.dart';

/// 角色画笔抽象接口
///
/// 所有宠物角色都实现这个接口。
/// 替换角色 = 换一个 PetPainterBase 实现，其他代码不变。
abstract class PetPainterBase extends CustomPainter {
  final String mood;
  final double breathT;
  final double bounceT;

  PetPainterBase({
    required this.mood,
    required this.breathT,
    required this.bounceT,
  });

  /// 角色名称（显示用）
  String get characterName;

  /// 角色默认尺寸
  Size get characterSize;
}

/// 角色注册表
///
/// 用法:
///   CharacterRegistry.register('cat', (mood, breathT, bounceT) => CatPainter(...));
///   final painter = CharacterRegistry.create('cat', mood: 'happy', breathT: 0.5, bounceT: 0);
class CharacterRegistry {
  static final Map<String, CharacterFactory> _registry = {};

  /// 所有已注册角色的 ID
  static List<String> get characterIds => _registry.keys.toList();

  /// 注册一个角色
  static void register(String id, CharacterFactory factory) {
    _registry[id] = factory;
  }

  /// 创建角色画笔
  static PetPainterBase create(
    String id, {
    required String mood,
    required double breathT,
    required double bounceT,
  }) {
    final factory = _registry[id];
    if (factory == null) {
      throw ArgumentError('Unknown character: $id. Available: ${_registry.keys.join(', ')}');
    }
    return factory(mood, breathT, bounceT);
  }
}

typedef CharacterFactory = PetPainterBase Function(
  String mood,
  double breathT,
  double bounceT,
);
