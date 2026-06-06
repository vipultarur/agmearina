import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';

class DottedArc extends StatelessWidget {
  final Color color;

  const DottedArc({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(130.r),
      painter: DottedArcPainter(color),
    );
  }
}

class DottedArcPainter extends CustomPainter {
  final Color color;

  const DottedArcPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 130, size.height / 130);
    final dot = Paint()..color = AppColors.black.withValues(alpha: 0.72);
    for (int row = 0; row < 10; row++) {
      for (int col = 0; col < 10; col++) {
        final x = col * 13.0;
        final y = row * 13.0;
        if ((x - 96) * (x - 96) + (y - 96) * (y - 96) < 76 * 76) {
          canvas.drawCircle(Offset(x, y), 2, dot);
        }
      }
    }
    final cutout = Paint()..color = color;
    canvas.drawCircle(const Offset(96, 96), 58, cutout);
    canvas.restore();
  }

  @override
  bool shouldRepaint(DottedArcPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class ConfettiDash extends StatelessWidget {
  final bool light;

  const ConfettiDash({super.key, this.light = false});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.78,
      child: Container(
        width: 32.w,
        height: 4.h,
        color: light ? Colors.white : AppColors.black,
      ),
    );
  }
}
