/// 角色清单 — 描述一个角色包的内容和能力
class CharacterManifest {
  final String id;
  final String name;
  final String version;
  final String renderer; // "rive" | "thermion"
  final String model; // 模型文件名
  final String? thumbnail;
  final Map<String, String> animations; // name → filename
  final Map<String, String> emotionMorphTargets; // emotion → morph target name
  final HitBox hitBox;

  CharacterManifest({
    required this.id,
    required this.name,
    required this.version,
    required this.renderer,
    required this.model,
    this.thumbnail,
    required this.animations,
    this.emotionMorphTargets = const {},
    required this.hitBox,
  });

  factory CharacterManifest.fromJson(Map<String, dynamic> json) {
    return CharacterManifest(
      id: json['id'] as String,
      name: json['name'] as String,
      version: json['version'] as String,
      renderer: json['renderer'] as String,
      model: json['model'] as String,
      thumbnail: json['thumbnail'] as String?,
      animations: Map<String, String>.from(json['animations'] as Map),
      emotionMorphTargets: json['emotion_morph_targets'] != null
          ? Map<String, String>.from(json['emotion_morph_targets'] as Map)
          : {},
      hitBox: HitBox.fromJson(json['hit_box'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'version': version,
        'renderer': renderer,
        'model': model,
        'thumbnail': thumbnail,
        'animations': animations,
        'emotion_morph_targets': emotionMorphTargets,
        'hit_box': hitBox.toJson(),
      };
}

class HitBox {
  final double x;
  final double y;
  final double width;
  final double height;

  HitBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory HitBox.fromJson(Map<String, dynamic> json) => HitBox(
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        width: (json['width'] as num).toDouble(),
        height: (json['height'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'width': width,
        'height': height,
      };
}
