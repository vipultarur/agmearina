import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/app_state.dart';

enum AppFeedbackEffect { tap, correct, wrong, gameOver }

class AppFeedback {
  static final AudioCache _audioCache = AudioCache(prefix: 'assets/');
  static final Map<AppFeedbackEffect, Future<AudioPool>> _poolFutures =
      <AppFeedbackEffect, Future<AudioPool>>{};
  static DateTime? _lastTapSoundAt;

  static const Duration _tapSoundGap = Duration(milliseconds: 90);
  static const Duration _tapPoolHold = Duration(milliseconds: 360);
  static const Duration _resultPoolHold = Duration(milliseconds: 1200);
  static const Duration _longPoolHold = Duration(milliseconds: 3000);

  static void play(BuildContext context, AppFeedbackEffect effect) {
    final state = AppScope.of(context);
    if (state.vibration) {
      _vibrate(effect);
    }
    if (!state.sound) {
      return;
    }
    unawaited(_playSound(effect));
  }

  static Future<void> _playSound(AppFeedbackEffect effect) async {
    if (_isThrottled(effect)) {
      return;
    }
    try {
      final pool = await _poolFor(effect);
      final stop = await pool.start();
      Timer(_poolHoldFor(effect), () {
        unawaited(stop());
      });
    } catch (_) {
      // Audio platform channels are unavailable in some test environments.
    }
  }

  static bool _isThrottled(AppFeedbackEffect effect) {
    if (effect != AppFeedbackEffect.tap) {
      return false;
    }
    final now = DateTime.now();
    final lastTapSoundAt = _lastTapSoundAt;
    if (lastTapSoundAt != null &&
        now.difference(lastTapSoundAt) < _tapSoundGap) {
      return true;
    }
    _lastTapSoundAt = now;
    return false;
  }

  static Duration _poolHoldFor(AppFeedbackEffect effect) {
    if (effect == AppFeedbackEffect.tap) return _tapPoolHold;
    if (effect == AppFeedbackEffect.wrong || effect == AppFeedbackEffect.gameOver) return _longPoolHold;
    return _resultPoolHold;
  }

  static Future<AudioPool> _poolFor(AppFeedbackEffect effect) {
    final existingPool = _poolFutures[effect];
    if (existingPool != null) {
      return existingPool;
    }

    final createdPool = AudioPool.createFromAsset(
      path: assetFor(effect),
      audioCache: _audioCache,
      minPlayers: 1,
      maxPlayers: effect == AppFeedbackEffect.tap ? 3 : 2,
      playerMode: PlayerMode.lowLatency,
    ).catchError((Object error) {
      _poolFutures.remove(effect);
      throw error;
    });
    _poolFutures[effect] = createdPool;
    return createdPool;
  }

  static void _vibrate(AppFeedbackEffect effect) {
    try {
      switch (effect) {
        case AppFeedbackEffect.tap:
          HapticFeedback.selectionClick();
          break;
        case AppFeedbackEffect.correct:
          HapticFeedback.lightImpact();
          break;
        case AppFeedbackEffect.wrong:
          HapticFeedback.heavyImpact();
          break;
        case AppFeedbackEffect.gameOver:
          HapticFeedback.heavyImpact();
          break;
      }
    } catch (_) {
      // Haptics are best-effort.
    }
  }

  static String assetFor(AppFeedbackEffect effect) {
    switch (effect) {
      case AppFeedbackEffect.tap:
        return 'sounds/tick.mp3';
      case AppFeedbackEffect.correct:
        return 'sounds/right.mp3';
      case AppFeedbackEffect.wrong:
        return 'sounds/wrong.mp3';
      case AppFeedbackEffect.gameOver:
        return 'sounds/gameover.mp3';
    }
  }
}
