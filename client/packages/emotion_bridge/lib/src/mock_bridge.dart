import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'bridge_interface.dart';
import 'emotion_frame.dart';

/// Mock 通信桥 — MVP 阶段使用
///
/// 生成模拟情绪数据，用于在无 AI 服务时测试动画系统。
/// 每秒产出 10 帧模拟数据（降低频率，MVP 够用）。
class MockBridge implements EmotionBridgeInterface {
  final _emotionController = StreamController<EmotionFrame>.broadcast();
  Timer? _mockTimer;
  bool _connected = false;
  int _frameCounter = 0;
  final _random = Random();

  @override
  Future<void> connect() async {
    if (_connected) return;
    _connected = true;

    // 每 100ms 生成一帧模拟情绪数据 (10fps)
    _mockTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _emitMockFrame();
    });
  }

  @override
  Future<void> disconnect() async {
    _mockTimer?.cancel();
    _connected = false;
  }

  @override
  Stream<EmotionFrame> get emotionStream => _emotionController.stream;

  @override
  Future<void> sendEvent(Map<String, dynamic> event) async {
    // Mock: 打印事件到控制台
    print('[MockBridge] Event: ${jsonEncode(event)}');
  }

  @override
  Future<void> sendCommand(Map<String, dynamic> command) async {
    print('[MockBridge] Command: ${jsonEncode(command)}');
  }

  @override
  bool get isConnected => _connected;

  void _emitMockFrame() {
    _frameCounter++;

    // 模拟缓慢变化的情绪 — 使用正弦波
    final t = _frameCounter * 0.01;
    final happy = (sin(t) + 1) / 2 * 0.8 + _random.nextDouble() * 0.1;
    final sad = (sin(t + 2) + 1) / 2 * 0.3 + _random.nextDouble() * 0.05;
    final neutral = 1.0 - happy - sad;

    final emotions = {
      'happy': happy.clamp(0.0, 1.0),
      'sad': sad.clamp(0.0, 1.0),
      'angry': _random.nextDouble() * 0.05,
      'surprise': _random.nextDouble() * 0.03,
      'fear': _random.nextDouble() * 0.02,
      'disgust': _random.nextDouble() * 0.01,
      'neutral': neutral.clamp(0.0, 1.0),
    };

    // 找主导情绪
    String dominant = 'neutral';
    double maxVal = 0;
    for (final e in emotions.entries) {
      if (e.value > maxVal) {
        maxVal = e.value;
        dominant = e.key;
      }
    }

    _emotionController.add(EmotionFrame(
      timestamp: DateTime.now().millisecondsSinceEpoch / 1000.0,
      frameId: _frameCounter,
      emotions: emotions,
      dominant: dominant,
      confidence: 0.85 + _random.nextDouble() * 0.15,
      faceDetected: true,
      arousal: (sin(t * 0.5) + 1) / 2,
      valence: (sin(t * 0.3) + 1) / 2,
    ));
  }

  void dispose() {
    _mockTimer?.cancel();
    _emotionController.close();
  }
}
