import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';

/// 宠物精灵 — 支持多种图片来源
///
/// 图片加载优先级（从高到低）：
/// 1. 用户自定义目录 (customDir) — 用户上传的 GIF/PNG/WebP
/// 2. 内置 assets — 开发者预置的角色包
/// 3. CustomPaint fallback — 兜底的内置形象
///
/// 支持格式: GIF(动图) / PNG / WebP(动图) / APNG
/// 后续扩展: MP4 需要 video_player 包，3D 模型用 Thermion
class PetSprite extends StatelessWidget {
  final String mood;
  final String character;
  final String? customDir;

  const PetSprite({super.key, this.mood = 'idle', this.character = 'mochi', this.customDir});

  @override
  Widget build(BuildContext context) {
    return _buildCharacter();
  }

  Widget _buildCharacter() {
    const exts = ['gif', 'webp', 'png', 'jpg'];

    // 1. 优先从用户自定义目录加载
    if (customDir != null) {
      for (final ext in exts) {
        final file = File('$customDir/$mood.$ext');
        if (file.existsSync()) {
          return Image.file(
            file,
            width: 220,
            height: 260,
            fit: BoxFit.contain,
            gaplessPlayback: true,
          );
        }
      }
    }

    // 2. 从内置 assets 加载
    final base = 'assets/pet/$character/$mood';
    return _AssetImageChain(basePath: base, exts: exts, mood: mood);
  }
}

/// 链式尝试多种格式的 asset 图片
class _AssetImageChain extends StatelessWidget {
  final String basePath;
  final List<String> exts;
  final String mood;
  final int index;

  const _AssetImageChain({
    required this.basePath,
    required this.exts,
    required this.mood,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (index >= exts.length) {
      return _FallbackCharacter(mood: mood);
    }
    return Image.asset(
      '$basePath.${exts[index]}',
      width: 220,
      height: 260,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => _AssetImageChain(
        basePath: basePath,
        exts: exts,
        mood: mood,
        index: index + 1,
      ),
    );
  }
}

/// 内置默认形象 — 白色团子猫（类似蜜桃猫风格）
///
/// 当没有图片资源时显示此默认形象。
/// 一旦用户放入图片，自动切换为图片渲染。
class _FallbackCharacter extends StatelessWidget {
  final String mood;
  const _FallbackCharacter({required this.mood});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(220, 260),
      painter: _MochiPainter(mood: mood),
    );
  }
}

/// 蜜桃猫风格画笔 — 白色圆润身体 + 黑色小耳朵 + 粉色腮红
class _MochiPainter extends CustomPainter {
  final String mood;
  _MochiPainter({required this.mood});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.48;

    // ── 阴影 ──
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, size.height * 0.88), width: 100, height: 14),
      Paint()..color = Colors.black.withValues(alpha: 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // ── 身体 — 白色圆润 ──
    final bodyRect = Rect.fromCenter(center: Offset(cx, cy), width: 150, height: 155);
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.3),
        colors: [Colors.white, const Color(0xFFF5F0EB)],
      ).createShader(bodyRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(65)),
      bodyPaint,
    );
    // 身体轮廓
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(65)),
      Paint()..color = const Color(0xFFD7CCC8)..style = PaintingStyle.stroke..strokeWidth = 1.5,
    );

    // ── 耳朵 — 黑色/深棕 ──
    _drawEars(canvas, cx, cy);

    // ── 腮红 ──
    final blushPaint = Paint()..color = const Color(0xFFFFCDD2).withValues(alpha: 0.7);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 38, cy + 8), width: 24, height: 16), blushPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 38, cy + 8), width: 24, height: 16), blushPaint);

    // ── 表情 ──
    _drawFace(canvas, cx, cy);

    // ── 小手 ──
    _drawArms(canvas, cx, cy);
  }

  void _drawEars(Canvas canvas, double cx, double cy) {
    final earColor = const Color(0xFF4E342E);

    // 左耳 — 外层
    final leftEar = Path()
      ..moveTo(cx - 42, cy - 55)
      ..quadraticBezierTo(cx - 55, cy - 95, cx - 30, cy - 82)
      ..quadraticBezierTo(cx - 20, cy - 72, cx - 32, cy - 55)
      ..close();
    canvas.drawPath(leftEar, Paint()..color = earColor);
    // 左耳 — 内层（粉色）
    final leftInner = Path()
      ..moveTo(cx - 40, cy - 60)
      ..quadraticBezierTo(cx - 48, cy - 85, cx - 32, cy - 78)
      ..quadraticBezierTo(cx - 26, cy - 72, cx - 34, cy - 60)
      ..close();
    canvas.drawPath(leftInner, Paint()..color = const Color(0xFFFFAB91).withValues(alpha: 0.4));

    // 右耳
    final rightEar = Path()
      ..moveTo(cx + 42, cy - 55)
      ..quadraticBezierTo(cx + 55, cy - 95, cx + 30, cy - 82)
      ..quadraticBezierTo(cx + 20, cy - 72, cx + 32, cy - 55)
      ..close();
    canvas.drawPath(rightEar, Paint()..color = earColor);
    final rightInner = Path()
      ..moveTo(cx + 40, cy - 60)
      ..quadraticBezierTo(cx + 48, cy - 85, cx + 32, cy - 78)
      ..quadraticBezierTo(cx + 26, cy - 72, cx + 34, cy - 60)
      ..close();
    canvas.drawPath(rightInner, Paint()..color = const Color(0xFFFFAB91).withValues(alpha: 0.4));
  }

  void _drawArms(Canvas canvas, double cx, double cy) {
    final armPaint = Paint()
      ..color = const Color(0xFFF5F0EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final outlinePaint = Paint()
      ..color = const Color(0xFFD7CCC8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    // 根据心情调整手臂姿势
    switch (mood) {
      case 'happy':
        // 举手欢呼
        canvas.drawLine(Offset(cx - 60, cy - 5), Offset(cx - 75, cy - 30), outlinePaint);
        canvas.drawLine(Offset(cx - 60, cy - 5), Offset(cx - 75, cy - 30), armPaint);
        canvas.drawLine(Offset(cx + 60, cy - 5), Offset(cx + 75, cy - 30), outlinePaint);
        canvas.drawLine(Offset(cx + 60, cy - 5), Offset(cx + 75, cy - 30), armPaint);
        break;
      case 'love':
        // 双手比心
        canvas.drawLine(Offset(cx - 55, cy + 5), Offset(cx - 30, cy - 35), outlinePaint);
        canvas.drawLine(Offset(cx - 55, cy + 5), Offset(cx - 30, cy - 35), armPaint);
        canvas.drawLine(Offset(cx + 55, cy + 5), Offset(cx + 30, cy - 35), outlinePaint);
        canvas.drawLine(Offset(cx + 55, cy + 5), Offset(cx + 30, cy - 35), armPaint);
        break;
      default:
        // 自然下垂
        canvas.drawLine(Offset(cx - 58, cy + 10), Offset(cx - 68, cy + 35), outlinePaint);
        canvas.drawLine(Offset(cx - 58, cy + 10), Offset(cx - 68, cy + 35), armPaint);
        canvas.drawLine(Offset(cx + 58, cy + 10), Offset(cx + 68, cy + 35), outlinePaint);
        canvas.drawLine(Offset(cx + 58, cy + 10), Offset(cx + 68, cy + 35), armPaint);
    }
  }

  void _drawFace(Canvas canvas, double cx, double cy) {
    switch (mood) {
      case 'happy':
        _happyFace(canvas, cx, cy);
      case 'love':
        _loveFace(canvas, cx, cy);
      case 'sleepy':
        _sleepyFace(canvas, cx, cy);
      case 'surprised':
        _surprisedFace(canvas, cx, cy);
      case 'angry':
        _angryFace(canvas, cx, cy);
      default:
        _idleFace(canvas, cx, cy);
    }
  }

  // ── idle: 圆眼微笑 ──
  void _idleFace(Canvas canvas, double cx, double cy) {
    final eye = Paint()..color = const Color(0xFF3E2723);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 20, cy - 12), width: 12, height: 14), eye);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 20, cy - 12), width: 12, height: 14), eye);
    // 高光
    canvas.drawCircle(Offset(cx - 17, cy - 16), 3, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx + 23, cy - 16), 3, Paint()..color = Colors.white);
    // 嘴巴
    canvas.drawPath(
      Path()..moveTo(cx - 6, cy + 10)..quadraticBezierTo(cx, cy + 16, cx + 6, cy + 10),
      Paint()..color = const Color(0xFF5D4037)..style = PaintingStyle.stroke..strokeWidth = 2..strokeCap = StrokeCap.round,
    );
  }

  // ── happy: 弯弯眼大笑 ──
  void _happyFace(Canvas canvas, double cx, double cy) {
    final curve = Paint()..color = const Color(0xFF3E2723)..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCenter(center: Offset(cx - 20, cy - 10), width: 18, height: 12), pi * 0.1, pi * 0.8, false, curve);
    canvas.drawArc(Rect.fromCenter(center: Offset(cx + 20, cy - 10), width: 18, height: 12), pi * 0.1, pi * 0.8, false, curve);
    // 大笑嘴
    final mouth = Path()..moveTo(cx - 14, cy + 8)..quadraticBezierTo(cx, cy + 24, cx + 14, cy + 8)..close();
    canvas.drawPath(mouth, Paint()..color = const Color(0xFF3E2723));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 16), width: 12, height: 6), Paint()..color = const Color(0xFFEF9A9A));
  }

  // ── love: 爱心眼 ──
  void _loveFace(Canvas canvas, double cx, double cy) {
    final heart = Paint()..color = const Color(0xFFE91E63);
    for (final ox in [cx - 20, cx + 20]) {
      canvas.save();
      canvas.translate(ox, cy - 12);
      canvas.scale(0.9);
      canvas.drawPath(
        Path()..moveTo(0, 3)..cubicTo(-7, -4, -12, 1, -6, 7)..lineTo(0, 12)..lineTo(6, 7)..cubicTo(12, 1, 7, -4, 0, 3)..close(),
        heart,
      );
      canvas.restore();
    }
    canvas.drawPath(
      Path()..moveTo(cx - 6, cy + 12)..quadraticBezierTo(cx, cy + 18, cx + 6, cy + 12),
      Paint()..color = const Color(0xFF5D4037)..style = PaintingStyle.stroke..strokeWidth = 2..strokeCap = StrokeCap.round,
    );
  }

  // ── sleepy: 闭眼 + zzz ──
  void _sleepyFace(Canvas canvas, double cx, double cy) {
    final line = Paint()..color = const Color(0xFF3E2723)..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCenter(center: Offset(cx - 20, cy - 8), width: 16, height: 8), 0, pi, false, line);
    canvas.drawArc(Rect.fromCenter(center: Offset(cx + 20, cy - 8), width: 16, height: 8), 0, pi, false, line);
    // 小嘴 o
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 12), width: 7, height: 9), line);
  }

  // ── surprised: 大圆眼 + O嘴 ──
  void _surprisedFace(Canvas canvas, double cx, double cy) {
    final eye = Paint()..color = const Color(0xFF3E2723);
    canvas.drawCircle(Offset(cx - 20, cy - 12), 9, eye);
    canvas.drawCircle(Offset(cx + 20, cy - 12), 9, eye);
    canvas.drawCircle(Offset(cx - 17, cy - 15), 3.5, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx + 23, cy - 15), 3.5, Paint()..color = Colors.white);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 12), width: 14, height: 16),
      Paint()..color = const Color(0xFF3E2723)..style = PaintingStyle.stroke..strokeWidth = 2.5,
    );
  }

  // ── angry: 怒眉 + 撅嘴 ──
  void _angryFace(Canvas canvas, double cx, double cy) {
    final eye = Paint()..color = const Color(0xFF3E2723);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 20, cy - 10), width: 12, height: 13), eye);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 20, cy - 10), width: 12, height: 13), eye);
    canvas.drawCircle(Offset(cx - 17, cy - 14), 3, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx + 23, cy - 14), 3, Paint()..color = Colors.white);
    // 怒眉
    final brow = Paint()..color = const Color(0xFF3E2723)..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 28, cy - 24), Offset(cx - 14, cy - 20), brow);
    canvas.drawLine(Offset(cx + 28, cy - 24), Offset(cx + 14, cy - 20), brow);
    // 撅嘴
    canvas.drawPath(
      Path()..moveTo(cx - 8, cy + 12)..quadraticBezierTo(cx, cy + 6, cx + 8, cy + 12),
      Paint()..color = const Color(0xFF5D4037)..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _MochiPainter old) => old.mood != mood;
}
