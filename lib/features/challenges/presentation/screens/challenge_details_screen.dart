import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../data/models/challenge_model.dart';
import '../bloc/challenge_bloc.dart';
import '../bloc/challenge_event.dart';
import '../bloc/challenge_state.dart';
import 'create_edit_challenge_screen.dart';

class ChallengeDetailsScreen extends StatefulWidget {
  final ChallengeModel challenge;

  const ChallengeDetailsScreen({
    super.key,
    required this.challenge,
  });

  @override
  State<ChallengeDetailsScreen> createState() => _ChallengeDetailsScreenState();
}

class _ChallengeDetailsScreenState extends State<ChallengeDetailsScreen> {
  bool _isBookmarked = false;
  final Set<int> _checkedGoals = {0, 1};

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();
    final isDark = themeCubit.isDark;

    return BlocBuilder<ChallengeBloc, ChallengeState>(
      builder: (context, state) {
        ChallengeModel current = widget.challenge;
        if (state is ChallengeLoaded) {
          final found = state.challenges.where((c) => c.id == widget.challenge.id);
          if (found.isNotEmpty) {
            current = found.first;
          }
        }

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          body: Stack(
            children: [
              // Scrollable Details
              CustomScrollView(
                slivers: [
                  // Hero Image App Bar
                  SliverAppBar(
                    expandedHeight: 280,
                    pinned: true,
                    leading: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withValues(alpha: 0.5),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withValues(alpha: 0.5),
                          child: IconButton(
                            icon: Icon(
                              _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                              color: _isBookmarked ? AppColors.primaryNeon : Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() => _isBookmarked = !_isBookmarked);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(_isBookmarked ? 'Saved to bookmarks' : 'Removed from bookmarks'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withValues(alpha: 0.5),
                          child: IconButton(
                            icon: const Icon(Icons.share_outlined, color: Colors.white, size: 20),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Challenge link copied to clipboard!')),
                              );
                            },
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: CircleAvatar(
                          backgroundColor: Colors.black.withValues(alpha: 0.5),
                          child: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 20),
                        ),
                        color: isDark ? AppColors.darkCard : Colors.white,
                        onSelected: (val) {
                          if (val == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CreateEditChallengeScreen(challenge: current),
                              ),
                            );
                          } else if (val == 'delete') {
                            _confirmDelete(context, current);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit_outlined, size: 18),
                                const SizedBox(width: 10),
                                Text('Edit Challenge', style: GoogleFonts.plusJakartaSans()),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                const SizedBox(width: 10),
                                Text(
                                  'Delete Challenge',
                                  style: GoogleFonts.plusJakartaSans(color: AppColors.error),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            current.imageUrl.isNotEmpty
                                ? current.imageUrl
                                : 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?q=80&w=800&auto=format&fit=crop',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: isDark ? AppColors.darkCard : Colors.grey.shade300,
                              child: const Icon(Icons.fitness_center_rounded, size: 60, color: AppColors.primaryNeon),
                            ),
                          ),
                          // Subtle dark gradient overlay
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.6),
                                  Colors.transparent,
                                  isDark ? AppColors.darkBackground : AppColors.lightBackground,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: const [0.0, 0.45, 1.0],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Challenge Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            current.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: isDark ? Colors.white : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Badges: [Fitness] [30 Days] [Intermediate]
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildPillBadge(current.category, AppColors.primaryNeon, isDark),
                              _buildPillBadge(current.duration, isDark ? AppColors.darkCard : AppColors.lightSurface, isDark),
                              _buildPillBadge(current.difficulty, isDark ? AppColors.darkCard : AppColors.lightSurface, isDark),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Description
                          Text(
                            current.description,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5,
                              height: 1.55,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 26),

                          // Goals Section
                          Text(
                            'Goals',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(current.goals.length, (idx) {
                            final goal = current.goals[idx];
                            final isDone = _checkedGoals.contains(idx);

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isDone) {
                                    _checkedGoals.remove(idx);
                                  } else {
                                    _checkedGoals.add(idx);
                                  }
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkCard : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: isDone ? AppColors.primaryNeon : Colors.transparent,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isDone
                                              ? AppColors.primaryNeon
                                              : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                                          width: 1.8,
                                        ),
                                      ),
                                      child: isDone
                                          ? const Icon(Icons.check, size: 16, color: Colors.black)
                                          : null,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        goal,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                          decoration: isDone ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 26),

                          // Participants Row
                          Text(
                            'Participants',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${current.participantsCount}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Overlapping Avatar Stack
                                SizedBox(
                                  width: 110,
                                  height: 38,
                                  child: Stack(
                                    children: [
                                      _buildAvatar('https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=150', 0),
                                      _buildAvatar('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=150', 22),
                                      _buildAvatar('https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150', 44),
                                      _buildAvatar('https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=150', 66),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '+${(current.participantsCount - 4).clamp(0, 9999)} more',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryNeon,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Sticky Bottom Action Button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.darkBackground : AppColors.lightBackground).withValues(alpha: 0.95),
                    border: Border(
                      top: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 1,
                      ),
                    ),
                  ),
                  child: current.isJoined
                      ? Row(
                          children: [
                            Expanded(
                              child: PrimaryButton(
                                text: 'Log Today\'s Workout (${current.currentDay}/${current.totalDays})',
                                icon: Icons.check_circle_outline_rounded,
                                onPressed: () {
                                  context.read<ChallengeBloc>().add(AdvanceChallengeProgress(current.id));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Great job! Workout logged for today! 🔥'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              tooltip: 'Leave Challenge',
                              style: IconButton.styleFrom(
                                backgroundColor: isDark ? AppColors.darkCard : Colors.white,
                                side: BorderSide(
                                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                ),
                              ),
                              onPressed: () {
                                context.read<ChallengeBloc>().add(ToggleJoinChallenge(current.id));
                              },
                              icon: const Icon(Icons.exit_to_app_rounded, color: AppColors.error),
                            ),
                          ],
                        )
                      : PrimaryButton(
                          text: 'Join Challenge',
                          onPressed: () {
                            context.read<ChallengeBloc>().add(ToggleJoinChallenge(current.id));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Welcome to "${current.title}"! Let\'s crush it! 🚀'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPillBadge(String label, Color color, bool isDark) {
    final isNeon = color == AppColors.primaryNeon;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: isNeon ? AppColors.primaryNeon : (isDark ? AppColors.darkCard : AppColors.lightSurface),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isNeon ? AppColors.primaryNeon : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isNeon ? Colors.black : (isDark ? Colors.white : AppColors.lightTextPrimary),
        ),
      ),
    );
  }

  Widget _buildAvatar(String url, double leftOffset) {
    return Positioned(
      left: leftOffset,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 2),
          image: DecorationImage(
            image: NetworkImage(url),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ChallengeModel current) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Challenge?'),
        content: Text('Are you sure you want to delete "${current.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ChallengeBloc>().add(DeleteChallenge(current.id));
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

