import 'dart:math';
import 'package:flutter/material.dart';
import '../pet_skin.dart';

/// 小机器人角色 — 银灰色方圆机器人
class RobotSkin implements PetSkin {
  @override
  String get id => 'robot';
  @override
  String get name => '小铁';
  @override
  List<String> get supportedMoods => ['idle', 'happy', 'love', 'sleepy', 'surprised'];

  @override
  void paint(Canvas canvas, Size size, {
    required String mood,
    required double breathT,
    required double bounceT,
  }) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 5;
    final breathScale = 1.0 + sin(breathT * pi) * 0.015;
    final bounceY = -sin(bounceT * pi) * 10;

    canvas.save();
    canvas.translate(cx, cy + bounceY);
    canvas.scale(breathScale);

    // ── 阴影 ──
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, 65 - bounceY * 0.3), width: 90, height: 14),
      Paint()..color = Colors.black.withValues(alpha: 0.1)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // ── 天线 ──
    final antennaWave = sin(breathT * pi * 2) * 3;
    canvas.drawLine(const Offset(0, -65), Offset(0 + antennaWave, -85), Paint()..color = const Color(0xFF78909C)..strokeWidth = 3..strokeCap = StrokeCap.round);
    final antennaColor = _moodAccent(mood);
    canvas.drawCircle(Offset(0 + antennaWave, -88), 5, Paint()..color = antennaColor);
    // 天线发光
    canvas.drawCircle(Offset(0 + antennaWave, -88), 8, Paint()..color = antennaColor.withValues(alpha: 0.2 + sin(breathT * pi) * 0.15)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));

    // ── 头部 (圆角矩形) ──
    final headRect = Rect.fromCenter(center: const Offset(0, -30), width: 100, height: 70);
    final headGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [const Color(0xFFECEFF1), const Color(0xFFB0BEC5)],
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(headRect, const Radius.circular(25)),
      Paint()..shader = headGradient.createShader(headRect),
    );
    // 头部边框高光
    canvas.drawRRect(
      RRect.fromRectAndRadius(headRect, const Radius.circular(25)),
      Paint()..color = Colors.white.withValues(alpha: 0.3)..style = PaintingStyle.stroke..strokeWidth = 1.5,
    );

    // ── 身体 ──
    final bodyRect = Rect.fromCenter(center: const Offset(0, 25), width: 80, height: 60);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(18)),
      Paint()..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFFCFD8DC), const Color(0xFF90A4AE)],
      ).createShader(bodyRect),
    );
    // 胸口指示灯
    final indicatorColor = _moodAccent(mood);
    canvas.drawCircle(const Offset(0, 20), 6, Paint()..color = indicatorColor);
    canvas.drawCircle(const Offset(0, 20), 10, Paint()..color = indicatorColor.withValues(alpha: 0.15 + sin(breathT * pi) * 0.1)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));

    // ── 表情 (LED 屏幕) ──
    _drawFace(canvas, mood, breathT);

    // ── 手臂 ──
    _drawArms(canvas, breathT);

    // ── 脚 ──
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(-18, 58), width: 24, height: 12), const Radius.circular(6)),
      Paint()..color = const Color(0xFF78909C));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(18, 58), width: 24, height: 12), const Radius.circular(6)),
      Paint()..color = const Color(0xFF78909C));

    canvas.restore();
  }

  Color _moodAccent(String mood) {
    switch (mood) {
      case 'happy': return const Color(0xFF66BB6A);
      case 'love': return const Color(0xFFEC407A);
      case 'sleepy': return const Color(0xFF7E57C2);
      case 'surprised': return const Color(0xFFFFA726);
      default: return const Color(0xFF42A5F5);
    }
  }

  void _drawArms(Canvas canvas, double breathT) {
    final armPaint = Paint()..color = const Color(0xFF90A4AE)..strokeWidth = 6..strokeCap = StrokeCap.round;
    final wave = sin(breathT * pi) * 0.1;
    canvas.save(); canvas.translate(-42, 15); canvas.rotate(-0.2 + wave);
    canvas.drawLine(Offset.zero, const Offset(-14, 18), armPaint);
    canvas.drawCircle(const Offset(-14, 22), 5, Paint()..color = const Color(0xFF78909C)); canvas.restore();
    canvas.save(); canvas.translate(42, 15); canvas.rotate(0.2 - wave);
    canvas.drawLine(Offset.zero, const Offset(14, 18), armPaint);
    canvas.drawCircle(const Offset(14, 22), 5, Paint()..color = const Color(0xFF78909C)); canvas.restore();
  }

  void _drawFace(Canvas canvas, String mood, double breathT) {
    // LED 屏幕背景
    final screenRect = Rect.fromCenter(center: const Offset(0, -30), width: 75, height: 42);
    canvas.drawRRect(
      RRect.fromRectAndRadius(screenRect, const Radius.circular(10)),
      Paint()..color = const Color(0xFF37474F),
    );

    final ledColor = _moodAccent(mood);
    final ledPaint = Paint()..color = ledColor..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    final ledFill = Paint()..color = ledColor;

    switch (mood) {
      case 'happy':
        // ^_^ 弯弯眼
        canvas.drawArc(Rect.fromCenter(center: const Offset(-16, -33), width: 16, height: 10), pi * 1.1, pi * 0.8, false, ledPaint);
        canvas.drawArc(Rect.fromCenter(center: const Offset(16, -33), width: 16, height: 10), pi * 1.1, pi * 0.8, false, ledPaint);
        canvas.drawPath(Path()..moveTo(-12, -22)..quadraticBezierTo(0, -15, 12, -22), ledPaint);
        break;

      case 'love':
        // 爱心眼
        for (final ox in [-16.0, 16.0]) {
          canvas.save(); canvas.translate(ox, -33); canvas.scale(0.7);
          canvas.drawPath(Path()..moveTo(0, 4)..cubicTo(-8, -4, -14, 2, -7, 8)..lineTo(0, 14)..lineTo(7, 8)..cubicTo(14, 2, 8, -4, 0, 4)..close(), ledFill);
          canvas.restore();
        }
        canvas.drawPath(Path()..moveTo(-8, -22)..quadraticBezierTo(0, -16, 8, -22), ledPaint);
        break;

      case 'sleepy':
        // - - 闭眼
        canvas.drawLine(const Offset(-24, -32), const Offset(-8, -32), ledPaint);
        canvas.drawLine(const Offset(8, -32), const Offset(24, -32), ledPaint);
        canvas.drawOval(Rect.fromCenter(center: const Offset(0, -22), width: 6, height: 8), ledPaint);
        final zOff = sin(breathT * pi) * 3;
        _drawText(canvas, 'z', Offset(30, -48 + zOff), 10, ledColor.withValues(alpha: 0.6));
        break;

      case 'surprised':
        // O O 大眼
        canvas.drawCircle(const Offset(-16, -32), 7, ledPaint);
        canvas.drawCircle(const Offset(16, -32), 7, ledPaint);
        canvas.drawOval(Rect.fromCenter(center: const Offset(0, -20), width: 10, height: 12), ledPaint);
        break;

      default:
        // idle: 普通点阵眼
        final blinkScale = breathT > 0.9 ? (1.0 - breathT) * 10 : 1.0;
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(-16, -32), width: 10, height: 12 * blinkScale), const Radius.circular(3)), ledFill);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(16, -32), width: 10, height: 12 * blinkScale), const Radius.circular(3)), ledFill);
        canvas.drawPath(Path()..moveTo(-8, -22)..quadraticBezierTo(0, -17, 8, -22), ledPaint);
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, double fontSize, Color color) {
    final tp = TextPainter(text: TextSpan(text: text, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: color)), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, offset);
  }
}
