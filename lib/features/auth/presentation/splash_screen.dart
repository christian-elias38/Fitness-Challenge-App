import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../core/widgets/brand_logo.dart';
import '../../../core/widgets/primary_button.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../../navigation/main_navigation_scaffold.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();
    final isDark = themeCubit.isDark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Stack(
        children: [
          // Background Topographic Waves
          Positioned.fill(
            child: CustomPaint(
              painter: TopographicWavePainter(
                waveColor: AppColors.primaryNeon,
                opacity: isDark ? 0.12 : 0.22,
              ),
            ),
          ),

          // Top right theme quick-toggle
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  tooltip: 'Toggle Theme',
                  style: IconButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.darkCard.withValues(alpha: 0.8)
                        : Colors.white.withValues(alpha: 0.9),
                    side: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  onPressed: () => themeCubit.toggleTheme(),
                  icon: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: isDark ? AppColors.primaryNeon : AppColors.lightTextPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),

          // Main Center Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Brand Logo & Tagline
                  FitChallengeLogo(
                    iconSize: 64,
                    fontSize: 34,
                    showTagline: true,
                    isDark: isDark,
                  ),

                  const Spacer(flex: 3),

                  // Action Buttons
                  PrimaryButton(
                    text: 'Get Started',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    text: 'Log In',
                    isOutlined: true,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      // Quick bypass directly to main dashboard for testing
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MainNavigationScaffold()),
                      );
                    },
                    child: Text(
                      'Explore as Guest',
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
