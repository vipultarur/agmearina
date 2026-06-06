import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/asset_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_asset.dart';
import 'app_motion.dart';

class LevelCard extends StatelessWidget {
  final String gameId;
  final int level;
  final Color color;
  final int stars;
  final bool completed;
  final bool locked;
  final VoidCallback? onTap;

  const LevelCard({
    super.key,
    required this.gameId,
    required this.level,
    required this.color,
    required this.stars,
    required this.completed,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBounce(
      onTap: locked ? null : onTap,
      child: Opacity(
        opacity: locked ? 0.52 : 1,
        child: Container(
          decoration: BoxDecoration(
            color: completed
                ? color.withValues(alpha: 0.40)
                : AppColors.cardSurface,
            borderRadius: BorderRadius.circular(AppDimensions.levelCardRadius),
            border: Border.all(
              color: completed ? color : AppColors.border,
              width: AppDimensions.regularStroke,
            ),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (locked)
                    Icon(
                      Icons.lock_rounded,
                      key: ValueKey<String>('level-lock-$gameId-$level'),
                      color: AppColors.black,
                      size: 26.r,
                    )
                  else
                    Text(
                      '$level',
                      style: AppTextStyles.levelNumber.copyWith(
                        color: completed ? AppColors.black : AppColors.text,
                      ),
                    ),
                  SizedBox(height: 8.h),
                  _LevelStars(
                    gameId: gameId,
                    level: level,
                    stars: completed ? stars : 0,
                  ),
                  SizedBox(height: 7.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.levelBadgeHorizontalPadding,
                      vertical: AppDimensions.levelBadgeVerticalPadding,
                    ),
                    decoration: BoxDecoration(
                      color: locked
                          ? AppColors.divider
                          : color.withValues(alpha: completed ? 0.85 : 0.62),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.pillRadius,
                      ),
                    ),
                    child: Text(
                      locked
                          ? 'Locked'
                          : completed
                          ? 'Done'
                          : 'Level',
                      style: AppTextStyles.levelLabel,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelStars extends StatelessWidget {
  final String gameId;
  final int level;
  final int stars;

  const _LevelStars({
    required this.gameId,
    required this.level,
    required this.stars,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int index = 0; index < 3; index++)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: AppAsset(
              index < stars ? AssetConstants.starFill : AssetConstants.star,
              key: ValueKey<String>(
                'level-star-$gameId-$level-$index-${index < stars ? 'filled' : 'empty'}',
              ),
              width: 16.r,
              height: 16.r,
            ),
          ),
      ],
    );
  }
}
