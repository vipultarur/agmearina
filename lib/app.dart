import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/state/app_state.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/screens/home_screen.dart';

class MathspazzelApp extends StatefulWidget {
  final SharedPreferences prefs;

  const MathspazzelApp({super.key, required this.prefs});

  @override
  State<MathspazzelApp> createState() => _MathspazzelAppState();
}

class _MathspazzelAppState extends State<MathspazzelApp> {
  late final AppState _state;

  @override
  void initState() {
    super.initState();
    _state = AppState(widget.prefs);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,
      child: const HomeScreen(),
      builder: (BuildContext context, Widget? child) {
        return AppScope(
          appState: _state,
          child: MaterialApp(
            title: 'Math Spazzel',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            home: child,
          ),
        );
      },
    );
  }
}
