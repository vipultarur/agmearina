import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../common/widgets/app_motion.dart';
import '../../../../common/widgets/capped_scaffold.dart';
import '../../../../common/widgets/level_card.dart';
import '../../../../common/widgets/top_game_bar.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/navigation.dart';
import '../../../gameplay/data/question_bank.dart';
import '../../../gameplay/presentation/screens/game_play_screen.dart';
import '../../../games/domain/entities/game_config.dart';

class LevelSelectScreen extends StatelessWidget {
  final GameConfig game;

  const LevelSelectScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return CappedScaffold(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            TopGameBar(
              title: game.title,
              theme: game.theme,
              centered: true,
              showActions: false,
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(18.w, 26.h, 18.w, 0),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 28.h),
                  decoration: BoxDecoration(
                    color: game.theme.soft,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.cardRadius + 6,
                    ),
                  ),
                  child: game.mode == PlayMode.numberPyramid
                      ? _GroupedNumberPyramidLevels(game: game)
                      : _FlatLevelGrid(game: game),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlatLevelGrid extends StatelessWidget {
  final GameConfig game;

  const _FlatLevelGrid({required this.game});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: game.totalLevels,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 18.w,
        mainAxisSpacing: 28.h,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (BuildContext context, int index) {
        final level = index + 1;
        return _LevelCardEntry(game: game, level: level, animationIndex: index);
      },
    );
  }
}

class _GroupedNumberPyramidLevels extends StatefulWidget {
  final GameConfig game;

  const _GroupedNumberPyramidLevels({required this.game});

  @override
  State<_GroupedNumberPyramidLevels> createState() =>
      _GroupedNumberPyramidLevelsState();
}

class _GroupedNumberPyramidLevelsState
    extends State<_GroupedNumberPyramidLevels> {
  late final Future<List<GameLevelGroup>> groupsFuture;

  @override
  void initState() {
    super.initState();
    groupsFuture = loadLevelGroupsFor(widget.game);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GameLevelGroup>>(
      future: groupsFuture,
      builder:
          (BuildContext context, AsyncSnapshot<List<GameLevelGroup>> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Level data unavailable',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.dialogBody,
                ),
              );
            }
            if (!snapshot.hasData) {
              return Center(
                child: Text(
                  'Loading...',
                  style: AppTextStyles.dialogBody.copyWith(
                    color: widget.game.theme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }

            final groups = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: groups.length,
              itemBuilder: (BuildContext context, int groupIndex) {
                final group = groups[groupIndex];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: groupIndex == groups.length - 1 ? 0 : 24.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _LevelGroupHeader(
                        group: group,
                        color: widget.game.theme.primary,
                      ),
                      SizedBox(height: 14.h),
                      GridView.builder(
                        shrinkWrap: true,
                        primary: false,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: group.levels.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 18.w,
                          mainAxisSpacing: 24.h,
                          childAspectRatio: 0.82,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          final level = group.levels[index];
                          return _LevelCardEntry(
                            game: widget.game,
                            level: level,
                            animationIndex: level - 1,
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
    );
  }
}

class _LevelGroupHeader extends StatelessWidget {
  final GameLevelGroup group;
  final Color color;

  const _LevelGroupHeader({required this.group, required this.color});

  @override
  Widget build(BuildContext context) {
    final range = group.firstLevel == null || group.lastLevel == null
        ? ''
        : '${group.firstLevel}-${group.lastLevel}';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: color.withValues(alpha: 0.34),
          width: AppDimensions.regularStroke,
        ),
      ),
      child: Row(
        children: <Widget>[
          if (group.phase != null) ...<Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
              ),
              child: Text(
                'Phase ${group.phase}',
                style: AppTextStyles.levelLabel.copyWith(color: AppColors.text),
              ),
            ),
            SizedBox(width: 10.w),
          ],
          Expanded(
            child: Text(
              group.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.dialogBody.copyWith(
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (range.isNotEmpty) ...<Widget>[
            SizedBox(width: 10.w),
            Text(
              range,
              style: AppTextStyles.levelLabel.copyWith(color: AppColors.text),
            ),
          ],
        ],
      ),
    );
  }
}

class _LevelCardEntry extends StatelessWidget {
  final GameConfig game;
  final int level;
  final int animationIndex;

  const _LevelCardEntry({
    required this.game,
    required this.level,
    required this.animationIndex,
  });

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final completed = state.isLevelCompleted(game.id, level);
    final locked = !state.isLevelUnlocked(game.id, level);
    final stars = state.starsFor(game.id, level);
    return StaggeredEntry(
      index: animationIndex,
      stepDelay: const Duration(milliseconds: 14),
      child: LevelCard(
        key: ValueKey<String>('level-card-${game.id}-$level'),
        gameId: game.id,
        level: level,
        color: game.theme.primary,
        stars: stars,
        completed: completed,
        locked: locked,
        onTap: locked
            ? null
            : () =>
                  pushScreen(context, GamePlayScreen(game: game, level: level)),
      ),
    );
  }
}
