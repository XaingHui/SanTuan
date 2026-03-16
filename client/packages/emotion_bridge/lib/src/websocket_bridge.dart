import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'bridge_interface.dart';
import 'emotion_frame.dart';

/// WebSocket 通信桥 — V1.0 阶段使用
///
/// 连接到本地 Python AI 服务的 WebSocket 端口。
/// 支持双向通信：接收情绪流 + 发送事件/指令。
class WebSocketBridge implements EmotionBridgeInterface {
  final String url;
  WebSocketChannel? _channel;
  final _emotionController = StreamController<EmotionFrame>.broadcast();
  bool _connected = false;
  StreamSubscription? _subscription;

  WebSocketBridge({this.url = 'ws://localhost:8765'});

  @override
  Future<void> connect() async {
    if (_connected) return;

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      await _channel!.ready;
      _connected = true;

      // 监听来自 AI 服务的消息
      _subscription = _channel!.stream.listen(
        (data) => _handleMessage(data as String),
        onError: (error) {
          print('[WebSocketBridge] Error: $error');
          _connected = false;
          // 自动重连
          Future.delayed(const Duration(seconds: 3), connect);
        },
        onDone: () {
          _connected = false;
          // 自动重连
          Future.delayed(const Duration(seconds: 3), connect);
        },
      );
    } catch (e) {
      print('[WebSocketBridge] Connection failed: $e');
      // 回退到重试
      Future.delayed(const Duration(seconds: 3), connect);
    }
  }

  @override
  Future<void> disconnect() async {
    await _subscription?.cancel();
    await _channel?.sink.close();
    _connected = false;
  }

  @override
  Stream<EmotionFrame> get emotionStream => _emotionController.stream;

  @override
  Future<void> sendEvent(Map<String, dynamic> event) async {
    _send({'type': 'client_event', ...event});
  }

  @override
  Future<void> sendCommand(Map<String, dynamic> command) async {
    _send({'type': 'command_request', ...command});
  }

  @override
  bool get isConnected => _connected;

  void _handleMessage(String data) {
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      final type = json['type'] as String?;

      switch (type) {
        case 'emotion_frame':
          _emotionController.add(EmotionFrame.fromJson(json));
          break;
        case 'animation_command':
          // TODO: 路由到 AnimationController
          break;
        default:
          print('[WebSocketBridge] Unknown message type: $type');
      }
    } catch (e) {
      print('[WebSocketBridge] Parse error: $e');
    }
  }

  void _send(Map<String, dynamic> data) {
    if (!_connected || _channel == null) return;
    _channel!.sink.add(jsonEncode(data));
  }

  void dispose() {
    _subscription?.cancel();
    _channel?.sink.close();
    _emotionController.close();
  }
}
