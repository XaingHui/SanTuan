import 'dart:convert';
import 'animation_command.dart';

/// JSON 指令解析器
///
/// 将 WebSocket / Mock 传入的 JSON 字符串解析为 AnimationCommand。
/// 支持单条指令和批量指令。
class CommandParser {
  /// 解析单条 JSON 指令
  static AnimationCommand parse(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return AnimationCommand.fromJson(json);
  }

  /// 解析批量 JSON 指令
  static List<AnimationCommand> parseBatch(String jsonString) {
    final list = jsonDecode(jsonString) as List;
    return list
        .map((e) => AnimationCommand.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 序列化指令为 JSON
  static String serialize(AnimationCommand command) {
    return jsonEncode(command.toJson());
  }
}
