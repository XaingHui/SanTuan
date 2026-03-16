import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter/material.dart';

/// 透明窗口控制器
///
/// 封装 window_manager + flutter_acrylic，提供统一的：
/// - 窗口透明化
/// - 置顶 (always on top)
/// - 跳过任务栏
/// - 点击穿透切换
class ShellController {
  bool _initialized = false;
  bool _ignoring = true;

  /// 根据当前平台创建控制器
  factory ShellController.forCurrentPlatform() {
    return ShellController._();
  }

  ShellController._();

  /// 初始化透明窗口
  Future<void> initialize({
    Size windowSize = const Size(350, 400),
    bool alwaysOnTop = true,
    bool skipTaskbar = true,
  }) async {
    if (_initialized) return;

    // 桌面端才初始化窗口管理
    if (_isDesktop) {
      await windowManager.ensureInitialized();
      await Window.initialize();

      final windowOptions = WindowOptions(
        size: windowSize,
        backgroundColor: Colors.transparent,
        skipTaskbar: skipTaskbar,
        alwaysOnTop: alwaysOnTop,
        titleBarStyle: TitleBarStyle.hidden,
      );

      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await Window.setEffect(effect: WindowEffect.transparent);
        await windowManager.setHasShadow(false);
        await windowManager.setBackgroundColor(Colors.transparent);

        // 默认开启点击穿透 + 转发鼠标移动
        await windowManager.setIgnoreMouseEvents(true, forward: true);
        _ignoring = true;

        await windowManager.show();
      });
    }

    _initialized = true;
  }

  /// 设置点击穿透
  ///
  /// [ignore] = true: 鼠标事件穿透到桌面（背景区域）
  /// [ignore] = false: 捕获鼠标事件（宠物区域）
  Future<void> setIgnoreMouseEvents(bool ignore) async {
    if (!_isDesktop || _ignoring == ignore) return;
    _ignoring = ignore;

    if (ignore) {
      await windowManager.setIgnoreMouseEvents(true, forward: true);
    } else {
      await windowManager.setIgnoreMouseEvents(false);
    }
  }

  /// 设置置顶状态
  Future<void> setAlwaysOnTop(bool onTop) async {
    if (!_isDesktop) return;
    await windowManager.setAlwaysOnTop(onTop);
  }

  /// 开始拖拽窗口
  Future<void> startDragging() async {
    if (!_isDesktop) return;
    await windowManager.startDragging();
  }

  /// 设置窗口位置
  Future<void> setPosition(Offset position) async {
    if (!_isDesktop) return;
    await windowManager.setPosition(position);
  }

  /// 获取窗口位置
  Future<Offset> getPosition() async {
    if (!_isDesktop) return Offset.zero;
    return await windowManager.getPosition();
  }

  bool get isDesktop => _isDesktop;

  bool get _isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
}
