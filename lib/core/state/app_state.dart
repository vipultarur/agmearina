import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class AppState extends ChangeNotifier {
  final SharedPreferences _prefs;

  int coins = AppConstants.initialCoins;
  final Map<String, Set<int>> completedLevels = <String, Set<int>>{};
  final Map<String, Map<int, int>> bestStars = <String, Map<int, int>>{};
  final Map<String, Map<int, int>> bestTimes = <String, Map<int, int>>{};
  bool sound = true;
  bool vibration = true;
  bool darkMode = false;

  AppState(this._prefs) {
    _loadState();
  }

  void _loadState() {
    coins = _prefs.getInt('coins') ?? AppConstants.initialCoins;
    sound = _prefs.getBool('sound') ?? true;
    vibration = _prefs.getBool('vibration') ?? true;
    darkMode = _prefs.getBool('darkMode') ?? false;

    final String? completedStr = _prefs.getString('completedLevels');
    if (completedStr != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(completedStr);
        decoded.forEach((String key, dynamic value) {
          completedLevels[key] = (value as List).cast<int>().toSet();
        });
      } catch (_) {
        _prefs.remove('completedLevels');
      }
    }

    final String? starsStr = _prefs.getString('bestStars');
    if (starsStr != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(starsStr);
        decoded.forEach((String key, dynamic value) {
          final Map<String, dynamic> valMap = value as Map<String, dynamic>;
          bestStars[key] = valMap.map((String k, dynamic v) => MapEntry<int, int>(int.parse(k), v as int));
        });
      } catch (_) {
        _prefs.remove('bestStars');
      }
    }

    final String? timesStr = _prefs.getString('bestTimes');
    if (timesStr != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(timesStr);
        decoded.forEach((String key, dynamic value) {
          final Map<String, dynamic> valMap = value as Map<String, dynamic>;
          bestTimes[key] = valMap.map((String k, dynamic v) => MapEntry<int, int>(int.parse(k), v as int));
        });
      } catch (_) {
        _prefs.remove('bestTimes');
      }
    }

  }


  Future<void> _saveCoins() async {
    await _prefs.setInt('coins', coins);
  }

  Future<void> _saveSettings() async {
    await _prefs.setBool('sound', sound);
    await _prefs.setBool('vibration', vibration);
    await _prefs.setBool('darkMode', darkMode);
  }

  Future<void> _saveCompletedLevels() async {
    final Map<String, List<int>> encodable = {};
    completedLevels.forEach((String key, Set<int> value) {
      encodable[key] = value.toList();
    });
    await _prefs.setString('completedLevels', jsonEncode(encodable));
  }

  Future<void> _saveBestStars() async {
    final Map<String, Map<String, int>> encodable = {};
    bestStars.forEach((String key, Map<int, int> value) {
      encodable[key] = value.map((int k, int v) => MapEntry<String, int>(k.toString(), v));
    });
    await _prefs.setString('bestStars', jsonEncode(encodable));
  }

  Future<void> _saveBestTimes() async {
    final Map<String, Map<String, int>> encodable = {};
    bestTimes.forEach((String key, Map<int, int> value) {
      encodable[key] = value.map((int k, int v) => MapEntry<String, int>(k.toString(), v));
    });
    await _prefs.setString('bestTimes', jsonEncode(encodable));
  }


  bool isLevelCompleted(String gameId, int level) {
    return completedLevels[gameId]?.contains(level) ?? false;
  }

  bool isLevelUnlocked(String gameId, int level) {
    if (level <= 1) {
      return true;
    }
    return isLevelCompleted(gameId, level - 1);
  }

  int starsFor(String gameId, int level) => bestStars[gameId]?[level] ?? 0;

  int? bestTimeFor(String gameId, int level) => bestTimes[gameId]?[level];

  bool completeLevel(
    String gameId,
    int level, {
    required int stars,
    required int completedSeconds,
  }) {
    bool stateChanged = false;

    final levels = completedLevels.putIfAbsent(gameId, () => <int>{});
    final firstCompletion = levels.add(level);
    if (firstCompletion) {
      _saveCompletedLevels();
      stateChanged = true;
    }

    final starsByLevel = bestStars.putIfAbsent(gameId, () => <int, int>{});
    final currentStars = starsByLevel[level] ?? 0;
    if (stars > currentStars) {
      starsByLevel[level] = stars;
      _saveBestStars();
      stateChanged = true;
    }

    final timesByLevel = bestTimes.putIfAbsent(gameId, () => <int, int>{});
    final currentTime = timesByLevel[level];
    if (currentTime == null || completedSeconds < currentTime) {
      timesByLevel[level] = completedSeconds;
      _saveBestTimes();
      stateChanged = true;
    }

    if (firstCompletion) {
      coins += 1;
      _saveCoins();
      stateChanged = true;
    }
    
    if (stateChanged) {
      notifyListeners();
    }
    
    return firstCompletion;
  }

  bool spendCoins(int amount) {
    if (coins < amount) {
      return false;
    }
    coins -= amount;
    _saveCoins();
    notifyListeners();
    return true;
  }

  void toggleSound() {
    sound = !sound;
    _saveSettings();
    notifyListeners();
  }

  void toggleVibration() {
    vibration = !vibration;
    _saveSettings();
    notifyListeners();
  }

  void toggleDarkMode() {
    darkMode = !darkMode;
    _saveSettings();
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState appState, required super.child})
    : super(notifier: appState);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!.notifier!;
  }
}
