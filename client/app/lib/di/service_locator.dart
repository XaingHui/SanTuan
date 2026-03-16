import 'package:get_it/get_it.dart';
import 'package:platform_shell/platform_shell.dart';
import 'package:pet_renderer/pet_renderer.dart';
import 'package:animation_engine/animation_engine.dart';
import 'package:emotion_bridge/emotion_bridge.dart';

final locator = GetIt.instance;

Future<void> setupServiceLocator() async {
  // 平台窗口控制器
  locator.registerLazySingleton<ShellController>(
    () => ShellController.forCurrentPlatform(),
  );

  // 角色渲染器 — 默认使用 Rive (MVP), 可切换 Thermion (3D)
  locator.registerLazySingleton<PetRendererInterface>(
    () => RiveRenderer(),
  );

  // 动画引擎
  locator.registerLazySingleton<AnimationController>(
    () => AnimationController(renderer: locator<PetRendererInterface>()),
  );

  // 通信桥 — MVP 阶段使用 Mock, V1.0 切换 WebSocket
  locator.registerLazySingleton<EmotionBridgeInterface>(
    () => MockBridge(),
  );
}
