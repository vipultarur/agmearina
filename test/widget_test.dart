import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathspazzel/app.dart';
import 'package:mathspazzel/common/widgets/answer_controls.dart';
import 'package:mathspazzel/common/widgets/capped_scaffold.dart';
import 'package:mathspazzel/common/widgets/game_panel.dart';
import 'package:mathspazzel/common/widgets/top_game_bar.dart';
import 'package:mathspazzel/core/constants/app_constants.dart';
import 'package:mathspazzel/core/services/app_feedback.dart';
import 'package:mathspazzel/core/state/app_state.dart';
import 'package:mathspazzel/core/theme/app_dimensions.dart';
import 'package:mathspazzel/features/gameplay/data/question_bank.dart';
import 'package:mathspazzel/features/gameplay/domain/entities/game_question.dart';
import 'package:mathspazzel/features/gameplay/presentation/screens/game_play_screen.dart';
import 'package:mathspazzel/features/gameplay/presentation/widgets/puzzle_displays.dart';
import 'package:mathspazzel/features/games/data/game_catalog.dart';
import 'package:mathspazzel/features/games/domain/entities/game_config.dart';
import 'package:mathspazzel/features/home/presentation/screens/home_screen.dart';
import 'package:mathspazzel/features/levels/presentation/screens/level_select_screen.dart';
import 'package:mathspazzel/features/math_puzzle/presentation/screens/math_puzzle_screen.dart';
import 'package:mathspazzel/features/memory_puzzle/presentation/screens/memory_puzzle_screen.dart';
import 'package:mathspazzel/features/settings/presentation/screens/settings_screen.dart';
import 'package:mathspazzel/features/train_brain/presentation/screens/train_brain_screen.dart';

double evaluateMathExpression(String source) {
  final expression = source.replaceAll('=', '').trim();
  final squareRoot = RegExp(r'^sqrt\((-?\d+(?:\.\d+)?)\)$').firstMatch(
    expression,
  );
  if (squareRoot != null) {
    return math.sqrt(double.parse(squareRoot.group(1)!));
  }
  final cubeRoot = RegExp(r'^cuberoot\((-?\d+(?:\.\d+)?)\)$').firstMatch(
    expression,
  );
  if (cubeRoot != null) {
    final value = double.parse(cubeRoot.group(1)!);
    final root = math.pow(value.abs(), 1 / 3).toDouble();
    return value < 0 ? -root : root;
  }
  return _ExpressionParser(expression).parse();
}

bool equationHolds(String expression) {
  final parts = expression.split('=');
  if (parts.length != 2) {
    throw FormatException('Expected equation: $expression');
  }
  return (evaluateMathExpression(parts[0]) - evaluateMathExpression(parts[1]))
          .abs() <
      0.0001;
}

double applyPyramidOperation(double left, double right, String op) {
  switch (op) {
    case '+':
      return left + right;
    case '-':
      return left - right;
    case '*':
      return left * right;
    case '/':
      return left / right;
  }
  throw FormatException('Unsupported pyramid op: $op');
}

void expectQuestionLogic(GameConfig game, GameQuestion question) {
  expect(question.expression, isNotEmpty);
  expect(question.answer, isNotEmpty);
  expect(question.data['hint']?.toString().trim(), isNotEmpty);

  switch (game.mode) {
    case PlayMode.keypad:
      if (game.id == mentalArithmeticGame.id) {
        expect(question.expression, question.answer);
      } else {
        expect(
          evaluateMathExpression(question.expression),
          closeTo(double.parse(question.answer), 0.0001),
        );
      }
      break;
    case PlayMode.answers:
      expect(question.choices, contains(question.answer));
      expect(
        equationHolds(question.expression.replaceFirst('?', question.answer)),
        isTrue,
      );
      break;
    case PlayMode.trueFalse:
      expect(
        equationHolds(question.expression),
        question.answer == 'True',
      );
      break;
    case PlayMode.dualGame:
      final expressions = question.expression
          .split('|')
          .map((String item) => item.trim())
          .where((String item) => item.isNotEmpty)
          .toList(growable: false);
      final answers = question.answer.split(',');
      expect(expressions, hasLength(answers.length));
      for (int index = 0; index < expressions.length; index++) {
        expect(
          equationHolds(expressions[index].replaceFirst('?', answers[index])),
          isTrue,
        );
      }
      break;
    case PlayMode.magicTriangle:
      expect(question.numberOptions, hasLength(6));
      expect(question.numberOptions.toSet(), hasLength(6));
      expect(int.tryParse(question.expression), isNotNull);
      break;
    case PlayMode.picturePuzzle:
      expect(question.pictureRows, isNotEmpty);
      expect(
        question.pictureRows.where(
          (PictureEquationRowData row) => row.boxedResult,
        ),
        hasLength(1),
      );
      break;
    case PlayMode.mathPairs:
    case PlayMode.concentration:
      expect(question.cards, isNotEmpty);
      final ids = <String, int>{};
      for (final card in question.cards) {
        ids.update(card.id, (int count) => count + 1, ifAbsent: () => 1);
      }
      expect(ids.values, everyElement(2));
      break;
    case PlayMode.numericMemory:
      expect(question.cards, isNotEmpty);
      expect(
        question.cards.where(
          (PuzzleCardData card) => card.answer == question.target,
        ),
        isNotEmpty,
      );
      break;
    case PlayMode.numberPyramid:
      final rows = question.gridRows;
      final ops = question.pyramidOps;
      expect(rows, hasLength(3));
      expect(ops.keys, containsAll(<String>['op1', 'op2', 'op3']));
      final answer = double.parse(question.answer);
      final midLeft = double.parse(rows[1][0]);
      final midRight = double.parse(rows[1][1]);
      final bottomLeft = double.parse(rows[2][0]);
      final bottomMiddle = double.parse(rows[2][1]);
      final bottomRight = double.parse(rows[2][2]);
      expect(
        applyPyramidOperation(midLeft, midRight, ops['op1']!),
        closeTo(answer, 0.0001),
      );
      expect(
        applyPyramidOperation(bottomLeft, bottomMiddle, ops['op2']!),
        closeTo(midLeft, 0.0001),
      );
      expect(
        applyPyramidOperation(bottomMiddle, bottomRight, ops['op3']!),
        closeTo(midRight, 0.0001),
      );
      break;
    case PlayMode.mathGrid:
      expect(question.gridRows, isNotEmpty);
      expect(
        equationHolds(
          question.gridRows.first.join(' ').replaceFirst('?', question.answer),
        ),
        isTrue,
      );
      break;
  }
}

class GatedAssetBundle extends CachingAssetBundle {
  final AssetBundle parent;
  final String gatedAssetPath;
  final Completer<void> gate = Completer<void>();

  GatedAssetBundle({required this.parent, required this.gatedAssetPath});

  @override
  Future<ByteData> load(String key) async {
    if (key == gatedAssetPath) {
      await gate.future;
    }
    return parent.load(key);
  }

  void release() {
    if (!gate.isCompleted) {
      gate.complete();
    }
  }
}

class _ExpressionParser {
  final String source;
  int index = 0;

  _ExpressionParser(this.source);

  double parse() {
    final value = _parseExpression();
    _skipSpaces();
    if (index != source.length) {
      throw FormatException('Unexpected token in $source at $index');
    }
    return value;
  }

  double _parseExpression() {
    var value = _parseTerm();
    while (true) {
      _skipSpaces();
      if (_consume('+')) {
        value += _parseTerm();
      } else if (_consume('-')) {
        value -= _parseTerm();
      } else {
        return value;
      }
    }
  }

  double _parseTerm() {
    var value = _parseFactor();
    while (true) {
      _skipSpaces();
      if (_consume('*')) {
        value *= _parseFactor();
      } else if (_consume('/')) {
        value /= _parseFactor();
      } else {
        return value;
      }
    }
  }

  double _parseFactor() {
    _skipSpaces();
    if (_consume('+')) {
      return _parseFactor();
    }
    if (_consume('-')) {
      return -_parseFactor();
    }
    if (_consume('(')) {
      final value = _parseExpression();
      if (!_consume(')')) {
        throw FormatException('Missing closing parenthesis in $source');
      }
      return value;
    }
    return _parseNumber();
  }

  double _parseNumber() {
    _skipSpaces();
    final start = index;
    while (index < source.length) {
      final char = source[index];
      if (!RegExp(r'[0-9.]').hasMatch(char)) {
        break;
      }
      index++;
    }
    if (start == index) {
      throw FormatException('Expected number in $source at $index');
    }
    return double.parse(source.substring(start, index));
  }

  bool _consume(String token) {
    _skipSpaces();
    if (!source.startsWith(token, index)) {
      return false;
    }
    index += token.length;
    return true;
  }

  void _skipSpaces() {
    while (index < source.length && source[index].trim().isEmpty) {
      index++;
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  void setTallPhoneSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(430, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  void setPhoneSurface(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  void expectNoFlutterException(WidgetTester tester) {
    final Object? exception = tester.takeException();
    if (exception is FlutterError) {
      debugPrint(exception.toStringDeep());
      for (final DiagnosticsNode diagnostic in exception.diagnostics) {
        debugPrint(diagnostic.toStringDeep());
      }
    }
    expect(exception, isNull);
  }

  Future<void> pumpLoadedGame(WidgetTester tester) async {
    for (int attempt = 0; attempt < 30; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('Level data unavailable').evaluate().isNotEmpty) {
        fail('Game level JSON failed to load.');
      }
      if (find.text('Loading...').evaluate().isEmpty) {
        await tester.pump();
        return;
      }
    }
    fail('Game level JSON did not finish loading.');
  }

  Future<void> tapDigits(WidgetTester tester, String value) async {
    for (final digit in value.split('')) {
      await tester.tap(find.byKey(ValueKey<String>('key-$digit')));
      await tester.pump();
    }
  }

  Future<void> dismissResultDialog(WidgetTester tester) async {
    final closeFinder = find.byKey(const ValueKey<String>('result-close'));
    if (closeFinder.evaluate().isEmpty) {
      return;
    }
    await tester.tap(closeFinder);
    await tester.pumpAndSettle();
  }

  Widget scopedTestApp({required AppState state, required Widget home}) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,
      child: home,
      builder: (BuildContext context, Widget? child) {
        return AppScope(
          appState: state,
          child: MaterialApp(key: UniqueKey(), home: child),
        );
      },
    );
  }

  testWidgets('home renders category cards', (WidgetTester tester) async {
    setTallPhoneSurface(tester);
    await tester.pumpWidget(const MathspazzelApp());

    expect(find.text('Math Games'), findsOneWidget);
    expect(find.text('Math Puzzle'), findsOneWidget);
    expect(find.text('Memory Puzzle'), findsOneWidget);
    expect(find.text('Train Your Brain'), findsOneWidget);
  });

  testWidgets('home and game type headers stay outside scrollable content', (
    WidgetTester tester,
  ) async {
    setPhoneSurface(tester, const Size(360, 640));

    final screens = <Widget>[
      const HomeScreen(),
      const MathPuzzleScreen(),
      const MemoryPuzzleScreen(),
      const TrainBrainScreen(),
    ];

    for (final screen in screens) {
      final state = AppState();
      await tester.pumpWidget(scopedTestApp(state: state, home: screen));
      await tester.pumpAndSettle();

      final settingsButton = find.byKey(
        const ValueKey<String>('settings-button'),
      );
      expect(settingsButton, findsOneWidget);
      expect(
        find.ancestor(of: settingsButton, matching: find.byType(Scrollable)),
        findsNothing,
      );

      if (screen is! HomeScreen) {
        final backButton = find.byKey(const ValueKey<String>('header-back'));
        expect(backButton, findsOneWidget);
        expect(
          find.ancestor(of: backButton, matching: find.byType(Scrollable)),
          findsNothing,
        );
      }
    }
  });

  testWidgets('math puzzle grid renders all math games', (
    WidgetTester tester,
  ) async {
    setTallPhoneSurface(tester);
    await tester.pumpWidget(const MathspazzelApp());

    await tester.tap(find.byKey(const ValueKey<String>('category-math')));
    await tester.pumpAndSettle();

    for (final game in mathGames) {
      expect(
        find.byKey(ValueKey<String>('subgame-${game.id}')),
        findsOneWidget,
      );
    }
    expect(find.text('Square Root'), findsOneWidget);
    expect(find.text('Math Grid'), findsOneWidget);
    expect(find.text('Number Pyramid'), findsOneWidget);
  });

  testWidgets('default game level selectors have thirty levels', (
    WidgetTester tester,
  ) async {
    setTallPhoneSurface(tester);
    for (final game in allGames.where(
      (GameConfig game) => game.mode != PlayMode.numberPyramid,
    )) {
      final state = AppState();
      await tester.pumpWidget(
        scopedTestApp(
          state: state,
          home: LevelSelectScreen(game: game),
        ),
      );
      await tester.pumpAndSettle();

      for (int level = 1; level <= 30; level++) {
        expect(
          find.byKey(ValueKey<String>('level-card-${game.id}-$level')),
          findsOneWidget,
        );
      }
      expect(
        find.byWidgetPredicate((Widget widget) {
          return widget.key is ValueKey<String> &&
              (widget.key! as ValueKey<String>).value.startsWith(
                'level-card-${game.id}-',
              );
        }),
        findsNWidgets(game.totalLevels),
      );
    }
  });

  testWidgets('number pyramid level selector uses grouped json levels', (
    WidgetTester tester,
  ) async {
    setTallPhoneSurface(tester);
    final state = AppState();

    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const LevelSelectScreen(game: numberPyramidGame),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Phase 1'), findsOneWidget);
    expect(find.text('All {+},{-},{*},{/}'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('level-card-number_pyramid-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('level-card-number_pyramid-5')),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('level-card-number_pyramid-165')),
      900,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.byKey(const ValueKey<String>('level-card-number_pyramid-165')),
      findsOneWidget,
    );
  });

  testWidgets('level selector highlights completed levels and unlocks next', (
    WidgetTester tester,
  ) async {
    setTallPhoneSurface(tester);
    final state = AppState();

    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const LevelSelectScreen(game: calculatorGame),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('level-lock-calculator-1')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('level-lock-calculator-2')),
      findsOneWidget,
    );

    state.completeLevel(calculatorGame.id, 1, stars: 2, completedSeconds: 4);
    await tester.pumpAndSettle();

    expect(find.text('Done'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('level-star-calculator-1-0-filled')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('level-star-calculator-1-1-filled')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('level-star-calculator-1-2-empty')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('level-lock-calculator-2')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('level-lock-calculator-3')),
      findsOneWidget,
    );
  });

  testWidgets('key shared interactive widgets use Bounceable', (
    WidgetTester tester,
  ) async {
    setTallPhoneSurface(tester);
    await tester.pumpWidget(const MathspazzelApp());
    await tester.pumpAndSettle();

    expect(find.byType(Bounceable), findsAtLeastNWidgets(4));

    await tester.tap(find.byKey(const ValueKey<String>('category-math')));
    await tester.pumpAndSettle();

    expect(find.byType(Bounceable), findsAtLeastNWidgets(10));
  });

  testWidgets('timer waits for level data before counting down', (
    WidgetTester tester,
  ) async {
    setTallPhoneSurface(tester);
    final bundle = GatedAssetBundle(
      parent: rootBundle,
      gatedAssetPath: 'assets/levels/calculator.json',
    );
    final state = AppState();

    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: DefaultAssetBundle(
          bundle: bundle,
          child: const GamePlayScreen(game: calculatorGame, level: 1),
        ),
      ),
    );

    expect(find.text('Loading...'), findsOneWidget);
    expect(find.text('00:10'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Loading...'), findsOneWidget);
    expect(find.text('00:10'), findsOneWidget);
    expect(find.text('Game Over!!!'), findsNothing);

    bundle.release();
    await tester.pump();
    await tester.pump();

    expect(find.text('Loading...'), findsNothing);
    expect(find.text('00:10'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('00:09'), findsOneWidget);
  });

  testWidgets('timer pauses during hint and quit dialogs', (
    WidgetTester tester,
  ) async {
    setTallPhoneSurface(tester);
    final state = AppState();
    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const GamePlayScreen(game: calculatorGame, level: 1),
      ),
    );
    await pumpLoadedGame(tester);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('00:09'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('hint-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('hint-dialog')), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    expect(find.text('00:09'), findsOneWidget);
    expect(find.text('Game Over!!!'), findsNothing);

    await tester.tap(find.byKey(const ValueKey<String>('hint-close')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('00:08'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('pause-button')));
    await tester.pumpAndSettle();
    expect(find.text('Quit!!!'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    expect(find.text('00:08'), findsOneWidget);
    expect(find.text('Game Over!!!'), findsNothing);

    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('00:07'), findsOneWidget);
  });

  testWidgets('pause button opens quit dialog', (WidgetTester tester) async {
    setTallPhoneSurface(tester);
    final state = AppState();
    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const GamePlayScreen(game: calculatorGame, level: 1),
      ),
    );
    await pumpLoadedGame(tester);

    await tester.tap(find.byKey(const ValueKey<String>('pause-button')));
    await tester.pumpAndSettle();

    expect(find.text('Quit!!!'), findsOneWidget);
    expect(find.textContaining('Are you sure'), findsOneWidget);
    expect(find.text('Yes'), findsOneWidget);
    expect(find.text('No'), findsOneWidget);
  });

  testWidgets('header action variants match math and train games', (
    WidgetTester tester,
  ) async {
    setTallPhoneSurface(tester);
    final state = AppState();
    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const GamePlayScreen(game: calculatorGame, level: 1),
      ),
    );
    await pumpLoadedGame(tester);

    expect(find.byKey(const ValueKey<String>('hint-button')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('info-button')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('pause-button')), findsOneWidget);

    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const GamePlayScreen(game: magicTriangleGame, level: 1),
      ),
    );
    await pumpLoadedGame(tester);

    expect(find.byKey(const ValueKey<String>('hint-button')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('info-button')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('pause-button')), findsOneWidget);
  });

  testWidgets('settings toggles update visually', (WidgetTester tester) async {
    setTallPhoneSurface(tester);
    await tester.pumpWidget(const MathspazzelApp());

    await tester.tap(find.byKey(const ValueKey<String>('settings-button')));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('sound-toggle')));
    await tester.pump();

    final state = AppScope.of(tester.element(find.text('Settings')));
    expect(state.sound, isFalse);

    await tester.tap(find.byKey(const ValueKey<String>('dark-toggle')));
    await tester.pump();
    expect(state.darkMode, isTrue);
  });

  testWidgets('numeric keypad uses an icon backspace', (
    WidgetTester tester,
  ) async {
    setTallPhoneSurface(tester);
    final state = AppState();
    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const GamePlayScreen(game: calculatorGame, level: 1),
      ),
    );
    await pumpLoadedGame(tester);

    expect(find.byKey(const ValueKey<String>('key-backspace')), findsOneWidget);
    expect(find.byIcon(Icons.backspace_rounded), findsOneWidget);
  });

  testWidgets('numeric keypad keys use minimal-radius square shapes', (
    WidgetTester tester,
  ) async {
    setTallPhoneSurface(tester);
    final state = AppState();
    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const GamePlayScreen(game: calculatorGame, level: 1),
      ),
    );
    await pumpLoadedGame(tester);

    for (final key in const <String>['key-9', 'key-clear', 'key-backspace']) {
      final button = find.byKey(ValueKey<String>(key));
      final container = tester.widget<Container>(
        find.descendant(of: button, matching: find.byType(Container)).first,
      );
      final decoration = container.decoration as BoxDecoration;
      final borderRadius = decoration.borderRadius as BorderRadius;

      expect(decoration.shape, BoxShape.rectangle);
      expect(decoration.borderRadius, isNotNull);
      expect(
        borderRadius.topLeft.x,
        lessThan(AppDimensions.keypadButtonSize / 4),
      );
    }
  });

  testWidgets('gameplay screens fit without scroll views', (
    WidgetTester tester,
  ) async {
    setPhoneSurface(tester, const Size(360, 640));
    for (final game in allGames) {
      final state = AppState();
      await tester.pumpWidget(
        scopedTestApp(
          state: state,
          home: GamePlayScreen(game: game, level: 1),
        ),
      );
      await pumpLoadedGame(tester);

      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.byType(Scrollable), findsNothing);
      expectNoFlutterException(tester);
    }
  });

  testWidgets('numeric keypad playable flow completes calculator level', (
    WidgetTester tester,
  ) async {
    setTallPhoneSurface(tester);
    final state = AppState();
    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const GamePlayScreen(game: calculatorGame, level: 1),
      ),
    );
    await pumpLoadedGame(tester);

    await tester.tap(find.byKey(const ValueKey<String>('key-9')));
    await tester.tap(find.byKey(const ValueKey<String>('key-8')));
    await tester.pump();

    expect(state.trophyCount(calculatorGame.id), 1);
  });

  testWidgets('answer list playable flow completes guess sign level', (
    WidgetTester tester,
  ) async {
    setTallPhoneSurface(tester);
    final state = AppState();
    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const GamePlayScreen(game: guessSignGame, level: 1),
      ),
    );
    await pumpLoadedGame(tester);

    await tester.tap(find.text('*'));
    await tester.pump();

    expect(state.trophyCount(guessSignGame.id), 1);
  });

  testWidgets('true false playable flow completes level', (
    WidgetTester tester,
  ) async {
    setTallPhoneSurface(tester);
    final state = AppState();
    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const GamePlayScreen(game: trueFalseGame, level: 1),
      ),
    );
    await pumpLoadedGame(tester);

    await tester.tap(find.byKey(const ValueKey<String>('false-button')));
    await tester.pump();

    expect(state.trophyCount(trueFalseGame.id), 1);
  });

  testWidgets('magic triangle playable flow completes level', (
    WidgetTester tester,
  ) async {
    setTallPhoneSurface(tester);
    final state = AppState();
    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const GamePlayScreen(game: magicTriangleGame, level: 1),
      ),
    );
    await pumpLoadedGame(tester);

    final numbers = <int>[3, 2, 6, 5, 4, 1];
    for (int index = 0; index < numbers.length; index++) {
      await tester.tap(find.byKey(ValueKey<String>('triangle-slot-$index')));
      await tester.pump();
      await tester.tap(
        find.byKey(ValueKey<String>('triangle-${numbers[index]}')),
      );
      await tester.pump();
    }

    expect(state.trophyCount(magicTriangleGame.id), 1);
  });

  testWidgets('magic triangle rejects incorrect side sums', (
    WidgetTester tester,
  ) async {
    setTallPhoneSurface(tester);
    final state = AppState();
    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const GamePlayScreen(game: magicTriangleGame, level: 1),
      ),
    );
    await pumpLoadedGame(tester);

    final numbers = <int>[2, 3, 1, 4, 5, 6];
    for (int index = 0; index < numbers.length; index++) {
      await tester.tap(find.byKey(ValueKey<String>('triangle-slot-$index')));
      await tester.pump();
      await tester.tap(
        find.byKey(ValueKey<String>('triangle-${numbers[index]}')),
      );
      await tester.pump();
    }

    expect(state.trophyCount(magicTriangleGame.id), 0);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('magic triangle removes placed numbers from picker', (
    WidgetTester tester,
  ) async {
    setTallPhoneSurface(tester);
    final state = AppState();
    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const GamePlayScreen(game: magicTriangleGame, level: 1),
      ),
    );
    await pumpLoadedGame(tester);

    await tester.tap(find.byKey(const ValueKey<String>('triangle-slot-0')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('triangle-2')));
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('triangle-2')), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('triangle-2-used')),
      findsOneWidget,
    );

    for (final number in <int>[3, 1, 4, 5, 6]) {
      expect(find.byKey(ValueKey<String>('triangle-$number')), findsOneWidget);
    }

    expect(state.trophyCount(magicTriangleGame.id), 0);
  });

  testWidgets('magic triangle clears filled slot and restores number', (
    WidgetTester tester,
  ) async {
    setTallPhoneSurface(tester);
    final state = AppState();
    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const GamePlayScreen(game: magicTriangleGame, level: 1),
      ),
    );
    await pumpLoadedGame(tester);

    await tester.tap(find.byKey(const ValueKey<String>('triangle-slot-0')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('triangle-2')));
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('triangle-2')), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('triangle-2-used')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey<String>('triangle-slot-0')));
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('triangle-2')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('triangle-2-used')), findsNothing);
    expect(state.trophyCount(magicTriangleGame.id), 0);
  });

  testWidgets('magic triangle requires selecting a position before number', (
    WidgetTester tester,
  ) async {
    setTallPhoneSurface(tester);
    final state = AppState();
    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const GamePlayScreen(game: magicTriangleGame, level: 1),
      ),
    );
    await pumpLoadedGame(tester);

    await tester.tap(find.byKey(const ValueKey<String>('triangle-2')));
    await tester.pump();

    expect(find.text('Select a spot'), findsOneWidget);
    for (final number in <int>[2, 3, 1, 4, 5, 6]) {
      await tester.tap(find.byKey(ValueKey<String>('triangle-$number')));
      await tester.pump();
    }

    expect(state.trophyCount(magicTriangleGame.id), 0);
  });

  testWidgets('picture puzzle keypad playable flow completes level', (
    WidgetTester tester,
  ) async {
    setTallPhoneSurface(tester);
    final state = AppState();
    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const GamePlayScreen(game: picturePuzzleGame, level: 1),
      ),
    );
    await pumpLoadedGame(tester);

    await tester.tap(find.byKey(const ValueKey<String>('key-2')));
    await tester.tap(find.byKey(const ValueKey<String>('key-1')));
    await tester.pump();

    expect(state.trophyCount(picturePuzzleGame.id), 1);
  });

  testWidgets('visual keypad games show partial typed answers', (
    WidgetTester tester,
  ) async {
    setTallPhoneSurface(tester);
    final state = AppState();

    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const GamePlayScreen(game: picturePuzzleGame, level: 1),
      ),
    );
    await pumpLoadedGame(tester);

    final pictureAnswerCell = find.byKey(
      const ValueKey<String>('picture-puzzle-answer-cell'),
    );
    expect(pictureAnswerCell, findsOneWidget);
    expect(
      find.descendant(of: pictureAnswerCell, matching: find.text('?')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey<String>('key-2')));
    await tester.pump();

    expect(
      find.descendant(of: pictureAnswerCell, matching: find.text('2')),
      findsOneWidget,
    );
    expect(state.trophyCount(picturePuzzleGame.id), 0);

    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const GamePlayScreen(game: mathGridGame, level: 1),
      ),
    );
    await pumpLoadedGame(tester);

    final gridAnswerCell = find.byKey(
      const ValueKey<String>('math-grid-answer-cell'),
    );
    expect(gridAnswerCell, findsOneWidget);
    expect(
      find.descendant(of: gridAnswerCell, matching: find.text('?')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey<String>('key-1')));
    await tester.pump();

    expect(
      find.descendant(of: gridAnswerCell, matching: find.text('1')),
      findsOneWidget,
    );
    expect(state.trophyCount(mathGridGame.id), 0);
  });

  testWidgets('win popup shows stars, completed time, and next action', (
    WidgetTester tester,
  ) async {
    setTallPhoneSurface(tester);
    final state = AppState();
    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const GamePlayScreen(game: calculatorGame, level: 1),
      ),
    );
    await pumpLoadedGame(tester);

    await tapDigits(tester, '98');
    await tester.pumpAndSettle();

    expect(find.text('You Win!!!'), findsOneWidget);
    expect(find.textContaining('Completed'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('result-home')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('result-share')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('result-next')), findsOneWidget);
    expect(state.starsFor(calculatorGame.id, 1), 3);

    await tester.tap(find.byKey(const ValueKey<String>('result-next')));
    await tester.pumpAndSettle();

    expect(find.text('Level : 2'), findsOneWidget);
  });

  testWidgets('game over popup appears when timer expires', (
    WidgetTester tester,
  ) async {
    setTallPhoneSurface(tester);
    final state = AppState();
    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const GamePlayScreen(game: calculatorGame, level: 1),
      ),
    );
    await pumpLoadedGame(tester);

    await tester.pump(const Duration(seconds: 11));
    await tester.pumpAndSettle();

    expect(find.text('Game Over!!!'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('result-restart')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey<String>('result-home')), findsOneWidget);
    expect(state.trophyCount(calculatorGame.id), 0);
  });

  testWidgets('game over close returns to level selector', (
    WidgetTester tester,
  ) async {
    setTallPhoneSurface(tester);
    final state = AppState();
    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const LevelSelectScreen(game: calculatorGame),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey<String>('level-card-calculator-1')),
    );
    await tester.pumpAndSettle();
    await pumpLoadedGame(tester);

    await tester.pump(const Duration(seconds: 11));
    await tester.pumpAndSettle();

    expect(find.text('Game Over!!!'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('result-close')));
    await tester.pumpAndSettle();

    expect(find.text('Calculator'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('level-card-calculator-1')),
      findsOneWidget,
    );
    expect(find.text('Game Over!!!'), findsNothing);
    expect(state.trophyCount(calculatorGame.id), 0);
  });

  testWidgets('hint button opens level hint popup without solving level', (
    WidgetTester tester,
  ) async {
    setTallPhoneSurface(tester);
    final state = AppState();
    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const GamePlayScreen(game: calculatorGame, level: 1),
      ),
    );
    await pumpLoadedGame(tester);

    await tester.tap(find.byKey(const ValueKey<String>('hint-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('hint-dialog')), findsOneWidget);
    expect(find.text('Level 1 Hint'), findsOneWidget);
    expect(find.textContaining('Break 14 into 10 + 4'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('hint-use-coins')), findsNothing);
    expect(find.text('Watch Video'), findsNothing);
    expect(state.coins, AppConstants.initialCoins);
    expect(state.trophyCount(calculatorGame.id), 0);
  });

  testWidgets('hint popup uses per-level json hint when available', (
    WidgetTester tester,
  ) async {
    setTallPhoneSurface(tester);
    final state = AppState();
    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const GamePlayScreen(game: calculatorGame, level: 5),
      ),
    );
    await pumpLoadedGame(tester);

    await tester.tap(find.byKey(const ValueKey<String>('hint-button')));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('This is the distributive method of multiplication.'),
      findsOneWidget,
    );
    expect(state.trophyCount(calculatorGame.id), 0);
  });

  testWidgets('train your brain games show level hints', (
    WidgetTester tester,
  ) async {
    setTallPhoneSurface(tester);
    final state = AppState();
    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const GamePlayScreen(game: magicTriangleGame, level: 1),
      ),
    );
    await pumpLoadedGame(tester);

    await tester.tap(find.byKey(const ValueKey<String>('hint-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('hint-dialog')), findsOneWidget);
    expect(
      find.textContaining('Place the numbers so each side of the triangle'),
      findsOneWidget,
    );
    expect(state.trophyCount(magicTriangleGame.id), 0);
  });

  testWidgets('new root and structured keypad games complete', (
    WidgetTester tester,
  ) async {
    setTallPhoneSurface(tester);
    final state = AppState();

    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const GamePlayScreen(game: squareRootGame, level: 1),
      ),
    );
    await pumpLoadedGame(tester);
    await tapDigits(tester, '4');
    await tester.pumpAndSettle();
    expect(state.trophyCount(squareRootGame.id), 1);
    await dismissResultDialog(tester);

    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const GamePlayScreen(game: numberPyramidGame, level: 1),
      ),
    );
    await pumpLoadedGame(tester);
    await tapDigits(tester, '1');
    await tester.pumpAndSettle();
    expect(state.trophyCount(numberPyramidGame.id), 1);
    await dismissResultDialog(tester);

    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const GamePlayScreen(game: mathGridGame, level: 1),
      ),
    );
    await pumpLoadedGame(tester);
    await tapDigits(tester, '17');
    await tester.pumpAndSettle();
    expect(state.trophyCount(mathGridGame.id), 1);
    await dismissResultDialog(tester);
  });

  testWidgets('number pyramid shows typed answer and next level works', (
    WidgetTester tester,
  ) async {
    setTallPhoneSurface(tester);
    final state = AppState();
    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const GamePlayScreen(game: numberPyramidGame, level: 3),
      ),
    );
    await pumpLoadedGame(tester);

    final answerCell = find.byKey(
      const ValueKey<String>('number-pyramid-answer-cell'),
    );
    expect(answerCell, findsOneWidget);
    expect(
      find.descendant(of: answerCell, matching: find.text('?')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey<String>('key-7')));
    await tester.pump();

    expect(
      find.descendant(of: answerCell, matching: find.text('7')),
      findsOneWidget,
    );
    expect(state.trophyCount(numberPyramidGame.id), 0);

    await tapDigits(tester, '20');
    await tester.pumpAndSettle();

    expect(state.trophyCount(numberPyramidGame.id), 1);
    expect(find.text('You Win!!!'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('result-next')));
    await tester.pumpAndSettle();

    expect(find.text('Level : 4'), findsOneWidget);
  });

  testWidgets('new card-based games complete', (WidgetTester tester) async {
    setTallPhoneSurface(tester);
    final state = AppState();

    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const GamePlayScreen(game: mathPairsGame, level: 1),
      ),
    );
    await pumpLoadedGame(tester);
    for (int index = 0; index < 12; index += 2) {
      await tester.tap(find.byKey(ValueKey<String>('math-pairs-card-$index')));
      await tester.pump();
      await tester.tap(
        find.byKey(ValueKey<String>('math-pairs-card-${index + 1}')),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(state.trophyCount(mathPairsGame.id), 1);
    await dismissResultDialog(tester);

    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const GamePlayScreen(game: concentrationGame, level: 1),
      ),
    );
    await pumpLoadedGame(tester);
    for (int index = 0; index < 12; index += 2) {
      await tester.tap(
        find.byKey(ValueKey<String>('concentration-card-$index')),
      );
      await tester.pump();
      await tester.tap(
        find.byKey(ValueKey<String>('concentration-card-${index + 1}')),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(state.trophyCount(concentrationGame.id), 1);
    await dismissResultDialog(tester);

    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const GamePlayScreen(game: numericMemoryGame, level: 1),
      ),
    );
    await pumpLoadedGame(tester);
    for (final index in <int>[2, 5, 8, 10]) {
      await tester.tap(
        find.byKey(ValueKey<String>('numeric-memory-card-$index')),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(state.trophyCount(numericMemoryGame.id), 1);
  });

  testWidgets('sound disabled still allows completion without audio failures', (
    WidgetTester tester,
  ) async {
    setTallPhoneSurface(tester);
    final state = AppState()..sound = false;
    await tester.pumpWidget(
      scopedTestApp(
        state: state,
        home: const GamePlayScreen(game: calculatorGame, level: 1),
      ),
    );
    await pumpLoadedGame(tester);

    await tapDigits(tester, '98');
    await tester.pumpAndSettle();

    expect(state.trophyCount(calculatorGame.id), 1);
    expect(state.sound, isFalse);
  });

  test('feedback effects map to loadable sound assets', () async {
    final expectedPaths = <AppFeedbackEffect, String>{
      AppFeedbackEffect.tap: 'sounds/tick.mp3',
      AppFeedbackEffect.correct: 'sounds/right.mp3',
      AppFeedbackEffect.wrong: 'sounds/wrong.mp3',
      AppFeedbackEffect.gameOver: 'sounds/wrong.mp3',
    };

    for (final entry in expectedPaths.entries) {
      expect(AppFeedback.assetFor(entry.key), entry.value);
      final data = await rootBundle.load('assets/${entry.value}');
      expect(data.lengthInBytes, greaterThan(0));
    }
  });

  testWidgets('game screens avoid overflow on phone-sized viewports', (
    WidgetTester tester,
  ) async {
    for (final size in <Size>[
      const Size(360, 640),
      const Size(390, 844),
      const Size(430, 932),
    ]) {
      setPhoneSurface(tester, size);
      final state = AppState();
      await tester.pumpWidget(
        scopedTestApp(
          state: state,
          home: CappedScaffold(
            child: Column(
              children: <Widget>[
                TopGameBar(
                  title: complexCalculationGame.title,
                  theme: complexCalculationGame.theme,
                  showActions: true,
                  onPause: () {},
                ),
              ],
            ),
          ),
        ),
      );
      expectNoFlutterException(tester);

      await tester.pumpWidget(
        scopedTestApp(
          state: state,
          home: const CappedScaffold(
            child: GamePanel(
              game: complexCalculationGame,
              level: 1,
              score: 0,
              secondsRemaining: 20,
              maxSeconds: 20,
              child: SizedBox.shrink(),
            ),
          ),
        ),
      );
      expectNoFlutterException(tester);

      await tester.pumpWidget(
        scopedTestApp(
          state: state,
          home: const CappedScaffold(
            child: GamePanel(
              game: complexCalculationGame,
              level: 1,
              score: 0,
              secondsRemaining: 20,
              maxSeconds: 20,
              child: ExpressionWithMissingBox(expression: '37 - 38 - ? = -27'),
            ),
          ),
        ),
      );
      expectNoFlutterException(tester);

      await tester.pumpWidget(
        scopedTestApp(
          state: state,
          home: CappedScaffold(
            child: BottomAnswerSheet(
              child: AnswerList(
                choices: const <String>['36', '18', '26', '16'],
                color: complexCalculationGame.theme.primary,
                onChoice: (_) {},
              ),
            ),
          ),
        ),
      );
      expectNoFlutterException(tester);

      await tester.pumpWidget(
        scopedTestApp(
          state: state,
          home: const GamePlayScreen(game: complexCalculationGame, level: 1),
        ),
      );
      await pumpLoadedGame(tester);
      expectNoFlutterException(tester);

      await tester.pumpWidget(
        scopedTestApp(
          state: state,
          home: const GamePlayScreen(game: picturePuzzleGame, level: 1),
        ),
      );
      await pumpLoadedGame(tester);
      expectNoFlutterException(tester);

      for (final game in allGames) {
        await tester.pumpWidget(
          scopedTestApp(
            state: state,
            home: GamePlayScreen(game: game, level: 1),
          ),
        );
        await pumpLoadedGame(tester);
        expectNoFlutterException(tester);
      }

      await tester.pumpWidget(
        scopedTestApp(state: state, home: const SettingsScreen()),
      );
      expectNoFlutterException(tester);
    }
  });

  test('all game levels load from json assets', () async {
    for (final game in allGames) {
      final jsonString = await rootBundle.loadString(
        'assets/levels/${game.id}.json',
      );
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      if (game.mode == PlayMode.numberPyramid) {
        expect(json['totalLevels'], game.totalLevels);
        final groups = await loadLevelGroupsFor(game);
        final levels = groups
            .expand((GameLevelGroup group) => group.levels)
            .toList(growable: false);
        expect(levels, hasLength(game.totalLevels));
        expect(groups.first.label, 'All {+},{-},{*},{/}');
        expect(groups.last.lastLevel, game.totalLevels);
      } else {
        final levels = (json['levels'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
        expect(levels, hasLength(AppConstants.levelsPerGame));
      }

      for (int level = 1; level <= game.totalLevels; level++) {
        final question = await loadQuestionFor(game, level);
        expectQuestionLogic(game, question);
      }
    }

    final calculatorQuestion = await loadQuestionFor(calculatorGame, 1);
    expect(calculatorQuestion.expression, '14 * 7');
    expect(calculatorQuestion.answer, '98');

    final calculatorHintQuestion = await loadQuestionFor(calculatorGame, 5);
    expect(calculatorHintQuestion.expression, '17 * 8');
    expect(calculatorHintQuestion.answer, '136');
    expect(calculatorHintQuestion.data['hint'], contains('10 + 7'));

    final magicQuestion = await loadQuestionFor(magicTriangleGame, 1);
    expect(magicQuestion.numberOptions, <int>[2, 3, 1, 4, 5, 6]);

    final pictureQuestion = await loadQuestionFor(picturePuzzleGame, 1);
    expect(pictureQuestion.pictureRows, hasLength(4));

    final pyramidQuestion = await loadQuestionFor(numberPyramidGame, 1);
    expect(pyramidQuestion.gridRows, hasLength(3));
    expect(pyramidQuestion.pyramidOps, containsPair('op1', '/'));
    expect(pyramidQuestion.groupLabel, 'All {+},{-},{*},{/}');
  });
}
