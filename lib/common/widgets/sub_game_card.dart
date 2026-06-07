import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/asset_constants.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/games/domain/entities/game_config.dart';
import 'app_asset.dart';
import 'app_motion.dart';
import 'app_motion.dart';
class SubGameCard extends StatelessWidget {
  final GameConfig game;
  final VoidCallback onTap;

  const SubGameCard({
    super.key, 
    required this.game, 
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBounce(
      key: ValueKey<String>('subgame-${game.id}'),
      onTap: onTap,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            top: 42.h,
            child: Container(
              padding: EdgeInsets.fromLTRB(12.w, 66.h, 12.w, 14.h),
              decoration: BoxDecoration(
                color: game.theme.soft,
                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              ),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Center(
                      child: Text(
                        game.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.subGameTitle,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    height: 47.h,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: game.theme.primary,
                        borderRadius: BorderRadius.circular(13.r),
                      ),
                      child: Center(
                        child: Text('Play', style: AppTextStyles.playButton),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 90.r, height: 90.r, child: AppAsset(game.icon)),
        ],
      ),
    );
  }
}
