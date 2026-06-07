import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../common/widgets/answer_controls.dart';
import '../../../../common/widgets/app_motion.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/game_question.dart';

class KeypadPuzzleDisplay extends StatelessWidget {
  final String expression;
  final String input;
  final bool mentalMode;

  const KeypadPuzzleDisplay({
    super.key,
    required this.expression,
    required this.input,
    required this.mentalMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              expression,
              maxLines: 1,
              style: AppTextStyles.equationLarge.copyWith(
                color: mentalMode
                    ? AppColors.text.withValues(alpha: 0.74)
                    : AppColors.black,
                fontSize: mentalMode ? 32.sp : 42.sp,
              ),
            ),
          ),
        ),
        SizedBox(height: 36.h),
        AnswerBox(text: input.isEmpty ? '?' : input),
      ],
    );
  }
}

class MentalArithmeticDisplay extends StatefulWidget {
  final String expression;
  final String input;

  const MentalArithmeticDisplay({
    super.key,
    required this.expression,
    required this.input,
  });

  @override
  State<MentalArithmeticDisplay> createState() => _MentalArithmeticDisplayState();
}

class _MentalArithmeticDisplayState extends State<MentalArithmeticDisplay> {
  late List<String> tokens;
  int currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _parseTokens();
    _startTimer();
  }

  @override
  void didUpdateWidget(MentalArithmeticDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expression != widget.expression) {
      _parseTokens();
      _startTimer();
    }
  }

  void _parseTokens() {
    final RegExp regex = RegExp(r'\d+|[+\-*/]');
    final matches = regex.allMatches(widget.expression);
    tokens = matches.map((m) => m.group(0)!).toList();
    currentIndex = 0;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (currentIndex < tokens.length) {
          currentIndex++;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFinished = currentIndex >= tokens.length;
    final String currentDisplay = isFinished ? '?' : tokens[currentIndex];

    return Column(
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          height: 60.h,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 700),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (Widget child, Animation<double> animation) {
                final isIncoming = child.key == ValueKey<int>(currentIndex);
                final offsetAnimation = Tween<Offset>(
                  begin: isIncoming ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation);
                
                return ClipRect(
                  child: SlideTransition(
                    position: offsetAnimation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  ),
                );
              },
              child: SizedBox(
                key: ValueKey<int>(currentIndex),
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Text(
                    currentDisplay,
                    style: AppTextStyles.equationLarge.copyWith(
                      color: AppColors.text.withValues(alpha: 0.74),
                      fontSize: 42.sp,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 36.h),
        AnswerBox(text: widget.input.isEmpty ? '?' : widget.input),
      ],
    );
  }
}

class ExpressionWithMissingBox extends StatelessWidget {
  final String expression;

  const ExpressionWithMissingBox({super.key, required this.expression});

  @override
  Widget build(BuildContext context) {
    final parts = expression.split('?');
    if (parts.length == 2) {
      return SizedBox(
        width: double.infinity,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(parts[0], style: AppTextStyles.puzzle),
              const SmallMissingBox(),
              Text(parts[1], style: AppTextStyles.puzzle),
            ],
          ),
        ),
      );
    }
    return CenterExpression(expression: expression);
  }
}

class CenterExpression extends StatelessWidget {
  final String expression;

  const CenterExpression({super.key, required this.expression});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 36.h),
      child: SizedBox(
        width: double.infinity,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            expression,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: AppTextStyles.puzzle,
          ),
        ),
      ),
    );
  }
}

class SmallMissingBox extends StatelessWidget {
  const SmallMissingBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58.r,
      height: 58.r,
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(
          color: AppColors.border,
          width: AppDimensions.strongStroke,
        ),
      ),
      child: Center(child: Text('?', style: AppTextStyles.puzzle)),
    );
  }
}

class AnswerBox extends StatelessWidget {
  final String text;

  const AnswerBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60.h,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.border,
          width: AppDimensions.strongStroke,
        ),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Text(
              text,
              key: ValueKey<bool>(text == '?'),
              style: AppTextStyles.keypadNumber,
            ),
          ),
        ),
      ),
    );
  }
}

class DualGameDisplay extends StatelessWidget {
  final String expression;
  final String firstInput;
  final String secondInput;
  final int activeIndex;
  final ValueChanged<int> onSelect;

  const DualGameDisplay({
    super.key,
    required this.expression,
    required this.firstInput,
    required this.secondInput,
    required this.activeIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final lines = expression
        .split('|')
        .map((String line) => line.trim())
        .where((String line) => line.isNotEmpty)
        .toList(growable: false);
    final firstExpression = lines.isNotEmpty ? lines[0] : '?';
    final secondExpression = lines.length > 1 ? lines[1] : '?';

    return Column(
      children: <Widget>[
        _DualExpressionLine(
          expression: firstExpression,
          input: firstInput,
          active: activeIndex == 0,
          onTap: () => onSelect(0),
        ),
        SizedBox(height: 24.h),
        _DualExpressionLine(
          expression: secondExpression,
          input: secondInput,
          active: activeIndex == 1,
          onTap: () => onSelect(1),
        ),
      ],
    );
  }
}

class _DualExpressionLine extends StatelessWidget {
  final String expression;
  final String input;
  final bool active;
  final VoidCallback onTap;

  const _DualExpressionLine({
    required this.expression,
    required this.input,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final parts = expression.split('?');
    final children = <Widget>[];
    if (parts.length == 2) {
      if (parts[0].isNotEmpty) {
        children.add(Text(parts[0], style: AppTextStyles.puzzle));
      }
      children.add(
        MiniInputBox(
          text: input.isEmpty ? '?' : input,
          active: active,
          onTap: onTap,
        ),
      );
      if (parts[1].isNotEmpty) {
        children.add(Text(parts[1], style: AppTextStyles.puzzle));
      }
    } else {
      children.add(Text(expression, style: AppTextStyles.puzzle));
    }

    return SizedBox(
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}

class MiniInputBox extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;

  const MiniInputBox({
    super.key,
    required this.text,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBounce(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: 62.r,
        height: 56.r,
        decoration: BoxDecoration(
          color: active ? AppColors.yellowSoft : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(11.r),
          border: Border.all(
            color: AppColors.border,
            width: AppDimensions.strongStroke,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: AppTextStyles.keypadNumber.copyWith(fontSize: 35.sp),
          ),
        ),
      ),
    );
  }
}

class MagicTriangleBoard extends StatelessWidget {
  final String target;
  final List<int?> slots;
  final int? selectedIndex;
  final ValueChanged<int> onSlotSelected;

  const MagicTriangleBoard({
    super.key,
    required this.target,
    required this.slots,
    required this.selectedIndex,
    required this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: AspectRatio(
            aspectRatio: 1.05,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;
                final slotSize = math.min(74.r, width * 0.24);
                return Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Positioned(
                      top: 0,
                      left: (width - slotSize) / 2,
                      child: TriangleSlot(
                        key: const ValueKey<String>('triangle-slot-0'),
                        value: slots[0],
                        size: slotSize,
                        selected: selectedIndex == 0,
                        onTap: () => onSlotSelected(0),
                      ),
                    ),
                    Positioned(
                      top: height * 0.31,
                      left: width * 0.20,
                      child: TriangleSlot(
                        key: const ValueKey<String>('triangle-slot-1'),
                        value: slots[1],
                        size: slotSize,
                        selected: selectedIndex == 1,
                        onTap: () => onSlotSelected(1),
                      ),
                    ),
                    Positioned(
                      top: height * 0.31,
                      right: width * 0.20,
                      child: TriangleSlot(
                        key: const ValueKey<String>('triangle-slot-2'),
                        value: slots[2],
                        size: slotSize,
                        selected: selectedIndex == 2,
                        onTap: () => onSlotSelected(2),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: width * 0.06,
                      child: TriangleSlot(
                        key: const ValueKey<String>('triangle-slot-3'),
                        value: slots[3],
                        size: slotSize,
                        selected: selectedIndex == 3,
                        onTap: () => onSlotSelected(3),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: (width - slotSize) / 2,
                      child: TriangleSlot(
                        key: const ValueKey<String>('triangle-slot-4'),
                        value: slots[4],
                        size: slotSize,
                        selected: selectedIndex == 4,
                        onTap: () => onSlotSelected(4),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: width * 0.06,
                      child: TriangleSlot(
                        key: const ValueKey<String>('triangle-slot-5'),
                        value: slots[5],
                        size: slotSize,
                        selected: selectedIndex == 5,
                        onTap: () => onSlotSelected(5),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
  }
}

class TriangleSlot extends StatelessWidget {
  final int? value;
  final double? size;
  final bool selected;
  final VoidCallback onTap;

  const TriangleSlot({
    super.key,
    required this.value,
    required this.onTap,
    this.size,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final filled = value != null;
    final boxSize = size ?? 74.r;
    final selectedBorder = Border.all(
      color: AppColors.purple,
      width: AppDimensions.regularStroke,
    );
    return AppBounce(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: boxSize,
        height: boxSize,
        decoration: BoxDecoration(
          color: filled ? null : AppColors.purpleSoft,
          gradient: filled
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    AppColors.purple.withValues(alpha: 0.46),
                    AppColors.purple.withValues(alpha: 0.78),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(22.r),
          border: selected ? selectedBorder : null,
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            child: Text(
              value?.toString() ?? '',
              key: ValueKey<int?>(value),
              style: AppTextStyles.keypadNumber.copyWith(fontSize: 34.sp),
            ),
          ),
        ),
      ),
    );
  }
}

class MagicTrianglePicker extends StatelessWidget {
  final List<int> numbers;
  final Set<int> used;
  final ValueChanged<int> onPick;

  const MagicTrianglePicker({
    super.key,
    required this.numbers,
    required this.used,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <List<int>>[
      for (int index = 0; index < numbers.length; index += 3)
        numbers.skip(index).take(3).toList(growable: false),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final availW = constraints.maxWidth;
        final availH =
            constraints.maxHeight.isFinite ? constraints.maxHeight : 300.h;
        final fromWidth = availW / 4.0;
        final fromHeight = availH / (rows.length + 1.0);
        final btnSize = math.min(fromWidth, fromHeight).clamp(48.0, 92.0);

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            for (int rowIndex = 0; rowIndex < rows.length; rowIndex++)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  for (int index = 0; index < rows[rowIndex].length; index++)
                    StaggeredEntry(
                      index: index,
                      child: Builder(
                        builder: (BuildContext context) {
                          final number = rows[rowIndex][index];
                          if (used.contains(number)) {
                            return SizedBox(
                              key: ValueKey<String>('triangle-$number-used'),
                              width: btnSize,
                              height: btnSize,
                            );
                          }
                          return KeyButton(
                            key: ValueKey<String>('triangle-$number'),
                            label: '$number',
                            color: AppColors.cardSurface,
                            rounded: false,
                            size: btnSize,
                            borderColor: AppColors.purple.withValues(alpha: 0.5),
                            borderRadius: 22.r,
                            onTap: () => onPick(number),
                          );
                        },
                      ),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}

class PictureEquationPanel extends StatelessWidget {
  final List<PictureEquationRowData> rows;
  final String input;

  const PictureEquationPanel({super.key, required this.rows, this.input = ''});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (int index = 0; index < rows.length; index++)
          StaggeredEntry(
            index: index,
            child: ShapeEquationRow(
              shapes: rows[index].shapes
                  .map(shapeTypeFromName)
                  .toList(growable: false),
              ops: rows[index].ops,
              result: rows[index].result,
              boxedResult: rows[index].boxedResult,
              input: input,
            ),
          ),
      ],
    );
  }
}

enum ShapeType { circle, triangle, square }

ShapeType shapeTypeFromName(String name) {
  switch (name) {
    case 'triangle':
      return ShapeType.triangle;
    case 'square':
      return ShapeType.square;
    case 'circle':
    default:
      return ShapeType.circle;
  }
}

class ShapeEquationRow extends StatelessWidget {
  final List<ShapeType> shapes;
  final List<String> ops;
  final String result;
  final bool boxedResult;
  final String input;

  const ShapeEquationRow({
    super.key,
    required this.shapes,
    this.ops = const <String>[],
    required this.result,
    this.boxedResult = false,
    this.input = '',
  });

  @override
  Widget build(BuildContext context) {
    final displayResult =
        boxedResult && result == '?' && input.isNotEmpty ? input : result;
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          for (int i = 0; i < shapes.length; i++) ...<Widget>[
            PuzzleShape(type: shapes[i]),
            if (i < shapes.length - 1)
              Text(
                ops.length > i ? ops[i] : '+',
                style: AppTextStyles.keypadAction.copyWith(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
          Text(
            '=',
            style: AppTextStyles.keypadAction.copyWith(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (boxedResult)
            Container(
              key: const ValueKey<String>('picture-puzzle-answer-cell'),
              width: 54.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimensions.regularStroke,
                ),
              ),
              child: Center(
                child: Text(displayResult, style: AppTextStyles.puzzle),
              ),
            )
          else
            SizedBox(
              width: 54.w,
              child: Text(
                result,
                textAlign: TextAlign.center,
                style: AppTextStyles.keypadAction.copyWith(fontSize: 28.sp),
              ),
            ),
        ],
      ),
    );
  }
}

class PuzzleShape extends StatelessWidget {
  final ShapeType type;

  const PuzzleShape({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(36.r), painter: ShapePainter(type));
  }
}

class ShapePainter extends CustomPainter {
  final ShapeType type;

  const ShapePainter(this.type);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.purple.withValues(alpha: 0.26)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2.r;
    switch (type) {
      case ShapeType.circle:
        canvas.drawCircle(
          size.center(Offset.zero),
          size.shortestSide * 0.44,
          paint,
        );
        break;
      case ShapeType.triangle:
        final path = Path()
          ..moveTo(size.width / 2, size.height * 0.08)
          ..lineTo(size.width * 0.08, size.height * 0.92)
          ..lineTo(size.width * 0.92, size.height * 0.92)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case ShapeType.square:
        final inset = size.shortestSide * 0.11;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              inset,
              inset,
              size.width - inset * 2,
              size.height - inset * 2,
            ),
            Radius.circular(2.r),
          ),
          paint,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(ShapePainter oldDelegate) => oldDelegate.type != type;
}

class CardGridDisplay extends StatelessWidget {
  final List<PuzzleCardData> cards;
  final Set<int> revealedIndexes;
  final Set<int> solvedIndexes;
  final Color color;
  final bool coveredByDefault;
  final String keyPrefix;
  final ValueChanged<int> onTap;

  const CardGridDisplay({
    super.key,
    required this.cards,
    required this.revealedIndexes,
    required this.solvedIndexes,
    required this.color,
    required this.coveredByDefault,
    required this.keyPrefix,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <List<int>>[
      for (int index = 0; index < cards.length; index += 3)
        <int>[
          for (
            int item = index;
            item < math.min(index + 3, cards.length);
            item++
          )
            item,
        ],
    ];
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final availW = constraints.maxWidth;
        final availH =
            constraints.maxHeight.isFinite ? constraints.maxHeight : 400.h;
        final fromWidth = availW / 4.0;
        final fromHeight = availH / (rows.length + 1.0);
        final cardSize = math.min(fromWidth, fromHeight).clamp(48.0, 100.0);

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            for (int rowIndex = 0; rowIndex < rows.length; rowIndex++)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  for (final index in rows[rowIndex])
                    StaggeredEntry(
                      index: index,
                      stepDelay: const Duration(milliseconds: 12),
                      child: _MemoryCard(
                        key: ValueKey<String>('$keyPrefix-card-$index'),
                        card: cards[index],
                        color: color,
                        size: cardSize,
                        selected: revealedIndexes.contains(index) && !coveredByDefault,
                        revealed:
                            solvedIndexes.contains(index) ||
                            revealedIndexes.contains(index) ||
                            !coveredByDefault,
                        solved: solvedIndexes.contains(index),
                        onTap: () => onTap(index),
                      ),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final PuzzleCardData card;
  final Color color;
  final double? size;
  final bool revealed;
  final bool solved;
  final bool selected;
  final VoidCallback onTap;

  const _MemoryCard({
    super.key,
    required this.card,
    required this.color,
    this.size,
    required this.revealed,
    required this.solved,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardSize = size ?? AppDimensions.keypadButtonSize;
    return AnimatedScale(
      scale: solved ? 0.001 : 1.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInBack,
      child: AnimatedOpacity(
        opacity: solved ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AppBounce(
          onTap: solved ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: cardSize,
            height: cardSize * 0.95,
            decoration: BoxDecoration(
              color: solved
                  ? color.withValues(alpha: 0.18)
                  : selected
                  ? color.withValues(alpha: 0.45)
                  : revealed
                  ? AppColors.cardSurface
                  : color.withValues(alpha: 0.68),
              borderRadius: BorderRadius.circular(AppDimensions.keypadRoundedRadius),
              border: Border.all(
                color: selected ? color : AppColors.border,
                width: selected ? 2.5.r : AppDimensions.regularStroke,
              ),
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: Text(
                  revealed ? card.label : '',
                  key: ValueKey<String>(revealed ? card.label : 'covered'),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.keypadNumber.copyWith(
                    color: AppColors.text,
                    fontSize: 30.sp,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NumberPyramidPanel extends StatelessWidget {
  final List<List<String>> rows;
  final Map<String, String> ops;
  final String input;

  const NumberPyramidPanel({
    super.key,
    required this.rows,
    this.ops = const <String, String>{},
    this.input = '',
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const CenterExpression(expression: 'Number Pyramid');
    }
    if (rows.length < 3 || ops.isEmpty) {
      return _buildPlainRows();
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _PyramidRow(values: rows[0], input: input),
          SizedBox(height: 8.h),
          PyramidOperator(value: _operation('op1')),
          SizedBox(height: 8.h),
          _PyramidRow(values: rows[1], input: input),
          SizedBox(height: 8.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              PyramidOperator(value: _operation('op2')),
              SizedBox(width: 56.w),
              PyramidOperator(value: _operation('op3')),
            ],
          ),
          SizedBox(height: 8.h),
          _PyramidRow(values: rows[2], input: input),
        ],
      ),
    );
  }

  Widget _buildPlainRows() {
    return Column(
      children: <Widget>[
        for (int rowIndex = 0; rowIndex < rows.length; rowIndex++)
          Padding(
            padding: EdgeInsets.only(
              bottom: rowIndex == rows.length - 1 ? 0 : 14.h,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                for (
                  int itemIndex = 0;
                  itemIndex < rows[rowIndex].length;
                  itemIndex++
                )
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: PyramidCell(
                      value: rows[rowIndex][itemIndex],
                      input: input,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  String _operation(String key) => ops[key]?.trim() ?? '';
}

class _PyramidRow extends StatelessWidget {
  final List<String> values;
  final String input;

  const _PyramidRow({required this.values, this.input = ''});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (final value in values)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: PyramidCell(value: value, input: input),
          ),
      ],
    );
  }
}

class PyramidOperator extends StatelessWidget {
  final String value;

  const PyramidOperator({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42.r,
      height: 32.r,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: AppColors.border,
          width: AppDimensions.regularStroke,
        ),
      ),
      child: Center(
        child: Text(
          value.isEmpty ? ' ' : value,
          style: AppTextStyles.keypadAction.copyWith(
            fontSize: 21.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class PyramidCell extends StatelessWidget {
  final String value;
  final String input;

  const PyramidCell({super.key, required this.value, this.input = ''});

  @override
  Widget build(BuildContext context) {
    final missing = value == '?';
    final displayValue = missing && input.isNotEmpty ? input : value;
    return Container(
      key: missing
          ? const ValueKey<String>('number-pyramid-answer-cell')
          : null,
      width: missing ? 78.r : 68.r,
      height: 58.r,
      decoration: BoxDecoration(
        color: missing ? AppColors.cardSurface : AppColors.yellowSoft,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.border,
          width: AppDimensions.regularStroke,
        ),
      ),
      child: Center(
        child: Text(
          displayValue,
          style: AppTextStyles.keypadNumber.copyWith(fontSize: 27.sp),
        ),
      ),
    );
  }
}

class MathGridPanel extends StatelessWidget {
  final List<List<String>> rows;
  final String input;

  const MathGridPanel({super.key, required this.rows, this.input = ''});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const CenterExpression(expression: 'Math Grid');
    }
    return Column(
      children: <Widget>[
        for (int rowIndex = 0; rowIndex < rows.length; rowIndex++)
          Padding(
            padding: EdgeInsets.only(
              bottom: rowIndex == rows.length - 1 ? 0 : 18.h,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (final value in rows[rowIndex])
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: GridToken(value: value, input: input),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class GridToken extends StatelessWidget {
  final String value;
  final String input;

  const GridToken({super.key, required this.value, this.input = ''});

  @override
  Widget build(BuildContext context) {
    if (value == '?') {
      return Container(
        key: const ValueKey<String>('math-grid-answer-cell'),
        width: 58.r,
        height: 48.r,
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: AppColors.border,
            width: AppDimensions.regularStroke,
          ),
        ),
        child: Center(
          child: Text(
            input.isEmpty ? value : input,
            style: AppTextStyles.puzzle,
          ),
        ),
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 31.r),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: AppTextStyles.keypadAction.copyWith(
          fontSize: 25.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
