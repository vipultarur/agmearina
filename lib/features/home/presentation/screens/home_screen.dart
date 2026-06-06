import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../common/widgets/app_motion.dart';
import '../../../../common/widgets/capped_scaffold.dart';
import '../../../../common/widgets/category_card.dart';
import '../../../../common/widgets/store_header.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/navigation.dart';
import '../../../games/data/game_catalog.dart';
import '../../../math_puzzle/presentation/screens/math_puzzle_screen.dart';
import '../../../memory_puzzle/presentation/screens/memory_puzzle_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../train_brain/presentation/screens/train_brain_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CappedScaffold(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(22.w, 18.h, 22.w, 0),
              child: FadeSlideIn(
                child: StoreHeader(
                  showBack: false,
                  padded: false,
                  onSettings: () =>
                      pushScreen(context, const SettingsScreen()),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(22.w, 58.h, 22.w, 34.h),
                children: <Widget>[
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 40),
                    child: Text('Math Games', style: AppTextStyles.homeTitle),
                  ),
                  SizedBox(height: 14.h),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 70),
                    child: Text(
                      'Train Your Brain, Improve Your Math\nSkill',
                      style: AppTextStyles.homeSubtitle,
                    ),
                  ),
                  SizedBox(height: 86.h),
                  StaggeredEntry(
                    index: 0,
                    baseDelay: const Duration(milliseconds: 120),
                    child: CategoryCard(
                      title: 'Math Puzzle',
                      theme: mathTheme,
                      onTap: () =>
                          pushScreen(context, const MathPuzzleScreen()),
                    ),
                  ),
                  SizedBox(height: 48.h),
                  StaggeredEntry(
                    index: 1,
                    baseDelay: const Duration(milliseconds: 120),
                    child: CategoryCard(
                      title: 'Memory Puzzle',
                      theme: memoryTheme,
                      onTap: () =>
                          pushScreen(context, const MemoryPuzzleScreen()),
                    ),
                  ),
                  SizedBox(height: 48.h),
                  StaggeredEntry(
                    index: 2,
                    baseDelay: const Duration(milliseconds: 120),
                    child: CategoryCard(
                      title: 'Train Your Brain',
                      theme: trainTheme,
                      onTap: () =>
                          pushScreen(context, const TrainBrainScreen()),
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
