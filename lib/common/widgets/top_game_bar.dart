import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/theme_assets.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/games/domain/entities/game_config.dart';
import 'app_asset.dart';
import 'app_motion.dart';
import 'circle_icon_button.dart';

class TopGameBar extends StatelessWidget {
  final String title;
  final GameTheme theme;
  final bool centered;
  final bool showActions;
  final bool showHint;
  final bool showInfo;
  final bool showPause;
  final VoidCallback? onBack;
  final VoidCallback? onHint;
  final VoidCallback? onPause;

  const TopGameBar({
    super.key,
    required this.title,
    required this.theme,
    this.centered = false,
    this.showActions = false,
    this.showHint = true,
    this.showInfo = true,
    this.showPause = true,
    this.onBack,
    this.onHint,
    this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.topBarHorizontalPadding,
              AppDimensions.topBarTopPadding,
              AppDimensions.topBarHorizontalPadding,
              AppDimensions.topBarBottomPadding,
            ),
            child: centered && !showActions
                ? _buildCenteredTitleRow(context)
                : _buildStandardTitleRow(context),
          ),
          if (showActions)
            Container(
              height: AppDimensions.topBarDividerHeight,
              width: double.infinity,
              color: theme.primary,
            ),
        ],
      ),
    );
  }

  Widget _buildCenteredTitleRow(BuildContext context) {
    final darkMode = AppScope.of(context).darkMode;
    return Row(
      children: <Widget>[
        SizedBox(
          width: AppDimensions.topBarSideExtent,
          child: Align(
            alignment: Alignment.centerLeft,
            child: CircleIconButton(
              key: const ValueKey<String>('top-back'),
              asset: themedAsset(theme, 'back_icon.svg', darkMode: darkMode),
              color: theme.primary,
              onTap: onBack,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: AppTextStyles.topBarTitle,
              ),
            ),
          ),
        ),
        SizedBox(
          width: AppDimensions.topBarSideExtent,
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: AppDimensions.iconButtonSize,
              height: AppDimensions.iconButtonSize,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStandardTitleRow(BuildContext context) {
    final darkMode = AppScope.of(context).darkMode;
    return Row(
      children: <Widget>[
        CircleIconButton(
          key: const ValueKey<String>('top-back'),
          asset: themedAsset(theme, 'back_icon.svg', darkMode: darkMode),
          color: theme.primary,
          onTap: onBack,
        ),
        SizedBox(width: AppDimensions.topBarTitleGap),
        Expanded(
          child: Align(
            alignment: centered ? Alignment.center : Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                maxLines: 1,
                textAlign: centered ? TextAlign.center : TextAlign.start,
                style: AppTextStyles.topBarTitle,
              ),
            ),
          ),
        ),
        SizedBox(width: AppDimensions.topBarActionGap),
        if (showActions) ...<Widget>[
          if (showHint) ...<Widget>[
            AppBounce(
              key: const ValueKey<String>('hint-button'),
              onTap: onHint,
              child: AppAsset('assets/hint.svg', width: 33.r, height: 33.r),
            ),
            SizedBox(width: AppDimensions.topBarActionGap),
          ],
          if (showInfo) ...<Widget>[
            CircleIconButton(
              key: const ValueKey<String>('info-button'),
              asset: themedAsset(theme, 'info.svg', darkMode: darkMode),
              color: theme.primary,
              onTap: () {},
            ),
            SizedBox(width: AppDimensions.topBarActionGap),
          ],
          if (showPause)
            CircleIconButton(
              key: const ValueKey<String>('pause-button'),
              asset: themedAsset(theme, 'ic_pause.svg', darkMode: darkMode),
              color: theme.primary,
              onTap: onPause,
            ),
        ] else
          SizedBox(width: AppDimensions.iconButtonSize),
      ],
    );
  }
}
