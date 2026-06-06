import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/asset_constants.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/games/domain/entities/game_config.dart';
import 'app_asset.dart';
import 'timer_ring.dart';

class GamePanel extends StatelessWidget {
  final GameConfig game;
  final int level;
  final int score;
  final int secondsRemaining;
  final int maxSeconds;
  final Widget child;

  const GamePanel({
    super.key,
    required this.game,
    required this.level,
    required this.score,
    required this.secondsRemaining,
    required this.maxSeconds,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppDimensions.gamePanelHorizontalMargin,
          AppDimensions.gamePanelTopMargin,
          AppDimensions.gamePanelHorizontalMargin,
          0,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: <Widget>[
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: AppDimensions.gamePanelMinHeight,
              ),
              padding: EdgeInsets.fromLTRB(20.w, 70.h, 20.w, 24.h),
              decoration: BoxDecoration(
                color: game.theme.panel,
                borderRadius: BorderRadius.circular(AppDimensions.panelRadius),
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Level : $level',
                              style: AppTextStyles.gameLevel,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      MetricStack(score: score, coins: appState.coins),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  child,
                ],
              ),
            ),
            Positioned(
              top: AppDimensions.gamePanelTimerTop,
              child: TimerRing(
                color: game.theme.primary,
                remaining: secondsRemaining,
                maxSeconds: maxSeconds,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MetricStack extends StatelessWidget {
  final int score;
  final int coins;

  const MetricStack({super.key, required this.score, required this.coins});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        metric(AssetConstants.trophy, score),
        SizedBox(height: 8.h),
        metric(AssetConstants.coin, coins),
      ],
    );
  }

  Widget metric(String icon, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AppAsset(icon, width: 27.r, height: 27.r),
        SizedBox(width: 8.w),
        Text('$value', style: AppTextStyles.metric),
      ],
    );
  }
}
