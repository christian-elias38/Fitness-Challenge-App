import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/app_states_view.dart';
import '../../data/models/challenge_model.dart';
import '../bloc/challenge_bloc.dart';
import '../bloc/challenge_event.dart';
import '../bloc/challenge_state.dart';
import 'challenge_details_screen.dart';
import 'create_edit_challenge_screen.dart';

class ChallengesListScreen extends StatefulWidget {
  const ChallengesListScreen({super.key});

  @override
  State<ChallengesListScreen> createState() => _ChallengesListScreenState();
}

class _ChallengesListScreenState extends State<ChallengesListScreen> {
  String _selectedStatus = 'Active'; // 'Active', 'Upcoming', 'Completed'
  String _selectedCategory = 'All'; // 'All', 'Fitness', 'Health', 'Beginner'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _statusTabs = ['Active', 'Upcoming', 'Completed'];
  final List<String> _categories = ['All', 'Fitness', 'Health', 'Beginner'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();
    final isDark = themeCubit.isDark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Challenges',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Create New Challenge',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primaryNeon,
              foregroundColor: Colors.black,
            ),
            icon: const Icon(Icons.add_rounded, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateEditChallengeScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Status Tabs: [Active] [Upcoming] [Completed]
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: _statusTabs.map((status) {
                    final isSelected = _selectedStatus == status;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedStatus = status),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? AppColors.primaryNeon : AppColors.primaryNeon)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            status,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected
                                  ? Colors.black
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search challenges...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Category Filter Pills: [All] [Fitness] [Health] [Beginner]
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryNeon
                              : (isDark ? AppColors.darkCard : AppColors.lightSurface),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryNeon
                                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          cat,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected
                                ? Colors.black
                                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Challenges List
            Expanded(
              child: BlocBuilder<ChallengeBloc, ChallengeState>(
                builder: (context, state) {
                  if (state is ChallengeLoading) {
                    return const AppLoadingView(
                      title: 'Loading challenges...',
                      subtitle: 'Please wait',
                    );
                  }

                  if (state is ChallengeError) {
                    return AppErrorView(
                      message: state.message,
                      onRetry: () => context.read<ChallengeBloc>().add(FetchChallenges()),
                    );
                  }

                  if (state is ChallengeLoaded) {
                    // Filter by status, category, search
                    final filtered = state.challenges.where((c) {
                      // Status match:
                      final statusMatch = _selectedStatus == 'Active'
                          ? (c.status == 'Active' || (c.isJoined && !c.completed))
                          : c.status.toLowerCase() == _selectedStatus.toLowerCase();

                      // Category match:
                      final catMatch = _selectedCategory == 'All' ||
                          c.category.toLowerCase() == _selectedCategory.toLowerCase() ||
                          c.difficulty.toLowerCase() == _selectedCategory.toLowerCase();

                      // Search query match:
                      final queryMatch = _searchQuery.isEmpty ||
                          c.title.toLowerCase().contains(_searchQuery) ||
                          c.description.toLowerCase().contains(_searchQuery);

                      return statusMatch && catMatch && queryMatch;
                    }).toList();

                    if (filtered.isEmpty) {
                      return AppEmptyView(
                        title: 'No challenges yet',
                        subtitle: 'Create or join a challenge to get started.',
                        buttonText: 'Create Challenge',
                        onAction: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateEditChallengeScreen(),
                            ),
                          );
                        },
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.primaryNeon,
                      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
                      onRefresh: () async {
                        context.read<ChallengeBloc>().add(FetchChallenges());
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return _buildChallengeCard(context, item, isDark);
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(
    BuildContext context,
    ChallengeModel challenge,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChallengeDetailsScreen(challenge: challenge),
            ),
          );
        },
        child: Row(
          children: [
            // Fitness thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 68,
                height: 68,
                color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                child: Image.network(
                  challenge.imageUrl.isNotEmpty
                      ? challenge.imageUrl
                      : 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?q=80&w=400&auto=format&fit=crop',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.fitness_center_rounded,
                    color: AppColors.primaryNeon,
                    size: 30,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info: Title + days/participants
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${challenge.duration} • ${challenge.participantsCount} participants',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Join / Joined Pill Button
            ElevatedButton(
              onPressed: () {
                context.read<ChallengeBloc>().add(ToggleJoinChallenge(challenge.id));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      challenge.isJoined
                          ? 'Left "${challenge.title}"'
                          : 'Joined "${challenge.title}"! Let\'s do this! 💪',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: challenge.isJoined
                    ? (isDark ? AppColors.darkSurface : AppColors.lightBorder)
                    : AppColors.primaryNeon,
                foregroundColor: challenge.isJoined
                    ? (isDark ? Colors.white : AppColors.lightTextPrimary)
                    : Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                minimumSize: const Size(60, 34),
              ),
              child: Text(
                challenge.isJoined ? 'Joined' : 'Join',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

