import 'dart:async';
import 'animation_command.dart';

/// 动画状态机
///
/// 管理当前动画状态、处理状态转换、维护动画队列。
/// 支持多层动画混合（emotion/gesture/idle/override）。
class AnimationStateMachine {
  String _currentState = 'idle';
  final Map<String, List<_Transition>> _transitions = {};
  final List<AnimationCommand> _queue = [];
  final _stateController = StreamController<String>.broadcast();

  /// 当前状态
  String get currentState => _currentState;

  /// 状态变化流
  Stream<String> get stateStream => _stateController.stream;

  /// 注册状态转换规则
  void addTransition(String from, String to, {Duration? minDuration}) {
    _transitions.putIfAbsent(from, () => []);
    _transitions[from]!.add(_Transition(to: to, minDuration: minDuration));
  }

  /// 处理动画指令
  Future<bool> processCommand(AnimationCommand command) async {
    switch (command.action) {
      case AnimationAction.transition:
        return _transitionTo(command.targetState);

      case AnimationAction.playOnce:
        final success = _transitionTo(command.targetState);
        // play_once 完成后回到 idle
        if (success) {
          Future.delayed(
            Duration(milliseconds: command.params.blendDurationMs + 1000),
            () => _transitionTo('idle'),
          );
        }
        return success;

      case AnimationAction.queue:
        _queue.add(command);
        if (_currentState == 'idle') _processQueue();
        return true;

      case AnimationAction.interrupt:
        _queue.clear();
        return _transitionTo(command.targetState);
    }
  }

  bool _transitionTo(String targetState) {
    // 允许所有转换（在 MVP 阶段不做严格校验）
    _currentState = targetState;
    _stateController.add(_currentState);
    return true;
  }

  Future<void> _processQueue() async {
    while (_queue.isNotEmpty) {
      final command = _queue.removeAt(0);
      await processCommand(command);
    }
  }

  void dispose() {
    _stateController.close();
  }
}

class _Transition {
  final String to;
  final Duration? minDuration;

  _Transition({required this.to, this.minDuration});
}
