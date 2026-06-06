import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/games/domain/entities/game_config.dart';
import 'app_asset.dart';
import 'app_motion.dart';
import 'decorative_shapes.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final GameTheme theme;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBounce(
      key: ValueKey<String>('category-${theme.id}'),
      onTap: onTap,
      child: SizedBox(
        height: 174.h,
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 4.w,
              top: 0,
              right: 0,
              bottom: 0,
              child: Transform.rotate(
                angle: 0.027,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.categoryCardRadius,
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              top: 8.h,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  AppDimensions.categoryCardRadius,
                ),
                child: Container(
                  color: theme.primary,
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        left: 42.w,
                        top: 38.h,
                        child: Container(
                          width: 86.r,
                          height: 86.r,
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: AppAsset(theme.categoryIcon),
                        ),
                      ),
                      Positioned(
                        left: 142.w,
                        top: 62.h,
                        right: 20.w,
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.categoryTitle,
                        ),
                      ),
                      Positioned(
                        right: -24.w,
                        bottom: -28.h,
                        child: DottedArc(color: theme.primary),
                      ),
                      Positioned(
                        left: 150.w,
                        top: 40.h,
                        child: const ConfettiDash(),
                      ),
                      Positioned(
                        left: 238.w,
                        top: 100.h,
                        child: const ConfettiDash(light: true),
                      ),
                      Positioned(
                        left: 170.w,
                        top: 122.h,
                        child: const ConfettiDash(light: true),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
