import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppDimensions {
  static double get maxContentWidth => 430.w;
  static double get pageHorizontalPadding => 22.w;

  static double get iconButtonSize => 46.r;
  static double get iconButtonIconSize => 25.r;
  static double get iconButtonStroke => 2.r;
  static double get iconButtonRadius => 14.r;

  static double get topBarHorizontalPadding => 20.w;
  static double get topBarTopPadding => 14.h;
  static double get topBarBottomPadding => 14.h;
  static double get topBarTitleGap => 14.w;
  static double get topBarActionGap => 8.w;
  static double get topBarDividerHeight => 3.5.h;
  static double get topBarSideExtent => iconButtonSize + topBarTitleGap;

  static double get thinStroke => 1.4.r;
  static double get regularStroke => 2.r;
  static double get strongStroke => 2.r;

  static double get cardRadius => 24.r;
  static double get categoryCardRadius => 26.r;
  static double get levelCardRadius => 34.r;
  static double get panelRadius => 28.r;
  static double get answerSheetRadius => 36.r;
  static double get dialogRadius => 28.r;
  static double get pillRadius => 999.r;

  static double get timerOuterSize => 120.r;
  static double get timerInnerSize => 102.r;
  static double get timerPaintSize => 110.r;
  static double get timerStroke => 11.r;

  static double get gamePanelMinHeight => 260.h;
  static double get gamePanelHorizontalMargin => 20.w;
  static double get gamePanelTopMargin => 80.h;
  static double get gamePanelTimerTop => -66.h;

  static double get keypadButtonSize => 80.r;
  static double get keypadRoundedRadius => 35.r;
  static double get keypadRowGap => 20.h;
  static double get keypadColumnGap => 28.w;

  static double get answerButtonHeight => 62.h;
  static double get answerButtonRadius => 16.r;
  static double get answerButtonGap => 16.h;

  static double get levelBadgeHorizontalPadding => 16.w;
  static double get levelBadgeVerticalPadding => 5.h;

  static double get settingsCardHeight => 68.h;
  static double get settingsCardRadius => 16.r;
  static double get settingsSwitchWidth => 72.w;
  static double get settingsSwitchHeight => 42.h;
  static double get settingsSwitchThumb => 34.r;
}
