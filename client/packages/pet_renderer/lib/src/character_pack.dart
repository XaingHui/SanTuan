import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/character_manifest.dart';

/// 角色包 — 包含模型文件 + 动画 + 配置清单
///
/// 角色可替换的核心：每个角色是一个自包含的角色包。
/// 切换角色 = 加载不同的 CharacterPack。
class CharacterPack {
  final String id;
  final String basePath;
  final CharacterManifest manifest;

  CharacterPack({
    required this.id,
    required this.basePath,
    required this.manifest,
  });

  /// 模型文件路径
  String get modelPath => '$basePath/${manifest.model}';

  /// 获取指定动画的文件路径
  String? animationPath(String name) {
    final file = manifest.animations[name];
    if (file == null) return null;
    return '$basePath/animations/$file';
  }

  /// 从 assets 加载角色包
  static Future<CharacterPack> load(String characterId) async {
    final basePath = 'assets/characters/$characterId';
    final manifestJson = await rootBundle.loadString('$basePath/manifest.json');
    final manifest = CharacterManifest.fromJson(json.decode(manifestJson));

    return CharacterPack(
      id: characterId,
      basePath: basePath,
      manifest: manifest,
    );
  }
}
