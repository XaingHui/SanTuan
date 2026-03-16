/// 情绪帧数据模型
///
/// 对应 protocol/schemas/emotion.schema.json
class EmotionFrame {
  final double timestamp;
  final int frameId;
  final Map<String, double> emotions;
  final String dominant;
  final double confidence;
  final bool faceDetected;
  final double arousal;
  final double valence;

  EmotionFrame({
    required this.timestamp,
    required this.frameId,
    required this.emotions,
    required this.dominant,
    required this.confidence,
    required this.faceDetected,
    required this.arousal,
    required this.valence,
  });

  factory EmotionFrame.fromJson(Map<String, dynamic> json) {
    return EmotionFrame(
      timestamp: (json['timestamp'] as num).toDouble(),
      frameId: json['frame_id'] as int,
      emotions: Map<String, double>.from(
        (json['emotions'] as Map).map(
          (k, v) => MapEntry(k as String, (v as num).toDouble()),
        ),
      ),
      dominant: json['dominant'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      faceDetected: json['face_detected'] as bool,
      arousal: (json['arousal'] as num).toDouble(),
      valence: (json['valence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': 'emotion_frame',
        'timestamp': timestamp,
        'frame_id': frameId,
        'emotions': emotions,
        'dominant': dominant,
        'confidence': confidence,
        'face_detected': faceDetected,
        'arousal': arousal,
        'valence': valence,
      };
}
