import 'dart:async';
import 'emotion_frame.dart';

/// 通信桥抽象接口
///
/// 所有通信实现（Mock / WebSocket / 未来 gRPC）必须实现此接口。
/// 切换通信方式 = 在 DI 中替换实现类。
abstract class EmotionBridgeInterface {
  /// 连接到 AI 服务
  Future<void> connect();

  /// 断开连接
  Future<void> disconnect();

  /// 情绪数据流 — 从 AI 服务接收
  Stream<EmotionFrame> get emotionStream;

  /// 发送事件到 AI 服务
  Future<void> sendEvent(Map<String, dynamic> event);

  /// 发送指令请求（如请求切换动画）
  Future<void> sendCommand(Map<String, dynamic> command);

  /// 连接状态
  bool get isConnected;
}
