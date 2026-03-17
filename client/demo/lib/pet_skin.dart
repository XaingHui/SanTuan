import 'dart:math';
import 'package:flutter/material.dart';

/// 宠物角色抽象接口 — 所有角色必须实现
///
/// 后续替换 3D 模型时，只需新建一个实现此接口的类。
abstract class PetSkin {
  /// 角色唯一标识
  String get id;

  /// 角色名称
  String get name;

  /// 支持的心情列表
  List<String> get supportedMoods;

  /// 绘制角色
  void paint(Canvas canvas, Size size, {
    required String mood,
    required double breathT,
    required double bounceT,
  });
}
