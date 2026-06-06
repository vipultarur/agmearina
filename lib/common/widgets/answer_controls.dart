import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_motion.dart';

class BottomAnswerSheet extends StatelessWidget {
  final Widget child;

  const BottomAnswerSheet({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.answerSheetRadius),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20.r,
            offset: Offset(0, -6.h),
          ),
        ],
      ),
      child: child,
    );
  }
}

class NumericKeypad extends StatelessWidget {
  final Color color;
  final ValueChanged<String> onDigit;
  final VoidCallback onClear;
  final VoidCallback onBackspace;
  final bool allowNegative;

  const NumericKeypad({
    super.key,
    required this.color,
    required this.onDigit,
    required this.onClear,
    required this.onBackspace,
    this.allowNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <List<String>>[
      <String>['7', '8', '9'],
      <String>['4', '5', '6'],
      <String>['1', '2', '3'],
      <String>[allowNegative ? '-' : 'Clear', '0', 'back'],
    ];
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final availW = constraints.maxWidth;
        final availH =
            constraints.maxHeight.isFinite ? constraints.maxHeight : 400.h;

        final fromWidth = availW / 4.0;
        final fromHeight = availH / 5.0;
        final buttonSize = math.min(fromWidth, fromHeight).clamp(48.0, 92.0);

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            for (int rowIndex = 0; rowIndex < rows.length; rowIndex++)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  for (
                    int valueIndex = 0;
                    valueIndex < rows[rowIndex].length;
                    valueIndex++
                  )
                    StaggeredEntry(
                      index: rowIndex * 3 + valueIndex,
                      stepDelay: const Duration(milliseconds: 16),
                      child: _buttonFor(
                        rows[rowIndex][valueIndex],
                        buttonSize,
                      ),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buttonFor(String value, double size) {
    if (value == 'Clear') {
      return KeyButton(
        key: const ValueKey<String>('key-clear'),
        label: 'Clear',
        color: AppColors.cardSurface,
        rounded: false,
        size: size,
        onTap: onClear,
      );
    }
    if (value == 'back') {
      return KeyButton(
        key: const ValueKey<String>('key-backspace'),
        label: '',
        icon: Icons.backspace_rounded,
        color: AppColors.cardSurface,
        rounded: false,
        size: size,
        onTap: onBackspace,
      );
    }
    return KeyButton(
      key: ValueKey<String>('key-$value'),
      label: value,
      color: color.withValues(alpha: 0.62),
      rounded: false,
      size: size,
      onTap: () => onDigit(value),
    );
  }
}

class KeyButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final VoidCallback onTap;
  final bool rounded;
  final double? size;
  final Color? borderColor;
  final double? borderRadius;

  const KeyButton({
    super.key,
    required this.label,
    this.icon,
    required this.color,
    required this.onTap,
    this.rounded = false,
    this.size,
    this.borderColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = size ?? AppDimensions.keypadButtonSize;
    return AppBounce(
      onTap: onTap,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius ?? AppDimensions.keypadRoundedRadius),
          shape: BoxShape.rectangle,
          border: Border.all(
            color: borderColor ?? AppColors.border,
            width: AppDimensions.regularStroke,
          ),
        ),
        child: Center(
          child: icon == null
              ? Text(
                  label,
                  style: label.length > 1
                      ? AppTextStyles.keypadAction
                      : AppTextStyles.keypadNumber,
                )
              : Icon(icon, color: AppColors.black, size: buttonSize * 0.35),
        ),
      ),
    );
  }
}

class AnswerList extends StatelessWidget {
  final List<String> choices;
  final Color color;
  final ValueChanged<String> onChoice;

  const AnswerList({
    super.key,
    required this.choices,
    required this.color,
    required this.onChoice,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final availH =
            constraints.maxHeight.isFinite ? constraints.maxHeight : 300.h;
        final count = choices.length;
        final gap = 12.h;
        final btnH = ((availH - (count - 1) * gap) / count).clamp(48.0, 72.0);

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            for (int index = 0; index < choices.length; index++)
              StaggeredEntry(
                index: index,
                child: WideAnswerButton(
                  label: choices[index],
                  color: color.withValues(alpha: 0.70),
                  onTap: () => onChoice(choices[index]),
                  height: btnH,
                ),
              ),
          ],
        );
      },
    );
  }
}

class TrueFalseButtons extends StatelessWidget {
  final ValueChanged<String> onChoice;

  const TrueFalseButtons({super.key, required this.onChoice});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        StaggeredEntry(
          index: 0,
          child: WideAnswerButton(
            key: const ValueKey<String>('true-button'),
            label: 'True',
            color: AppColors.trueGreen,
            onTap: () => onChoice('True'),
          ),
        ),
        StaggeredEntry(
          index: 1,
          child: WideAnswerButton(
            key: const ValueKey<String>('false-button'),
            label: 'False',
            color: AppColors.red,
            onTap: () => onChoice('False'),
            whiteText: true,
          ),
        ),
      ],
    );
  }
}

class WideAnswerButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool whiteText;
  final double? height;

  const WideAnswerButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
    this.whiteText = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return AppBounce(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height ?? AppDimensions.answerButtonHeight,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppDimensions.answerButtonRadius),
          border: Border.all(
            color: AppColors.border,
            width: AppDimensions.regularStroke,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.wideAnswer.copyWith(
              color: whiteText ? Colors.white : AppColors.black,
            ),
          ),
        ),
      ),
    );
  }
}
