import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/theme_assets.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/gameplay/domain/entities/game_question.dart';
import '../../features/games/domain/entities/game_config.dart';
import 'circle_icon_button.dart';

Future<void> showHintDialog(
  BuildContext context, {
  required GameConfig game,
  required int level,
  required GameQuestion question,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.42),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder:
        (
          BuildContext dialogContext,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          final darkMode = AppScope.of(context).darkMode;
          return Dialog(
            key: const ValueKey<String>('hint-dialog'),
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 34.w),
            child: Container(
              padding: EdgeInsets.fromLTRB(26.w, 24.h, 26.w, 30.h),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(AppDimensions.dialogRadius),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Align(
                    alignment: Alignment.topRight,
                    child: CircleIconButton(
                      key: const ValueKey<String>('hint-close'),
                      asset: themedAsset(
                        game.theme,
                        'ic_close.svg',
                        darkMode: darkMode,
                      ),
                      color: game.theme.primary,
                      onTap: () => Navigator.of(dialogContext).pop(),
                    ),
                  ),
                  Text(
                    'Level $level Hint',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.dialogTitle,
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 18.h,
                    ),
                    decoration: BoxDecoration(
                      color: game.theme.soft,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      buildLevelHint(game: game, question: question),
                      key: const ValueKey<String>('hint-message'),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.dialogBody,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
    transitionBuilder:
        (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
              child: child,
            ),
          );
        },
  );
}

String buildLevelHint({
  required GameConfig game,
  required GameQuestion question,
}) {
  final customHint = question.data['hint']?.toString().trim();
  if (customHint != null && customHint.isNotEmpty) {
    return customHint;
  }

  switch (game.mode) {
    case PlayMode.keypad:
      if (game.id == 'mental_arithmetic') {
        return 'Remember the number shown above, then enter the same number with the keypad.';
      }
      if (game.id.contains('root')) {
        return 'Find the number that matches ${question.expression}.';
      }
      return 'Solve ${question.expression} and enter the result.';
    case PlayMode.answers:
      return 'Replace the missing part in ${question.expression} and choose the option that makes it true.';
    case PlayMode.trueFalse:
      return 'Calculate the equation carefully, then decide if it is true or false.';
    case PlayMode.dualGame:
      return 'Solve both equations. Fill the first answer, then tap the second input and fill it.';
    case PlayMode.magicTriangle:
      return 'Use each number once and place them to match the target ${question.expression}.';
    case PlayMode.picturePuzzle:
      return 'Find each shape value from the first rows, then solve the final row.';
    case PlayMode.mathPairs:
      return 'Match each expression card with the card that has the same value.';
    case PlayMode.numericMemory:
      return 'Reveal cards that equal the target number ${question.target}.';
    case PlayMode.concentration:
      return 'Flip two cards at a time and remember where matching numbers are.';
    case PlayMode.numberPyramid:
      return 'Each upper block is made by adding the two blocks directly below it.';
    case PlayMode.mathGrid:
      return 'Read the row from left to right and solve the missing result.';
  }
}
