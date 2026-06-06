import 'package:flutter/material.dart';

enum PlayMode {
  keypad,
  answers,
  trueFalse,
  magicTriangle,
  picturePuzzle,
  dualGame,
  mathPairs,
  numericMemory,
  concentration,
  numberPyramid,
  mathGrid,
}

class GameTheme {
  final String id;
  final String title;
  final Color primary;
  final Color soft;
  final Color panel;
  final String categoryIcon;
  final String assetFolder;
  final String darkAssetFolder;

  const GameTheme({
    required this.id,
    required this.title,
    required this.primary,
    required this.soft,
    required this.panel,
    required this.categoryIcon,
    required this.assetFolder,
    required this.darkAssetFolder,
  });
}

class GameConfig {
  final String id;
  final String title;
  final String icon;
  final GameTheme theme;
  final PlayMode mode;
  final int maxSeconds;
  final int totalLevels;

  const GameConfig({
    required this.id,
    required this.title,
    required this.icon,
    required this.theme,
    required this.mode,
    required this.maxSeconds,
    this.totalLevels = 30,
  });
}
