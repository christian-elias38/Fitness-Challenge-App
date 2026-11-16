import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/challenges/presentation/bloc/challenge_bloc.dart';
import 'features/challenges/presentation/bloc/challenge_event.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FitChallengeApp());
}

class FitChallengeApp extends StatelessWidget {
  const FitChallengeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(),
        ),
        BlocProvider<ChallengeBloc>(
          create: (_) => ChallengeBloc()..add(FetchChallenges()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'FitChallenge',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
