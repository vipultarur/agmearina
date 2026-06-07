import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../common/widgets/answer_controls.dart';
import '../../../../common/widgets/app_motion.dart';
import '../../../../common/widgets/capped_scaffold.dart';
import '../../../../common/widgets/game_panel.dart';
import '../../../../common/widgets/hint_dialog.dart';
import '../../../../common/widgets/quit_dialog.dart';
import '../../../../common/widgets/result_dialog.dart';
import '../../../../common/widgets/timer_ring.dart';
import '../../../../common/widgets/top_game_bar.dart';
import '../../../../core/services/app_feedback.dart';
import '../../../../core/state/app_state.dart';
import '../../../gameplay/data/question_bank.dart';
import '../../../gameplay/domain/entities/game_question.dart';
import '../../../games/data/game_catalog.dart';
import '../../../games/domain/entities/game_config.dart';
import '../widgets/puzzle_displays.dart';

class GamePlayScreen extends StatefulWidget {
  final GameConfig game;
  final int level;

  const GamePlayScreen({super.key, required this.game, required this.level});

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> with WidgetsBindingObserver {
  GameQuestion? question;
  Object? questionLoadError;
  late final ValueNotifier<int> secondsRemainingNotifier;
  Timer? timer;
  String input = '';
  String secondInput = '';
  int activeDualInput = 0;
  int score = 0;
  int feedbackTrigger = 0;
  bool feedbackCorrect = true;
  int? selectedTriangleSlot;
  final List<int?> triangleSlots = List<int?>.filled(6, null);
  bool roundEnded = false;
  final Set<int> revealedCardIndexes = <int>{};
  final Set<int> solvedCardIndexes = <int>{};
  final List<int> selectedCardIndexes = <int>[];
  bool questionLoadStarted = false;

  @override
  void initState() {
    super.initState();
    secondsRemainingNotifier = ValueNotifier<int>(widget.game.maxSeconds);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (questionLoadStarted) {
      return;
    }
    questionLoadStarted = true;
    loadQuestion(DefaultAssetBundle.of(context));
  }

  void startTimer() {
    timer?.cancel();
    timer = null;
    if (roundEnded || question == null || questionLoadError != null) {
      return;
    }
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) return;
      if (roundEnded || question == null || questionLoadError != null) {
        return;
      }
      final nextSeconds = math.max(0, secondsRemainingNotifier.value - 1);
      secondsRemainingNotifier.value = nextSeconds;
      if (nextSeconds == 0) {
        finishRound(won: false);
      }
    });
  }

  void pauseTimer() {
    timer?.cancel();
    timer = null;
  }

  void resumeTimerIfActive() {
    if (!mounted || roundEnded || secondsRemainingNotifier.value <= 0) {
      return;
    }
    startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    timer?.cancel();
    secondsRemainingNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      pauseTimer();
    } else if (state == AppLifecycleState.resumed) {
      resumeTimerIfActive();
    }
  }

  Future<void> loadQuestion(AssetBundle bundle) async {
    try {
      final loadedQuestion = await loadQuestionFor(
        widget.game,
        widget.level,
        bundle: bundle,
      );
      if (!mounted) return;
      setState(() {
        question = loadedQuestion;
        questionLoadError = null;
      });
      startTimer();
    } catch (error) {
      if (!mounted) return;
      pauseTimer();
      setState(() {
        questionLoadError = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loadedQuestion = question;
    return CappedScaffold(
      child: Column(
        children: <Widget>[
          FadeSlideIn(
            child: TopGameBar(
              title: widget.game.title,
              theme: widget.game.theme,
              showActions: true,
              showHint:
                  widget.game.mode != PlayMode.mathPairs &&
                  widget.game.mode != PlayMode.numericMemory &&
                  widget.game.mode != PlayMode.concentration,
              onBack: () => Navigator.of(context).pop(),
              onHint: loadedQuestion == null
                  ? null
                  : () => showLevelHint(loadedQuestion),
              onPause: showPauseDialog,
            ),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                FadeSlideIn(
                  delay: const Duration(milliseconds: 80),
                  child: ResultFeedbackMotion(
                    trigger: feedbackTrigger,
                    correct: feedbackCorrect,
                    child: widget.game.mode == PlayMode.magicTriangle
                        ? _buildMagicTriangleGamePanel(loadedQuestion)
                        : GamePanel(
                            game: widget.game,
                            level: widget.level,
                            secondsRemainingNotifier: secondsRemainingNotifier,
                            maxSeconds: widget.game.maxSeconds,
                            child: FadeSlideIn(
                              delay: const Duration(milliseconds: 120),
                              child: loadedQuestion == null
                                  ? buildQuestionPlaceholder()
                                  : buildPuzzleArea(loadedQuestion),
                            ),
                          ),
                  ),
                ),
                Expanded(
                  child: FadeSlideIn(
                    delay: const Duration(milliseconds: 150),
                    beginOffset: const Offset(0, 0.10),
                    child: BottomAnswerSheet(
                      child: loadedQuestion == null
                          ? const SizedBox.shrink()
                          : buildAnswerArea(loadedQuestion),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMagicTriangleGamePanel(GameQuestion? loadedQuestion) {
    final appState = AppScope.of(context);
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppDimensions.gamePanelHorizontalMargin,
          AppDimensions.gamePanelTopMargin,
          AppDimensions.gamePanelHorizontalMargin,
          0,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20.w, 54.h, 20.w, 24.h),
              decoration: BoxDecoration(
                color: widget.game.theme.panel,
                borderRadius: BorderRadius.circular(AppDimensions.panelRadius),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Level : ${widget.level}',
                            style: AppTextStyles.gameLevel,
                          ),
                        ),
                      ),
                      MetricStack(coins: appState.coins),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 120),
                    child: loadedQuestion == null
                        ? buildQuestionPlaceholder()
                        : Text(
                            loadedQuestion.expression,
                            style: AppTextStyles.equationLarge.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: AppDimensions.gamePanelTimerTop - 8.r,
              child: Container(
                width: AppDimensions.timerOuterSize + 16.r,
                height: AppDimensions.timerOuterSize + 16.r,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: AppDimensions.gamePanelTimerTop,
              child: ValueListenableBuilder<int>(
                valueListenable: secondsRemainingNotifier,
                builder: (context, remaining, child) {
                  return TimerRing(
                    color: widget.game.theme.primary,
                    remaining: remaining,
                    maxSeconds: widget.game.maxSeconds,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildQuestionPlaceholder() {
    if (questionLoadError != null) {
      return Text(
        'Level data unavailable',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium,
      );
    }
    return Text(
      'Loading...',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: widget.game.theme.primary,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget buildPuzzleArea(GameQuestion question) {
    switch (widget.game.mode) {
      case PlayMode.keypad:
        if (widget.game.id == mentalArithmeticGame.id) {
          return MentalArithmeticDisplay(
            expression: question.expression,
            input: input,
          );
        }
        return KeypadPuzzleDisplay(
          expression: question.expression,
          input: input,
          mentalMode: false,
        );
      case PlayMode.answers:
        return ExpressionWithMissingBox(expression: question.expression);
      case PlayMode.trueFalse:
        return CenterExpression(expression: question.expression);
      case PlayMode.magicTriangle:
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: Text(
            question.expression,
            style: AppTextStyles.equationLarge.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        );
      case PlayMode.picturePuzzle:
        return PictureEquationPanel(rows: question.pictureRows, input: input);
      case PlayMode.dualGame:
        return DualGameDisplay(
          expression: question.expression,
          firstInput: input,
          secondInput: secondInput,
          activeIndex: activeDualInput,
          onSelect: (int index) => setState(() => activeDualInput = index),
        );
      case PlayMode.mathPairs:
        return CenterExpression(expression: question.expression);
      case PlayMode.numericMemory:
        return CenterExpression(expression: question.target);
      case PlayMode.concentration:
        return CenterExpression(expression: question.expression);
      case PlayMode.numberPyramid:
        return NumberPyramidPanel(
          rows: question.gridRows,
          ops: question.pyramidOps,
          input: input,
        );
      case PlayMode.mathGrid:
        return MathGridPanel(rows: question.gridRows, input: input);
    }
  }

  Future<void> showLevelHint(GameQuestion question) async {
    pauseTimer();
    await showHintDialog(
      context,
      game: widget.game,
      level: widget.level,
      question: question,
    );
    if (!mounted) return;
    resumeTimerIfActive();
  }

  Future<void> showPauseDialog() async {
    pauseTimer();
    await showQuitDialog(context, widget.game.theme);
    if (!mounted) return;
    resumeTimerIfActive();
  }

  Widget buildAnswerArea(GameQuestion question) {
    switch (widget.game.mode) {
      case PlayMode.keypad:
        return NumericKeypad(
          color: widget.game.theme.primary,
          onDigit: appendDigit,
          onClear: () => setState(() => input = ''),
          onBackspace: backspace,
          allowNegative: widget.game.id == mentalArithmeticGame.id,
        );
      case PlayMode.answers:
        return AnswerList(
          choices: question.choices,
          color: widget.game.theme.primary,
          onChoice: handleAnswer,
        );
      case PlayMode.trueFalse:
        return TrueFalseButtons(onChoice: handleAnswer);
      case PlayMode.magicTriangle:
        return Column(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Center(
                child: MagicTriangleBoard(
                  target: question.expression,
                  slots: triangleSlots,
                  selectedIndex: selectedTriangleSlot,
                  onSlotSelected: selectTriangleSlot,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Expanded(
              flex: 4,
              child: MagicTrianglePicker(
                numbers: question.numberOptions,
                used: triangleSlots.whereType<int>().toSet(),
                onPick: pickTriangleNumber,
              ),
            ),
          ],
        );
      case PlayMode.picturePuzzle:
        return NumericKeypad(
          color: widget.game.theme.primary,
          onDigit: appendDigit,
          onClear: () => setState(() => input = ''),
          onBackspace: backspace,
        );
      case PlayMode.dualGame:
        return NumericKeypad(
          color: widget.game.theme.primary,
          onDigit: appendDigit,
          onClear: clearActiveInput,
          onBackspace: backspace,
        );
      case PlayMode.mathPairs:
        return CardGridDisplay(
          cards: question.cards,
          revealedIndexes: selectedCardIndexes.toSet(),
          solvedIndexes: solvedCardIndexes,
          color: widget.game.theme.primary,
          coveredByDefault: false,
          keyPrefix: 'math-pairs',
          onTap: handleCardTap,
        );
      case PlayMode.numericMemory:
        return CardGridDisplay(
          cards: question.cards,
          revealedIndexes: revealedCardIndexes,
          solvedIndexes: solvedCardIndexes,
          color: widget.game.theme.primary,
          coveredByDefault: true,
          keyPrefix: 'numeric-memory',
          onTap: handleCardTap,
        );
      case PlayMode.concentration:
        return CardGridDisplay(
          cards: question.cards,
          revealedIndexes: revealedCardIndexes,
          solvedIndexes: solvedCardIndexes,
          color: widget.game.theme.primary,
          coveredByDefault: true,
          keyPrefix: 'concentration',
          onTap: handleCardTap,
        );
      case PlayMode.numberPyramid:
      case PlayMode.mathGrid:
        return NumericKeypad(
          color: widget.game.theme.primary,
          onDigit: appendDigit,
          onClear: () => setState(() => input = ''),
          onBackspace: backspace,
        );
    }
  }

  void appendDigit(String digit) {
    if (roundEnded) return;
    setState(() {
      if (widget.game.mode == PlayMode.dualGame && activeDualInput == 1) {
        secondInput += digit;
      } else {
        input += digit;
      }
    });
    checkAutoAnswer();
  }

  void clearActiveInput() {
    if (roundEnded) return;
    setState(() {
      if (widget.game.mode == PlayMode.dualGame && activeDualInput == 1) {
        secondInput = '';
      } else {
        input = '';
      }
    });
  }

  void backspace() {
    if (roundEnded) return;
    setState(() {
      if (widget.game.mode == PlayMode.dualGame && activeDualInput == 1) {
        if (secondInput.isNotEmpty) {
          secondInput = secondInput.substring(0, secondInput.length - 1);
        }
      } else if (input.isNotEmpty) {
        input = input.substring(0, input.length - 1);
      }
    });
  }

  void checkAutoAnswer() {
    final loadedQuestion = question;
    if (loadedQuestion == null) {
      return;
    }
    if (widget.game.mode == PlayMode.dualGame) {
      if ('$input,$secondInput' == loadedQuestion.answer) {
        finishRound(won: true);
      } else {
        final parts = loadedQuestion.answer.split(',');
        if (parts.length == 2) {
          final firstTarget = parts[0];
          final secondTarget = parts[1];
          if (activeDualInput == 0 && input.length >= firstTarget.length && input != firstTarget) {
            showFeedback('Try again', correct: false);
            final wrongInput = input;
            Future<void>.delayed(const Duration(milliseconds: 500), () {
              if (!mounted || roundEnded || input != wrongInput) return;
              setState(() {
                input = '';
              });
            });
          } else if (activeDualInput == 1 && secondInput.length >= secondTarget.length && secondInput != secondTarget) {
            showFeedback('Try again', correct: false);
            final wrongInput = secondInput;
            Future<void>.delayed(const Duration(milliseconds: 500), () {
              if (!mounted || roundEnded || secondInput != wrongInput) return;
              setState(() {
                secondInput = '';
              });
            });
          }
        }
      }
      return;
    }

    if (input == loadedQuestion.answer) {
      finishRound(won: true);
    } else if (input.length >= loadedQuestion.answer.length) {
      showFeedback('Try again', correct: false);
      final wrongInput = input;
      Future<void>.delayed(const Duration(milliseconds: 500), () {
        if (!mounted || roundEnded || input != wrongInput) return;
        setState(() {
          input = '';
        });
      });
    }
  }

  void handleAnswer(String value) {
    if (roundEnded) return;
    final loadedQuestion = question;
    if (loadedQuestion == null) {
      return;
    }
    if (value == loadedQuestion.answer) {
      finishRound(won: true);
    } else {
      showFeedback('Try again', correct: false);
    }
  }

  void selectTriangleSlot(int index) {
    if (roundEnded) return;
    setState(() {
      if (triangleSlots[index] != null) {
        triangleSlots[index] = null;
      }
      selectedTriangleSlot = index;
    });
  }

  void pickTriangleNumber(int number) {
    if (roundEnded) return;
    final loadedQuestion = question;
    if (loadedQuestion == null) {
      return;
    }
    final slotIndex = selectedTriangleSlot;
    if (slotIndex == null) {
      return;
    }
    setState(() {
      triangleSlots[slotIndex] = number;
      selectedTriangleSlot = null;
    });
    if (triangleSlots.every((int? slot) => slot != null)) {
      if (isMagicTriangleSolved(loadedQuestion)) {
        finishRound(won: true);
      } else {
        showFeedback('Try again', correct: false);
      }
    }
  }

  bool isMagicTriangleSolved(GameQuestion question) {
    final target = int.tryParse(question.expression);
    final values = triangleSlots.whereType<int>().toList(growable: false);
    if (target == null || values.length != triangleSlots.length) {
      return false;
    }

    final leftSide = values[0] + values[1] + values[3];
    final rightSide = values[0] + values[2] + values[5];
    final bottomSide = values[3] + values[4] + values[5];
    return leftSide == target && rightSide == target && bottomSide == target;
  }

  void handleCardTap(int index) {
    if (roundEnded || solvedCardIndexes.contains(index)) {
      return;
    }
    final loadedQuestion = question;
    if (loadedQuestion == null || index >= loadedQuestion.cards.length) {
      return;
    }

    switch (widget.game.mode) {
      case PlayMode.mathPairs:
        handlePairTap(index, covered: false);
        break;
      case PlayMode.concentration:
        handlePairTap(index, covered: true);
        break;
      case PlayMode.numericMemory:
        handleNumericMemoryTap(index);
        break;
      case PlayMode.keypad:
      case PlayMode.answers:
      case PlayMode.trueFalse:
      case PlayMode.magicTriangle:
      case PlayMode.picturePuzzle:
      case PlayMode.dualGame:
      case PlayMode.numberPyramid:
      case PlayMode.mathGrid:
        break;
    }
  }

  void handlePairTap(int index, {required bool covered}) {
    final loadedQuestion = question;
    if (loadedQuestion == null ||
        selectedCardIndexes.contains(index) ||
        selectedCardIndexes.length >= 2) {
      return;
    }
    setState(() {
      selectedCardIndexes.add(index);
      revealedCardIndexes.add(index);
    });
    if (selectedCardIndexes.length < 2) {
      return;
    }

    final first = selectedCardIndexes[0];
    final second = selectedCardIndexes[1];
    final matched =
        loadedQuestion.cards[first].id == loadedQuestion.cards[second].id;
    if (matched) {
      setState(() {
        solvedCardIndexes.add(first);
        solvedCardIndexes.add(second);
        selectedCardIndexes.clear();
      });
      if (solvedCardIndexes.length == loadedQuestion.cards.length) {
        finishRound(won: true);
      } else {
        AppFeedback.play(context, AppFeedbackEffect.correct);
      }
      return;
    }

    showFeedback('Try again', correct: false);
    Future<void>.delayed(const Duration(milliseconds: 420), () {
      if (!mounted) return;
      setState(() {
        if (covered) {
          revealedCardIndexes.remove(first);
          revealedCardIndexes.remove(second);
        }
        selectedCardIndexes.clear();
      });
    });
  }

  void handleNumericMemoryTap(int index) {
    final loadedQuestion = question;
    if (loadedQuestion == null || revealedCardIndexes.contains(index)) {
      return;
    }
    final card = loadedQuestion.cards[index];
    setState(() {
      revealedCardIndexes.add(index);
      if (card.answer == loadedQuestion.target) {
        solvedCardIndexes.add(index);
      }
    });
    if (card.answer != loadedQuestion.target) {
      showFeedback('Try again', correct: false);
      return;
    }
    final targetCount = loadedQuestion.cards
        .where((PuzzleCardData card) => card.answer == loadedQuestion.target)
        .length;
    if (solvedCardIndexes.length >= targetCount) {
      finishRound(won: true);
    } else {
      AppFeedback.play(context, AppFeedbackEffect.correct);
    }
  }

  void finishRound({required bool won}) {
    if (roundEnded) {
      return;
    }
    if (!won && question == null) {
      return;
    }
    pauseTimer();
    final completedSeconds = widget.game.maxSeconds - secondsRemainingNotifier.value;
    final earnedStars = won ? calculateStars() : 0;
    if (won) {
      AppScope.of(context).completeLevel(
        widget.game.id,
        widget.level,
        stars: earnedStars,
        completedSeconds: completedSeconds,
      );
      AppFeedback.play(context, AppFeedbackEffect.correct);
    } else {
      AppFeedback.play(context, AppFeedbackEffect.gameOver);
    }
    setState(() {
      roundEnded = true;
      feedbackCorrect = won;
      feedbackTrigger += 1;
      score = won ? earnedStars : 0;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showGameResultDialog(
        context,
        game: widget.game,
        level: widget.level,
        won: won,
        stars: earnedStars,
        score: won ? earnedStars : 0,
        completedSeconds: completedSeconds,
        onRestart: restartLevel,
        onHome: goHome,
        onClose: goLevelSelect,
        onNext: widget.level >= widget.game.totalLevels ? null : goNext,
      );
    });
  }

  int calculateStars() {
    final progress = widget.game.maxSeconds == 0
        ? 0.0
        : secondsRemainingNotifier.value / widget.game.maxSeconds;
    if (progress >= 0.70) {
      return 3;
    }
    if (progress >= 0.40) {
      return 2;
    }
    return 1;
  }

  void restartLevel() {
    secondsRemainingNotifier.value = widget.game.maxSeconds;
    setState(() {
      input = '';
      secondInput = '';
      activeDualInput = 0;
      score = 0;
      roundEnded = false;
      selectedTriangleSlot = null;
      for (int index = 0; index < triangleSlots.length; index++) {
        triangleSlots[index] = null;
      }
      revealedCardIndexes.clear();
      solvedCardIndexes.clear();
      selectedCardIndexes.clear();
    });
    loadQuestion(DefaultAssetBundle.of(context));
  }

  void goHome() {
    Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
  }

  void goLevelSelect() {
    Navigator.of(context).maybePop();
  }

  void goNext() {
    if (widget.level >= widget.game.totalLevels) {
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            GamePlayScreen(game: widget.game, level: widget.level + 1),
      ),
    );
  }

  void showFeedback(String message, {required bool correct}) {
    if (!correct) {
      AppFeedback.play(context, AppFeedbackEffect.wrong);
    }
    setState(() {
      feedbackCorrect = correct;
      feedbackTrigger += 1;
    });
  }
}
