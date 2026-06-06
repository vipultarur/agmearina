import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';

class TimerRing extends StatelessWidget {
  final Color color;
  final int remaining;
  final int maxSeconds;

  const TimerRing({
    super.key,
    required this.color,
    required this.remaining,
    required this.maxSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (maxSeconds == 0 ? 0.0 : remaining / maxSeconds)
        .clamp(0.0, 1.0)
        .toDouble();
    final minutes = (remaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (remaining % 60).toString().padLeft(2, '0');
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: progress),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double animatedProgress, Widget? child) {
        return SizedBox(
          width: AppDimensions.timerOuterSize,
          height: AppDimensions.timerOuterSize,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: AppDimensions.timerInnerSize,
                height: AppDimensions.timerInnerSize,
                decoration: const BoxDecoration(
                  color: AppColors.cardSurface,
                  shape: BoxShape.circle,
                ),
              ),
              CustomPaint(
                size: Size.square(AppDimensions.timerPaintSize),
                painter: RingPainter(color: color, progress: animatedProgress),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Text(
                  '$minutes:$seconds',
                  key: ValueKey<int>(remaining),
                  style: AppTextStyles.metric,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RingPainter extends CustomPainter {
  final Color color;
  final double progress;

  const RingPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppDimensions.timerStroke
      ..strokeCap = StrokeCap.round;

    paint.color = AppColors.timerTrack;
    canvas.drawArc(rect.deflate(6.r), -math.pi / 2, math.pi * 2, false, paint);

    paint.color = color;
    canvas.drawArc(
      rect.deflate(6.r),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(RingPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.progress != progress;
  }
}
