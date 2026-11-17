import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class FitChallengeLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final bool showTagline;
  final bool isDark;

  const FitChallengeLogo({
    super.key,
    this.iconSize = 44,
    this.fontSize = 26,
    this.showTagline = true,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Custom Stylized Dynamic Runner Icon
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryNeon, AppColors.primaryNeonDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(iconSize * 0.3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryNeon.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.directions_run_rounded,
                size: iconSize * 0.65,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'FitChallenge',
              style: GoogleFonts.plusJakartaSans(
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        if (showTagline) ...[
          const SizedBox(height: 8),
          Text(
            'Better Habits. Stronger You.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: fontSize * 0.45,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class TopographicWavePainter extends CustomPainter {
  final Color waveColor;
  final double opacity;

  TopographicWavePainter({
    required this.waveColor,
    this.opacity = 0.15,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final w = size.width;
    final h = size.height;

    for (int i = 0; i < 5; i++) {
      final path = Path();
      final offset = i * 28.0;
      path.moveTo(0, h * 0.6 + offset);
      path.cubicTo(
        w * 0.25,
        h * 0.45 + offset - (i * 10),
        w * 0.55,
        h * 0.75 + offset + (i * 5),
        w,
        h * 0.5 + offset,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

