import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/asset_constants.dart';
import '../../core/constants/theme_assets.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/games/domain/entities/game_config.dart';
import 'app_asset.dart';
import 'app_motion.dart';
import 'circle_icon_button.dart';

Future<void> showGameResultDialog(
  BuildContext context, {
  required GameConfig game,
  required int level,
  required bool won,
  required int stars,
  required int score,
  required int completedSeconds,
  required VoidCallback onRestart,
  required VoidCallback onHome,
  VoidCallback? onClose,
  required VoidCallback? onNext,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.58),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder:
        (
          BuildContext dialogContext,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return _GameResultDialog(
            game: game,
            level: level,
            won: won,
            stars: stars,
            score: score,
            completedSeconds: completedSeconds,
            onRestart: () {
              Navigator.of(dialogContext).pop();
              onRestart();
            },
            onHome: () {
              Navigator.of(dialogContext).pop();
              onHome();
            },
            onClose: () {
              Navigator.of(dialogContext).pop();
              onClose?.call();
            },
            onNext: onNext == null
                ? null
                : () {
                    Navigator.of(dialogContext).pop();
                    onNext();
                  },
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

class _GameResultDialog extends StatelessWidget {
  final GameConfig game;
  final int level;
  final bool won;
  final int stars;
  final int score;
  final int completedSeconds;
  final VoidCallback onRestart;
  final VoidCallback onHome;
  final VoidCallback onClose;
  final VoidCallback? onNext;

  const _GameResultDialog({
    required this.game,
    required this.level,
    required this.won,
    required this.stars,
    required this.score,
    required this.completedSeconds,
    required this.onRestart,
    required this.onHome,
    required this.onClose,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final darkMode = state.darkMode;
    final badgeSize = 128.r;
    final panelTopMargin = badgeSize * 0.48;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: <Widget>[
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: panelTopMargin),
            padding: EdgeInsets.fromLTRB(28.w, 122.h, 28.w, 32.h),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(34.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      won ? 'You Win!!!' : 'Game Over!!!',
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.dialogTitle.copyWith(
                        fontSize: 42.sp,
                        height: 1.05,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 36.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '$score',
                      style: AppTextStyles.keypadNumber.copyWith(
                        fontSize: 64.sp,
                        height: 0.95,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    AppAsset(AssetConstants.trophy, width: 45.r, height: 45.r),
                  ],
                ),
                Text(
                  'Your Score',
                  style: AppTextStyles.dialogBody.copyWith(
                    color: AppColors.mutedText.withValues(alpha: 0.56),
                  ),
                ),
                if (won) ...<Widget>[
                  SizedBox(height: 14.h),
                  Text(
                    'Completed ${formatGameTime(completedSeconds)}',
                    style: AppTextStyles.dialogBody.copyWith(fontSize: 20.sp),
                  ),
                ],
                SizedBox(height: 38.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    for (int index = 0; index < 3; index++)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 13.w),
                        child: AppAsset(
                          index < stars
                              ? AssetConstants.starFill
                              : AssetConstants.star,
                          width: 57.r,
                          height: 57.r,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 42.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    ResultActionButton(
                      key: ValueKey<String>(
                        won ? 'result-home' : 'result-restart',
                      ),
                      asset: won
                          ? themedAsset(
                              game.theme,
                              'Home.svg',
                              darkMode: darkMode,
                            )
                          : themedAsset(
                              game.theme,
                              'restart.svg',
                              darkMode: darkMode,
                            ),
                      color: game.theme.soft,
                      onTap: won ? onHome : onRestart,
                    ),
                    SizedBox(width: 28.w),
                    ResultActionButton(
                      key: const ValueKey<String>('result-share'),
                      asset: AssetConstants.share,
                      color: game.theme.soft,
                      onTap: () => _shareResult(game, level, stars),
                    ),
                    SizedBox(width: 28.w),
                    ResultActionButton(
                      key: ValueKey<String>(
                        won ? 'result-next' : 'result-home',
                      ),
                      asset: won
                          ? themedAsset(
                              game.theme,
                              'next_icon.svg',
                              darkMode: darkMode,
                            )
                          : themedAsset(
                              game.theme,
                              'Home.svg',
                              darkMode: darkMode,
                            ),
                      color: game.theme.soft,
                      onTap: won ? onNext : onHome,
                      disabled: won && onNext == null,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: panelTopMargin + 18.r,
            right: 22.w,
            child: CircleIconButton(
              key: const ValueKey<String>('result-close'),
              asset: themedAsset(game.theme, 'ic_close.svg', darkMode: darkMode),
              color: game.theme.primary,
              onTap: onClose,
            ),
          ),
          _LevelBadge(game: game, level: level, size: badgeSize),
        ],
      ),
    );
  }

  void _shareResult(GameConfig game, int level, int stars) {
    unawaited(_shareResultAsync(game, level, stars));
  }

  Future<void> _shareResultAsync(GameConfig game, int level, int stars) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text:
              'I scored $stars stars on ${game.title} level $level in Math Spazzel!',
        ),
      );
    } catch (_) {
      // Sharing is unavailable on some test or desktop targets.
    }
  }
}

class _LevelBadge extends StatelessWidget {
  final GameConfig game;
  final int level;
  final double size;

  const _LevelBadge({
    required this.game,
    required this.level,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (game.totalLevels == 0 ? 0.0 : level / game.totalLevels)
        .clamp(0.0, 1.0)
        .toDouble();
        
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox(
            width: size,
            height: size,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: progress),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: 16.r,
                  backgroundColor: AppColors.timerTrack,
                  color: game.theme.primary,
                  strokeCap: StrokeCap.round,
                );
              },
            ),
          ),
          Text(
            '$level/${game.totalLevels}\nLevel',
            textAlign: TextAlign.center,
            style: AppTextStyles.metric.copyWith(fontSize: 18.sp, height: 1.18),
          ),
        ],
      ),
    );
  }
}

class ResultActionButton extends StatelessWidget {
  final String asset;
  final Color color;
  final VoidCallback? onTap;
  final bool disabled;

  const ResultActionButton({
    super.key,
    required this.asset,
    required this.color,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBounce(
      onTap: disabled ? null : onTap,
      child: Opacity(
        opacity: disabled ? 0.35 : 1,
        child: Container(
          width: 76.r,
          height: 76.r,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(
            child: AppAsset(asset, width: 42.r, height: 42.r),
          ),
        ),
      ),
    );
  }
}

String formatGameTime(int seconds) {
  final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
  final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
  return '$minutes:$remainingSeconds';
}
