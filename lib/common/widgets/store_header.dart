import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/asset_constants.dart';
import '../../core/constants/theme_assets.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/games/data/game_catalog.dart';
import '../../features/games/domain/entities/game_config.dart';
import 'app_asset.dart';
import 'circle_icon_button.dart';

class StoreHeader extends StatelessWidget {
  final bool showBack;
  final GameTheme theme;
  final VoidCallback? onBack;
  final VoidCallback? onSettings;
  final bool padded;

  const StoreHeader({
    super.key,
    required this.showBack,
    this.theme = mathTheme,
    this.onBack,
    this.onSettings,
    this.padded = true,
  });

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final darkMode = state.darkMode;
    final header = Row(
      children: <Widget>[
        if (showBack)
          CircleIconButton(
            key: const ValueKey<String>('header-back'),
            asset: themedAsset(theme, 'back_icon.svg', darkMode: darkMode),
            color: theme.primary,
            onTap: onBack,
          )
        else
          SizedBox(
            width: AppDimensions.iconButtonSize,
            height: AppDimensions.iconButtonSize,
          ),
        const Spacer(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppAsset(AssetConstants.coin, width: 34.r, height: 34.r),
            SizedBox(width: 10.w),
            Text(state.coins.toString(), style: AppTextStyles.wideAnswer),
          ],
        ),
        const Spacer(),
        CircleIconButton(
          key: const ValueKey<String>('settings-button'),
          asset: AssetConstants.themed('images', 'setting.svg'),
          color: AppColors.black,
          onTap: onSettings,
        ),
      ],
    );
    if (!padded) {
      return header;
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.topBarHorizontalPadding,
        AppDimensions.topBarTopPadding,
        AppDimensions.topBarHorizontalPadding,
        AppDimensions.topBarBottomPadding,
      ),
      child: header,
    );
  }
}
