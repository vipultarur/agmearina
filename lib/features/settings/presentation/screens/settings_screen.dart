import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../common/widgets/app_motion.dart';
import '../../../../common/widgets/capped_scaffold.dart';
import '../../../../common/widgets/circle_icon_button.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return CappedScaffold(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(22.w, 18.h, 22.w, 32.h),
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleIconButton(
                  key: const ValueKey<String>('settings-back'),
                  asset: AssetConstants.themed('imgYellow', 'back_icon.svg'),
                  color: AppColors.yellow,
                  onTap: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Text(
                    'Settings',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.settingsTitle,
                  ),
                ),
                SizedBox(width: AppDimensions.iconButtonSize),
              ],
            ),
            SizedBox(height: 58.h),
            const StaggeredEntry(index: 0, child: SectionTitle('Sound')),
            SizedBox(height: 24.h),
            StaggeredEntry(
              index: 1,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: SettingToggleCard(
                      key: const ValueKey<String>('sound-toggle'),
                      label: 'Sound',
                      value: state.sound,
                      onTap: state.toggleSound,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: SettingToggleCard(
                      key: const ValueKey<String>('vibration-toggle'),
                      label: 'Vibration',
                      value: state.vibration,
                      onTap: state.toggleVibration,
                    ),
                  ),
                ],
              ),
            ),
            const SettingsDivider(),
            const StaggeredEntry(index: 2, child: SectionTitle('Theme')),
            SizedBox(height: 24.h),
            StaggeredEntry(
              index: 3,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 198.w,
                  child: SettingToggleCard(
                    key: const ValueKey<String>('dark-toggle'),
                    label: 'Dark Mode',
                    value: state.darkMode,
                    onTap: state.toggleDarkMode,
                  ),
                ),
              ),
            ),
            const SettingsDivider(),
            const StaggeredEntry(index: 4, child: SettingsRow(label: 'Share')),
            const SettingsDivider(),
            const StaggeredEntry(
              index: 5,
              child: SettingsRow(label: 'Rate Us'),
            ),
            const SettingsDivider(),
            const StaggeredEntry(
              index: 6,
              child: SettingsRow(label: 'Feedback'),
            ),
            const SettingsDivider(),
            const StaggeredEntry(
              index: 7,
              child: SettingsRow(label: 'Privacy Policy'),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;

  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.settingsSection);
  }
}

class SettingToggleCard extends StatelessWidget {
  final String label;
  final bool value;
  final VoidCallback onTap;

  const SettingToggleCard({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBounce(
      onTap: onTap,
      child: Container(
        height: AppDimensions.settingsCardHeight,
        padding: EdgeInsets.only(left: 16.w, right: 14.w),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(AppDimensions.settingsCardRadius),
          border: Border.all(
            color: AppColors.switchOutline,
            width: AppDimensions.thinStroke,
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.settingsLabel,
              ),
            ),
            MockSwitch(value: value),
          ],
        ),
      ),
    );
  }
}

class MockSwitch extends StatelessWidget {
  final bool value;

  const MockSwitch({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.settingsSwitchWidth,
      height: AppDimensions.settingsSwitchHeight,
      decoration: BoxDecoration(
        color: value ? AppColors.yellow : AppColors.switchOffTrack,
        borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
      ),
      child: AnimatedAlign(
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        duration: const Duration(milliseconds: 160),
        child: Container(
          width: AppDimensions.settingsSwitchThumb,
          height: AppDimensions.settingsSwitchThumb,
          margin: EdgeInsets.symmetric(horizontal: 5.w),
          decoration: const BoxDecoration(
            color: AppColors.cardSurface,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class SettingsRow extends StatelessWidget {
  final String label;

  const SettingsRow({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70.h,
      child: AppBounce(
        onTap: () {},
        child: Row(
          children: <Widget>[
            Text(label, style: AppTextStyles.settingsRow),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.black,
              size: 40.r,
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 28.h),
      height: 1.h,
      color: AppColors.divider,
    );
  }
}
