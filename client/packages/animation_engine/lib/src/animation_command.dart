/// 动画指令数据模型
///
/// 对应 protocol/schemas/command.schema.json
class AnimationCommand {
  final String id;
  final AnimationAction action;
  final String targetState;
  final AnimationParams params;
  final AnimationTrigger? trigger;

  AnimationCommand({
    required this.id,
    required this.action,
    required this.targetState,
    required this.params,
    this.trigger,
  });

  factory AnimationCommand.fromJson(Map<String, dynamic> json) {
    return AnimationCommand(
      id: json['id'] as String,
      action: AnimationAction.fromString(json['action'] as String),
      targetState: json['target_state'] as String,
      params: AnimationParams.fromJson(json['params'] as Map<String, dynamic>),
      trigger: json['trigger'] != null
          ? AnimationTrigger.fromJson(json['trigger'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': 'animation_command',
        'id': id,
        'action': action.name,
        'target_state': targetState,
        'params': params.toJson(),
        if (trigger != null) 'trigger': trigger!.toJson(),
      };
}

enum AnimationAction {
  transition, // 平滑过渡
  playOnce, // 播放一次
  queue, // 加入队列
  interrupt; // 立即中断

  static AnimationAction fromString(String s) => switch (s) {
        'transition' => transition,
        'play_once' => playOnce,
        'queue' => queue,
        'interrupt' => interrupt,
        _ => transition,
      };
}

class AnimationParams {
  final int blendDurationMs;
  final double intensity;
  final bool loop;
  final String layer; // emotion | gesture | idle | override
  final int priority;

  AnimationParams({
    this.blendDurationMs = 300,
    this.intensity = 1.0,
    this.loop = false,
    this.layer = 'emotion',
    this.priority = 5,
  });

  factory AnimationParams.fromJson(Map<String, dynamic> json) {
    return AnimationParams(
      blendDurationMs: json['blend_duration_ms'] as int? ?? 300,
      intensity: (json['intensity'] as num?)?.toDouble() ?? 1.0,
      loop: json['loop'] as bool? ?? false,
      layer: json['layer'] as String? ?? 'emotion',
      priority: json['priority'] as int? ?? 5,
    );
  }

  Map<String, dynamic> toJson() => {
        'blend_duration_ms': blendDurationMs,
        'intensity': intensity,
        'loop': loop,
        'layer': layer,
        'priority': priority,
      };
}

class AnimationTrigger {
  final String source; // emotion_stream | user_click | gemini | timer
  final double? emotionThreshold;

  AnimationTrigger({required this.source, this.emotionThreshold});

  factory AnimationTrigger.fromJson(Map<String, dynamic> json) {
    return AnimationTrigger(
      source: json['source'] as String,
      emotionThreshold: (json['emotion_threshold'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'source': source,
        if (emotionThreshold != null) 'emotion_threshold': emotionThreshold,
      };
}
