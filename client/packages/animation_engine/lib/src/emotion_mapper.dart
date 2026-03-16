import 'animation_command.dart';

/// 情绪 → 动画 映射器
///
/// 将情绪向量转换为对应的动画指令。
/// 这是 "我看你笑，它也笑" 的核心逻辑。
class EmotionMapper {
  /// 默认映射表：主导情绪 → 动画名
  static const Map<String, String> _defaultMapping = {
    'happy': 'happy_dance',
    'sad': 'sad_droop',
    'angry': 'angry_stomp',
    'surprise': 'surprise_jump',
    'fear': 'fear_shake',
    'disgust': 'disgust_turn',
    'neutral': 'idle_breathe',
  };

  final Map<String, String> _mapping;

  EmotionMapper({Map<String, String>? customMapping})
      : _mapping = customMapping ?? _defaultMapping;

  /// 根据情绪数据生成动画指令
  ///
  /// [emotions] 7维情绪向量 {"happy": 0.82, "sad": 0.03, ...}
  /// [threshold] 主导情绪最低阈值，低于此值保持 idle
  AnimationCommand? mapEmotion(
    Map<String, double> emotions, {
    double threshold = 0.4,
  }) {
    if (emotions.isEmpty) return null;

    // 找到最强情绪
    String dominant = 'neutral';
    double maxValue = 0.0;

    for (final entry in emotions.entries) {
      if (entry.value > maxValue) {
        maxValue = entry.value;
        dominant = entry.key;
      }
    }

    // 低于阈值 → idle
    if (maxValue < threshold) {
      dominant = 'neutral';
      maxValue = 1.0;
    }

    final targetAnimation = _mapping[dominant] ?? 'idle_breathe';

    return AnimationCommand(
      id: 'emotion_${DateTime.now().millisecondsSinceEpoch}',
      action: AnimationAction.transition,
      targetState: targetAnimation,
      params: AnimationParams(
        blendDurationMs: 300,
        intensity: maxValue,
        loop: true,
        layer: 'emotion',
        priority: 3,
      ),
      trigger: AnimationTrigger(
        source: 'emotion_stream',
        emotionThreshold: threshold,
      ),
    );
  }
}
