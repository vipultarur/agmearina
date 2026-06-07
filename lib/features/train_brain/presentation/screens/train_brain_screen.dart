import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../common/widgets/app_motion.dart';
import '../../../../common/widgets/capped_scaffold.dart';
import '../../../../common/widgets/store_header.dart';
import '../../../../common/widgets/sub_game_card.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/navigation.dart';
import '../../../games/data/game_catalog.dart';
import '../../../levels/presentation/screens/level_select_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class TrainBrainScreen extends StatelessWidget {
  const TrainBrainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CappedScaffold(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            StoreHeader(
              showBack: true,
              theme: trainTheme,
              onBack: () => Navigator.of(context).pop(),
              onSettings: () => pushScreen(context, const SettingsScreen()),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(22.w, 30.h, 22.w, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          FadeSlideIn(
                            delay: const Duration(milliseconds: 40),
                            child: Text(
                              'Train Your Brain',
                              style: AppTextStyles.heading,
                            ),
                          ),
                          SizedBox(height: 14.h),
                          FadeSlideIn(
                            delay: const Duration(milliseconds: 70),
                            child: Text(
                              'Visual puzzles with calm focus and\nsimple number logic.',
                              style: AppTextStyles.body,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(22.w, 76.h, 22.w, 36.h),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((
                        BuildContext context,
                        int index,
                      ) {
                        final game = trainGames[index];
                        return StaggeredEntry(
                          index: index,
                          baseDelay: const Duration(milliseconds: 110),
                          child: SubGameCard(
                            game: game,
                            onTap: () => pushScreen(
                              context,
                              LevelSelectScreen(game: game),
                            ),
                          ),
                        );
                      }, childCount: trainGames.length),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 22.w,
                        mainAxisSpacing: 44.h,
                        childAspectRatio: 0.66,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
