class GameQuestion {
  final String expression;
  final String answer;
  final List<String> choices;
  final Map<String, Object?> data;

  const GameQuestion({
    required this.expression,
    required this.answer,
    this.choices = const <String>[],
    this.data = const <String, Object?>{},
  });

  factory GameQuestion.fromJson(Map<String, dynamic> json) {
    final choicesJson = json['choices'];
    final dataJson = json['data'];
    final data = <String, Object?>{};
    if (dataJson is Map) {
      data.addAll(
        dataJson.map(
          (Object? key, Object? value) =>
              MapEntry<String, Object?>(key.toString(), value),
        ),
      );
    }
    for (final key in const <String>[
      'rows',
      'numbers',
      'cards',
      'target',
      'ops',
      'groupLabel',
      'phase',
    ]) {
      if (!data.containsKey(key) && json.containsKey(key)) {
        data[key] = json[key];
      }
    }
    final hint = json['hint']?.toString().trim();
    if (hint != null && hint.isNotEmpty) {
      data['hint'] = hint;
    }

    return GameQuestion(
      expression:
          (json['expression'] ?? json['question'] ?? json['title'] ?? '')
              .toString(),
      answer: json['answer'].toString(),
      choices: choicesJson is List
          ? choicesJson.map((Object? choice) => choice.toString()).toList()
          : const <String>[],
      data: Map<String, Object?>.unmodifiable(data),
    );
  }

  List<int> get numberOptions {
    final numbers = data['numbers'];
    if (numbers is! List) {
      return const <int>[];
    }
    return numbers
        .map((Object? number) => int.tryParse(number.toString()))
        .whereType<int>()
        .toList(growable: false);
  }

  List<PictureEquationRowData> get pictureRows {
    final rows = data['rows'];
    if (rows is! List) {
      return const <PictureEquationRowData>[];
    }
    return rows
        .whereType<Map>()
        .map(PictureEquationRowData.fromJson)
        .toList(growable: false);
  }

  List<PuzzleCardData> get cards {
    final cardsJson = data['cards'];
    if (cardsJson is! List) {
      return const <PuzzleCardData>[];
    }
    return cardsJson
        .whereType<Map>()
        .map(PuzzleCardData.fromJson)
        .toList(growable: false);
  }

  String get target => data['target']?.toString() ?? expression;

  List<List<String>> get gridRows {
    final rows = data['rows'];
    if (rows is! List) {
      return const <List<String>>[];
    }
    return rows
        .whereType<List>()
        .map(
          (List<dynamic> row) =>
              row.map((Object? value) => value.toString()).toList(),
        )
        .toList(growable: false);
  }

  Map<String, String> get pyramidOps {
    final ops = data['ops'];
    if (ops is! Map) {
      return const <String, String>{};
    }
    return ops.map(
      (Object? key, Object? value) =>
          MapEntry<String, String>(key.toString(), value.toString()),
    );
  }

  String get groupLabel => data['groupLabel']?.toString() ?? '';

  int? get phase {
    final value = data['phase'];
    if (value is int) {
      return value;
    }
    return int.tryParse(value.toString());
  }
}

class PictureEquationRowData {
  final List<String> shapes;
  final List<String> ops;
  final String result;
  final bool boxedResult;

  const PictureEquationRowData({
    required this.shapes,
    this.ops = const <String>[],
    required this.result,
    this.boxedResult = false,
  });

  factory PictureEquationRowData.fromJson(Map<dynamic, dynamic> json) {
    final shapesJson = json['shapes'];
    final opsJson = json['ops'];
    return PictureEquationRowData(
      shapes: shapesJson is List
          ? shapesJson.map((Object? shape) => shape.toString()).toList()
          : const <String>[],
      ops: opsJson is List
          ? opsJson.map((Object? op) => op.toString()).toList()
          : const <String>[],
      result: json['result'].toString(),
      boxedResult: json['boxedResult'] == true,
    );
  }
}

class PuzzleCardData {
  final String id;
  final String label;
  final String answer;

  const PuzzleCardData({
    required this.id,
    required this.label,
    required this.answer,
  });

  factory PuzzleCardData.fromJson(Map<dynamic, dynamic> json) {
    return PuzzleCardData(
      id: json['id'].toString(),
      label: json['label'].toString(),
      answer: json['answer']?.toString() ?? json['label'].toString(),
    );
  }
}
