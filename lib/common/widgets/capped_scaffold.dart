import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

class CappedScaffold extends StatelessWidget {
  final Widget child;

  const CappedScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: AppDimensions.maxContentWidth),
          child: child,
        ),
      ),
    );
  }
}
