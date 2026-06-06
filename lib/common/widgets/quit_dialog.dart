import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/theme_assets.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/games/domain/entities/game_config.dart';
import 'app_motion.dart';
import 'circle_icon_button.dart';

Future<bool?> showQuitDialog(BuildContext context, GameTheme theme) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.34),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder:
        (
          BuildContext dialogContext,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          final darkMode = AppScope.of(context).darkMode;
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 34.w),
            child: Container(
              padding: EdgeInsets.fromLTRB(28.w, 30.h, 28.w, 28.h),
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
                      key: const ValueKey<String>('quit-close'),
                      asset: themedAsset(
                        theme,
                        'ic_close.svg',
                        darkMode: darkMode,
                      ),
                      color: theme.primary,
                      onTap: () => Navigator.of(dialogContext).pop(false),
                    ),
                  ),
                  Text('Quit!!!', style: AppTextStyles.dialogTitle),
                  SizedBox(height: 18.h),
                  Text(
                    'Are you sure you want to quit the\ngame?',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.dialogBody,
                  ),
                  SizedBox(height: 34.h),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: DialogButton(
                          label: 'Yes',
                          color: theme.primary,
                          filled: false,
                          onTap: () {
                            Navigator.of(dialogContext).pop(true);
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: DialogButton(
                          label: 'No',
                          color: theme.primary,
                          filled: true,
                          onTap: () => Navigator.of(dialogContext).pop(false),
                        ),
                      ),
                    ],
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
              scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
              child: child,
            ),
          );
        },
  );
}

class DialogButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const DialogButton({
    super.key,
    required this.label,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBounce(
      onTap: onTap,
      child: Container(
        height: 66.h,
        decoration: BoxDecoration(
          color: filled ? color : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: color, width: filled ? 0 : 1.6.r),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.dialogButton.copyWith(
              color: filled ? AppColors.black : color,
            ),
          ),
        ),
      ),
    );
  }
}
