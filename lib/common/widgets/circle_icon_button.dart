import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import 'app_asset.dart';
import 'app_motion.dart';

class CircleIconButton extends StatelessWidget {
  final IconData? icon;
  final String? asset;
  final Color color;
  final VoidCallback? onTap;

  const CircleIconButton({
    super.key,
    this.icon,
    this.asset,
    required this.color,
    this.onTap,
  }) : assert(icon != null || asset != null);

  @override
  Widget build(BuildContext context) {
    return AppBounce(
      onTap: onTap,
      hitTestBehavior: HitTestBehavior.opaque,
      child: asset == null ? _buildFramedIcon() : _buildAssetIcon(),
    );
  }

  Widget _buildAssetIcon() {
    return SizedBox(
      width: AppDimensions.iconButtonSize,
      height: AppDimensions.iconButtonSize,
      child: AppAsset(
        asset!,
        width: AppDimensions.iconButtonSize,
        height: AppDimensions.iconButtonSize,
      ),
    );
  }

  Widget _buildFramedIcon() {
    return Container(
      width: AppDimensions.iconButtonSize,
      height: AppDimensions.iconButtonSize,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppDimensions.iconButtonRadius),
        border: Border.all(
          color: AppColors.border,
          width: AppDimensions.iconButtonStroke,
        ),
      ),
      child: Center(
        child: Icon(icon, color: color, size: AppDimensions.iconButtonIconSize),
      ),
    );
  }
}
