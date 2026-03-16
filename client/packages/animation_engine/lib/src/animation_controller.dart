import 'dart:async';
import 'package:pet_renderer/pet_renderer.dart';
import 'animation_command.dart';
import 'command_parser.dart';
import 'state_machine.dart';
import 'emotion_mapper.dart';

/// 动画控制器 — 对外统一入口
///
/// 连接 指令解析 → 状态机 → 渲染器，形成完整的动画管线。
/// 外部只需调用 [executeCommand] 或 [onEmotionUpdate]。
class AnimationController {
  final PetRendererInterface renderer;
  final AnimationStateMachine _stateMachine = AnimationStateMachine();
  final EmotionMapper _emotionMapper = EmotionMapper();

  late final StreamSubscription _stateSubscription;

  AnimationController({required this.renderer}) {
    // 状态机状态变化 → 驱动渲染器切换动画
    _stateSubscription = _stateMachine.stateStream.listen((state) {
      renderer.playAnimation(state);
    });
  }

  /// 执行 JSON 指令字符串
  Future<bool> executeJson(String jsonString) async {
    final command = CommandParser.parse(jsonString);
    return executeCommand(command);
  }

  /// 执行动画指令
  Future<bool> executeCommand(AnimationCommand command) {
    return _stateMachine.processCommand(command);
  }

  /// 情绪数据更新回调
  ///
  /// 接收来自 EmotionBridge 的情绪帧，自动映射为动画指令。
  Future<void> onEmotionUpdate(Map<String, double> emotions) async {
    final command = _emotionMapper.mapEmotion(emotions);
    if (command != null) {
      await executeCommand(command);
    }
  }

  /// 当前动画状态
  String get currentState => _stateMachine.currentState;

  void dispose() {
    _stateSubscription.cancel();
    _stateMachine.dispose();
  }
}
