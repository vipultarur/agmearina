import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/services/app_feedback.dart';

class AppBounce extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final HitTestBehavior? hitTestBehavior;

  const AppBounce({
    super.key,
    required this.child,
    required this.onTap,
    this.hitTestBehavior,
  });

  @override
  Widget build(BuildContext context) {
    return Bounceable(
      onTap: onTap == null
          ? null
          : () {
              AppFeedback.play(context, AppFeedbackEffect.tap);
              onTap?.call();
            },
      duration: const Duration(milliseconds: 110),
      reverseDuration: const Duration(milliseconds: 110),
      scaleFactor: 0.88,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeOutCubic,
      hitTestBehavior: hitTestBehavior,
      child: child,
    );
  }
}

class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset beginOffset;
  final double beginScale;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 420),
    this.beginOffset = const Offset(0, 0.06),
    this.beginScale = 0.98,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _delayTimer = Timer(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: widget.beginOffset,
          end: Offset.zero,
        ).animate(_curve),
        child: ScaleTransition(
          scale: Tween<double>(
            begin: widget.beginScale,
            end: 1,
          ).animate(_curve),
          child: widget.child,
        ),
      ),
    );
  }
}

class StaggeredEntry extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration baseDelay;
  final Duration stepDelay;

  const StaggeredEntry({
    super.key,
    required this.index,
    required this.child,
    this.baseDelay = Duration.zero,
    this.stepDelay = const Duration(milliseconds: 24),
  });

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(delay: baseDelay + stepDelay * index, child: child);
  }
}

class ResultFeedbackMotion extends StatefulWidget {
  final int trigger;
  final bool correct;
  final Widget child;

  const ResultFeedbackMotion({
    super.key,
    required this.trigger,
    required this.correct,
    required this.child,
  });

  @override
  State<ResultFeedbackMotion> createState() => _ResultFeedbackMotionState();
}

class _ResultFeedbackMotionState extends State<ResultFeedbackMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
  }

  @override
  void didUpdateWidget(ResultFeedbackMotion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final value = Curves.easeOut.transform(_controller.value);
        final scale = widget.correct
            ? 1 + (math.sin(value * math.pi) * 0.035)
            : 1.0;
        final dx = widget.correct
            ? 0.0
            : math.sin(value * math.pi * 5) * 8.w * (1 - value);
        return Transform.translate(
          offset: Offset(dx, 0),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: widget.child,
    );
  }
}
