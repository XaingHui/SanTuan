import 'dart:math';
import 'package:flutter/material.dart';
import '../pet_skin.dart';

/// 小幽灵角色 — 蓝白色Q弹幽灵
class GhostSkin implements PetSkin {
  @override
  String get id => 'ghost';
  @override
  String get name => '小幽灵';
  @override
  List<String> get supportedMoods => ['idle', 'happy', 'love', 'sleepy', 'surprised'];

  @override
  void paint(Canvas canvas, Size size, {
    required String mood,
    required double breathT,
    required double bounceT,
  }) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final breathScale = 1.0 + sin(breathT * pi) * 0.03;
    final bounceY = -sin(bounceT * pi) * 15;
    // 飘浮效果
    final floatY = sin(breathT * pi * 2) * 6;

    canvas.save();
    canvas.translate(cx, cy + bounceY + floatY);
    canvas.scale(breathScale);

    // ── 阴影 ──
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, 75 - bounceY * 0.2 - floatY * 0.5), width: 80, height: 12),
      Paint()..color = Colors.black.withValues(alpha: 0.08)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // ── 身体 (幽灵形) ──
    final bodyColors = _bodyColors(mood);
    final bodyPath = Path();
    // 头部圆弧
    bodyPath.moveTo(-50, 10);
    bodyPath.quadraticBezierTo(-55, -60, 0, -65);
    bodyPath.quadraticBezierTo(55, -60, 50, 10);
    // 底部波浪尾巴
    final tailWave = sin(breathT * pi * 2) * 5;
    bodyPath.lineTo(50, 50);
    bodyPath.quadraticBezierTo(35, 40 + tailWave, 25, 55);
    bodyPath.quadraticBezierTo(12, 45 - tailWave, 0, 58);
    bodyPath.quadraticBezierTo(-12, 45 + tailWave, -25, 55);
    bodyPath.quadraticBezierTo(-35, 40 - tailWave, -50, 50);
    bodyPath.close();

    final bodyRect = Rect.fromLTRB(-55, -65, 55, 58);
    canvas.drawPath(bodyPath, Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.4),
        radius: 1.0,
        colors: bodyColors,
      ).createShader(bodyRect));

    // ── 半透明光晕 ──
    canvas.drawCircle(
      const Offset(0, -20),
      55,
      Paint()..color = Colors.white.withValues(alpha: 0.08)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    // ── 表情 ──
    _drawFace(canvas, mood, breathT);

    // ── 小手 ──
    _drawArms(canvas, mood, breathT);

    canvas.restore();
  }

  List<Color> _bodyColors(String mood) {
    switch (mood) {
      case 'happy': return [const Color(0xFFE8F5E9), const Color(0xFF66BB6A)];
      case 'love': return [const Color(0xFFFCE4EC), const Color(0xFFEC407A)];
      case 'sleepy': return [const Color(0xFFEDE7F6), const Color(0xFF7E57C2)];
      case 'surprised': return [const Color(0xFFFFF3E0), const Color(0xFFFFA726)];
      default: return [const Color(0xFFE3F2FD), const Color(0xFF90CAF9)];
    }
  }

  void _drawArms(Canvas canvas, String mood, double breathT) {
    final colors = _bodyColors(mood);
    final armPaint = Paint()..color = colors[1].withValues(alpha: 0.4)..style = PaintingStyle.stroke..strokeWidth = 5..strokeCap = StrokeCap.round;
    final wave = sin(breathT * pi) * 0.2;

    canvas.save(); canvas.translate(-45, 0); canvas.rotate(-0.4 + wave);
    canvas.drawLine(Offset.zero, const Offset(-15, 15), armPaint); canvas.restore();
    canvas.save(); canvas.translate(45, 0); canvas.rotate(0.4 - wave);
    canvas.drawLine(Offset.zero, const Offset(15, 15), armPaint); canvas.restore();
  }

  void _drawFace(Canvas canvas, String mood, double breathT) {
    switch (mood) {
      case 'happy': _drawHappy(canvas); break;
      case 'love': _drawLove(canvas); break;
      case 'sleepy': _drawSleepy(canvas, breathT); break;
      case 'surprised': _drawSurprised(canvas); break;
      default: _drawIdle(canvas, breathT);
    }
  }

  void _drawIdle(Canvas canvas, double breathT) {
    final eyePaint = Paint()..color = const Color(0xFF263238);
    final blinkScale = breathT > 0.92 ? (1.0 - breathT) * 12.5 : 1.0;
    // 大圆眼 (幽灵特色)
    canvas.drawOval(Rect.fromCenter(center: const Offset(-18, -15), width: 18, height: 20 * blinkScale), eyePaint);
    canvas.drawOval(Rect.fromCenter(center: const Offset(18, -15), width: 18, height: 20 * blinkScale), eyePaint);
    // 大高光
    canvas.drawCircle(const Offset(-13, -20), 5, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(23, -20), 5, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(-19, -13), 2.5, Paint()..color = Colors.white.withValues(alpha: 0.6));
    canvas.drawCircle(const Offset(17, -13), 2.5, Paint()..color = Colors.white.withValues(alpha: 0.6));
    // 微笑
    canvas.drawPath(Path()..moveTo(-8, 8)..quadraticBezierTo(0, 16, 8, 8),
      Paint()..color = const Color(0xFF263238)..style = PaintingStyle.stroke..strokeWidth = 2..strokeCap = StrokeCap.round);
  }

  void _drawHappy(Canvas canvas) {
    final curvePaint = Paint()..color = const Color(0xFF263238)..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCenter(center: const Offset(-18, -12), width: 22, height: 16), pi * 0.1, pi * 0.8, false, curvePaint);
    canvas.drawArc(Rect.fromCenter(center: const Offset(18, -12), width: 22, height: 16), pi * 0.1, pi * 0.8, false, curvePaint);
    canvas.drawPath(Path()..moveTo(-12, 6)..quadraticBezierTo(0, 22, 12, 6)..close(), Paint()..color = const Color(0xFF263238));
    // 舌头
    canvas.drawOval(Rect.fromCenter(center: const Offset(0, 14), width: 10, height: 6), Paint()..color = const Color(0xFFEF9A9A));
  }

  void _drawLove(Canvas canvas) {
    final heartPaint = Paint()..color = const Color(0xFFE91E63);
    for (final ox in [-18.0, 18.0]) {
      canvas.save(); canvas.translate(ox, -14);
      canvas.scale(1.2);
      canvas.drawPath(Path()..moveTo(0, 4)..cubicTo(-8, -4, -14, 2, -7, 8)..lineTo(0, 14)..lineTo(7, 8)..cubicTo(14, 2, 8, -4, 0, 4)..close(), heartPaint);
      canvas.restore();
    }
    canvas.drawPath(Path()..moveTo(-8, 10)..quadraticBezierTo(0, 18, 8, 10),
      Paint()..color = const Color(0xFF263238)..style = PaintingStyle.stroke..strokeWidth = 2..strokeCap = StrokeCap.round);
  }

  void _drawSleepy(Canvas canvas, double breathT) {
    final linePaint = Paint()..color = const Color(0xFF263238)..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCenter(center: const Offset(-18, -12), width: 20, height: 10), 0, pi, false, linePaint);
    canvas.drawArc(Rect.fromCenter(center: const Offset(18, -12), width: 20, height: 10), 0, pi, false, linePaint);
    canvas.drawOval(Rect.fromCenter(center: const Offset(0, 10), width: 8, height: 10), linePaint);
    final zOff = sin(breathT * pi) * 4;
    _drawText(canvas, 'Z', Offset(40, -50 + zOff), 16, Colors.white60);
    _drawText(canvas, 'z', Offset(52, -68 + zOff * 0.7), 12, Colors.white38);
  }

  void _drawSurprised(Canvas canvas) {
    final eyePaint = Paint()..color = const Color(0xFF263238);
    canvas.drawCircle(const Offset(-18, -15), 12, eyePaint);
    canvas.drawCircle(const Offset(18, -15), 12, eyePaint);
    canvas.drawCircle(const Offset(-14, -19), 5, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(22, -19), 5, Paint()..color = Colors.white);
    canvas.drawOval(Rect.fromCenter(center: const Offset(0, 10), width: 14, height: 18),
      Paint()..color = const Color(0xFF263238)..style = PaintingStyle.stroke..strokeWidth = 2.5);
  }

  void _drawText(Canvas canvas, String text, Offset offset, double fontSize, Color color) {
    final tp = TextPainter(text: TextSpan(text: text, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: color)), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, offset);
  }
}
