import 'dart:math';
import 'package:flutter/material.dart';
import '../pet_skin.dart';

/// 小团子角色 — 黄色圆润猫咪
class TuanziSkin implements PetSkin {
  @override
  String get id => 'tuanzi';
  @override
  String get name => '小团子';
  @override
  List<String> get supportedMoods => ['idle', 'happy', 'love', 'sleepy', 'surprised'];

  @override
  void paint(Canvas canvas, Size size, {
    required String mood,
    required double breathT,
    required double bounceT,
  }) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 10;
    final breathScale = 1.0 + sin(breathT * pi) * 0.02;
    final bounceY = -sin(bounceT * pi) * 12;

    canvas.save();
    canvas.translate(cx, cy + bounceY);
    canvas.scale(breathScale);

    _drawShadow(canvas, bounceY);
    _drawBody(canvas, mood);
    _drawBlush(canvas, breathT);
    _drawFace(canvas, mood, breathT);
    _drawEars(canvas, mood);
    _drawArms(canvas, mood, breathT);

    canvas.restore();
  }

  List<Color> _bodyColors(String mood) {
    switch (mood) {
      case 'happy': return [const Color(0xFFFFE0B2), const Color(0xFFFF9800)];
      case 'love': return [const Color(0xFFF8BBD0), const Color(0xFFE91E63)];
      case 'sleepy': return [const Color(0xFFE1BEE7), const Color(0xFF9C27B0)];
      case 'surprised': return [const Color(0xFFB3E5FC), const Color(0xFF03A9F4)];
      default: return [const Color(0xFFFFF9C4), const Color(0xFFFFC107)];
    }
  }

  void _drawShadow(Canvas canvas, double bounceY) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, 60 - bounceY * 0.3), width: 100, height: 16),
      Paint()..color = Colors.black.withValues(alpha: 0.1)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  void _drawBody(Canvas canvas, String mood) {
    final colors = _bodyColors(mood);
    final bodyRect = Rect.fromCenter(center: Offset.zero, width: 140, height: 140);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(60)),
      Paint()..shader = RadialGradient(center: const Alignment(-0.3, -0.3), colors: colors).createShader(bodyRect),
    );
  }

  void _drawBlush(Canvas canvas, double breathT) {
    final blushPaint = Paint()..color = const Color(0xFFFFB3B3).withValues(alpha: 0.5 + breathT * 0.2);
    canvas.drawOval(Rect.fromCenter(center: const Offset(-38, 15), width: 22, height: 14), blushPaint);
    canvas.drawOval(Rect.fromCenter(center: const Offset(38, 15), width: 22, height: 14), blushPaint);
  }

  void _drawEars(Canvas canvas, String mood) {
    final earPaint = Paint()..color = _bodyColors(mood)[1].withValues(alpha: 0.7);
    final leftEar = Path()..moveTo(-45, -55)..quadraticBezierTo(-60, -90, -35, -80)..quadraticBezierTo(-25, -70, -35, -55)..close();
    final rightEar = Path()..moveTo(45, -55)..quadraticBezierTo(60, -90, 35, -80)..quadraticBezierTo(25, -70, 35, -55)..close();
    canvas.drawPath(leftEar, earPaint);
    canvas.drawPath(rightEar, earPaint);
  }

  void _drawArms(Canvas canvas, String mood, double breathT) {
    final armPaint = Paint()..color = _bodyColors(mood)[1].withValues(alpha: 0.6)..style = PaintingStyle.stroke..strokeWidth = 6..strokeCap = StrokeCap.round;
    final waveAngle = sin(breathT * pi) * 0.15;
    canvas.save(); canvas.translate(-60, 10); canvas.rotate(-0.3 + waveAngle);
    canvas.drawLine(Offset.zero, const Offset(-18, 20), armPaint); canvas.restore();
    canvas.save(); canvas.translate(60, 10); canvas.rotate(0.3 - waveAngle);
    canvas.drawLine(Offset.zero, const Offset(18, 20), armPaint); canvas.restore();
  }

  void _drawFace(Canvas canvas, String mood, double breathT) {
    final eyePaint = Paint()..color = const Color(0xFF3E2723);
    switch (mood) {
      case 'happy': _drawHappyFace(canvas, breathT); break;
      case 'love': _drawLoveFace(canvas); break;
      case 'sleepy': _drawSleepyFace(canvas, breathT); break;
      case 'surprised': _drawSurprisedFace(canvas); break;
      default: _drawIdleFace(canvas, breathT);
    }
  }

  void _drawIdleFace(Canvas canvas, double breathT) {
    final eyePaint = Paint()..color = const Color(0xFF3E2723);
    final blinkScale = breathT > 0.9 ? (1.0 - breathT) * 10 : 1.0;
    canvas.drawOval(Rect.fromCenter(center: const Offset(-20, -8), width: 14, height: 14 * blinkScale), eyePaint);
    canvas.drawOval(Rect.fromCenter(center: const Offset(20, -8), width: 14, height: 14 * blinkScale), eyePaint);
    canvas.drawCircle(const Offset(-16, -12), 3, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(24, -12), 3, Paint()..color = Colors.white);
    final smilePaint = Paint()..color = const Color(0xFF3E2723)..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    canvas.drawPath(Path()..moveTo(-12, 15)..quadraticBezierTo(0, 25, 12, 15), smilePaint);
  }

  void _drawHappyFace(Canvas canvas, double breathT) {
    final curvePaint = Paint()..color = const Color(0xFF3E2723)..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCenter(center: const Offset(-20, -8), width: 20, height: 14), pi * 0.1, pi * 0.8, false, curvePaint);
    canvas.drawArc(Rect.fromCenter(center: const Offset(20, -8), width: 20, height: 14), pi * 0.1, pi * 0.8, false, curvePaint);
    canvas.drawPath(Path()..moveTo(-16, 12)..quadraticBezierTo(0, 32, 16, 12)..close(), Paint()..color = const Color(0xFF3E2723));
    canvas.drawOval(Rect.fromCenter(center: const Offset(0, 20), width: 14, height: 8), Paint()..color = const Color(0xFFEF9A9A));
  }

  void _drawLoveFace(Canvas canvas) {
    final heartPaint = Paint()..color = const Color(0xFFE91E63);
    for (final ox in [-20.0, 20.0]) {
      canvas.save(); canvas.translate(ox, -8);
      canvas.drawPath(Path()..moveTo(0, 4)..cubicTo(-8, -4, -14, 2, -7, 8)..lineTo(0, 14)..lineTo(7, 8)..cubicTo(14, 2, 8, -4, 0, 4)..close(), heartPaint);
      canvas.restore();
    }
    canvas.drawPath(Path()..moveTo(-10, 18)..quadraticBezierTo(0, 26, 10, 18), Paint()..color = const Color(0xFF3E2723)..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round);
  }

  void _drawSleepyFace(Canvas canvas, double breathT) {
    final linePaint = Paint()..color = const Color(0xFF3E2723)..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCenter(center: const Offset(-20, -6), width: 18, height: 8), 0, pi, false, linePaint);
    canvas.drawArc(Rect.fromCenter(center: const Offset(20, -6), width: 18, height: 8), 0, pi, false, linePaint);
    canvas.drawOval(Rect.fromCenter(center: const Offset(0, 18), width: 8, height: 10), linePaint);
    final zOff = sin(breathT * pi) * 4;
    _drawText(canvas, 'Z', Offset(45, -45 + zOff), 14, Colors.white70);
    _drawText(canvas, 'z', Offset(55, -60 + zOff * 0.7), 11, Colors.white54);
    _drawText(canvas, 'z', Offset(62, -72 + zOff * 0.5), 9, Colors.white38);
  }

  void _drawSurprisedFace(Canvas canvas) {
    final eyePaint = Paint()..color = const Color(0xFF3E2723);
    canvas.drawCircle(const Offset(-20, -8), 10, eyePaint);
    canvas.drawCircle(const Offset(20, -8), 10, eyePaint);
    canvas.drawCircle(const Offset(-17, -11), 4, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(23, -11), 4, Paint()..color = Colors.white);
    canvas.drawOval(Rect.fromCenter(center: const Offset(0, 18), width: 16, height: 18), Paint()..color = const Color(0xFF3E2723)..style = PaintingStyle.stroke..strokeWidth = 2.5);
  }

  void _drawText(Canvas canvas, String text, Offset offset, double fontSize, Color color) {
    final tp = TextPainter(text: TextSpan(text: text, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: color)), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, offset);
  }
}
