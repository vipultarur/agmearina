import 'dart:convert';

import 'package:flutter/services.dart';

import '../../games/domain/entities/game_config.dart';
import '../domain/entities/game_question.dart';

final Map<String, Future<Map<String, dynamic>>> _levelJsonCache =
    <String, Future<Map<String, dynamic>>>{};

Future<GameQuestion> loadQuestionFor(
  GameConfig game,
  int level, {
  AssetBundle? bundle,
}) async {
  final json = await _loadGameLevelJson(game, bundle: bundle);
  final levelJson = _readLevelJsons(
    json,
  ).firstWhere(
    (Map<String, dynamic> item) => _readLevel(item) == level,
    orElse: () => throw FormatException('Level $level not found in asset'),
  );
  final questionJson = Map<String, dynamic>.from(levelJson)
    ..putIfAbsent('title', () => game.title);

  return GameQuestion.fromJson(questionJson);
}

Future<List<GameLevelGroup>> loadLevelGroupsFor(
  GameConfig game, {
  AssetBundle? bundle,
}) async {
  final json = await _loadGameLevelJson(game, bundle: bundle);
  final groupsJson = json['groups'];
  if (groupsJson is! List) {
    final levels = _readLevelJsons(
      json,
    ).map(_readLevel).toList(growable: false);
    return <GameLevelGroup>[GameLevelGroup(label: game.title, levels: levels)];
  }

  return groupsJson
      .whereType<Map>()
      .map((Map<dynamic, dynamic> groupJson) {
        final levelsJson = groupJson['levels'];
        final levels = levelsJson is List
            ? levelsJson
                  .whereType<Map>()
                  .map(_mapFromJson)
                  .map(_readLevel)
                  .toList(growable: false)
            : const <int>[];
        return GameLevelGroup(
          label: groupJson['label']?.toString() ?? game.title,
          phase: _readNullableInt(groupJson['phase']),
          levels: levels,
        );
      })
      .toList(growable: false);
}

int _readLevel(Map<String, dynamic> json) {
  final value = json['level'];
  if (value is int) {
    return value;
  }
  return int.parse(value.toString());
}

Future<Map<String, dynamic>> _loadGameLevelJson(
  GameConfig game, {
  AssetBundle? bundle,
}) async {
  final assetBundle = bundle ?? rootBundle;
  final assetPath = 'assets/levels/${game.id}.json';
  if (bundle == null || identical(assetBundle, rootBundle)) {
    return _levelJsonCache.putIfAbsent(
      assetPath,
      () => _readAndCacheGameLevelJson(assetBundle, assetPath),
    );
  }
  return _readGameLevelJson(assetBundle, assetPath);
}

Future<Map<String, dynamic>> _readAndCacheGameLevelJson(
  AssetBundle assetBundle,
  String assetPath,
) {
  return _readGameLevelJson(assetBundle, assetPath).catchError((Object error) {
    _levelJsonCache.remove(assetPath);
    throw error;
  });
}

Future<Map<String, dynamic>> _readGameLevelJson(
  AssetBundle assetBundle,
  String assetPath,
) async {
  final data = await assetBundle.load(assetPath);
  final jsonString = utf8.decode(
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
  );
  return jsonDecode(jsonString) as Map<String, dynamic>;
}

List<Map<String, dynamic>> _readLevelJsons(Map<String, dynamic> json) {
  final levelsJson = json['levels'];
  if (levelsJson is List) {
    return levelsJson
        .whereType<Map>()
        .map(_mapFromJson)
        .toList(growable: false);
  }

  final groupsJson = json['groups'];
  if (groupsJson is List) {
    final levels = <Map<String, dynamic>>[];
    for (final groupJson in groupsJson.whereType<Map>()) {
      final levelsJson = groupJson['levels'];
      if (levelsJson is! List) {
        continue;
      }
      for (final levelJson in levelsJson.whereType<Map>()) {
        final level = _mapFromJson(levelJson);
        level.putIfAbsent('groupLabel', () => groupJson['label']);
        level.putIfAbsent('phase', () => groupJson['phase']);
        levels.add(level);
      }
    }
    return levels;
  }

  throw const FormatException('Level asset must contain levels or groups.');
}

Map<String, dynamic> _mapFromJson(Map<dynamic, dynamic> json) {
  return json.map(
    (dynamic key, dynamic value) =>
        MapEntry<String, dynamic>(key.toString(), value),
  );
}

int? _readNullableInt(Object? value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value.toString());
}

class GameLevelGroup {
  final String label;
  final int? phase;
  final List<int> levels;

  const GameLevelGroup({required this.label, required this.levels, this.phase});

  int? get firstLevel => levels.isEmpty ? null : levels.first;

  int? get lastLevel => levels.isEmpty ? null : levels.last;
}
