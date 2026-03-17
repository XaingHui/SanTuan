import 'package:flutter/material.dart';
import 'pet_skin.dart';

/// 宠物角色 Widget — 通过 PetSkin 渲染
///
/// 支持替换不同的角色皮肤（小团子/小幽灵/小铁...）
/// 带呼吸动画 + 表情切换弹跳。
class PetCharacter extends StatefulWidget {
  final PetSkin skin;
  final String mood;

  const PetCharacter({super.key, required this.skin, this.mood = 'idle'});

  @override
  State<PetCharacter> createState() => _PetCharacterState();
}

class _PetCharacterState extends State<PetCharacter>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late AnimationController _bounceController;
  late Animation<double> _breathAnim;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _breathAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
    _bounceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _bounceAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(PetCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood != widget.mood || oldWidget.skin.id != widget.skin.id) {
      _bounceController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _breathController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_breathAnim, _bounceAnim]),
      builder: (context, _) {
        return CustomPaint(
          size: const Size(260, 300),
          painter: _SkinPainter(
            skin: widget.skin,
            mood: widget.mood,
            breathT: _breathAnim.value,
            bounceT: _bounceAnim.value,
          ),
        );
      },
    );
  }
}

class _SkinPainter extends CustomPainter {
  final PetSkin skin;
  final String mood;
  final double breathT;
  final double bounceT;

  _SkinPainter({required this.skin, required this.mood, required this.breathT, required this.bounceT});

  @override
  void paint(Canvas canvas, Size size) {
    // 透明窗口必须先清除画布，否则切换角色时上一帧残留
    canvas.drawRect(Offset.zero & size, Paint()..blendMode = BlendMode.clear);
    skin.paint(canvas, size, mood: mood, breathT: breathT, bounceT: bounceT);
  }

  @override
  bool shouldRepaint(covariant _SkinPainter old) => true;
}
