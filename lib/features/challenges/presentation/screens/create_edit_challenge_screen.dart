import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../data/models/challenge_model.dart';
import '../bloc/challenge_bloc.dart';
import '../bloc/challenge_event.dart';

class CreateEditChallengeScreen extends StatefulWidget {
  final ChallengeModel? challenge;

  const CreateEditChallengeScreen({super.key, this.challenge});

  @override
  State<CreateEditChallengeScreen> createState() =>
      _CreateEditChallengeScreenState();
}

class _CreateEditChallengeScreenState extends State<CreateEditChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late String _selectedCategory;
  late String _selectedDuration;
  late String _selectedDifficulty;
  bool _isLoading = false;

  final List<String> _categories = [
    'Fitness',
    'Strength',
    'Cardio',
    'Health',
    'Beginner',
    'Mindfulness',
  ];

  final List<String> _durations = [
    '7 Days',
    '14 Days',
    '21 Days',
    '30 Days',
    '60 Days',
  ];

  final List<String> _difficulties = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.challenge;
    _titleController = TextEditingController(text: c?.title ?? '');
    _descController = TextEditingController(text: c?.description ?? '');
    _selectedCategory = c?.category ?? 'Fitness';
    _selectedDuration = c?.duration ?? '30 Days';
    _selectedDifficulty = c?.difficulty ?? 'Intermediate';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveChallenge() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final match = RegExp(r'\d+').firstMatch(_selectedDuration);
    final days = int.tryParse(match?.group(0) ?? '30') ?? 30;

    final challenge = ChallengeModel(
      id: widget.challenge?.id ?? 'c_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      category: _selectedCategory,
      duration: _selectedDuration,
      totalDays: days,
      currentDay: widget.challenge?.currentDay ?? 0,
      difficulty: _selectedDifficulty,
      completed: widget.challenge?.completed ?? false,
      isJoined: widget.challenge?.isJoined ?? true,
      participantsCount: widget.challenge?.participantsCount ?? 1,
      imageUrl: widget.challenge?.imageUrl ??
          'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?q=80&w=800&auto=format&fit=crop',
    );

    if (widget.challenge == null) {
      context.read<ChallengeBloc>().add(AddChallenge(challenge));
    } else {
      context.read<ChallengeBloc>().add(UpdateChallenge(challenge));
    }

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.challenge == null
              ? 'Challenge created successfully! 🎉'
              : 'Challenge updated successfully!',
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.challenge != null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Challenge' : 'Create Challenge',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Field
                Text(
                  'Title',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
                  decoration: const InputDecoration(
                    hintText: 'e.g. 30 Day Fitness Challenge',
                  ),
                ),
                const SizedBox(height: 20),

                // Description Field
                Text(
                  'Description',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a description' : null,
                  decoration: const InputDecoration(
                    hintText: 'Tell people about your challenge...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 20),

                // Category Dropdown
                Text(
                  'Category',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: _selectedCategory,
                  items: _categories,
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                  isDark: isDark,
                ),
                const SizedBox(height: 20),

                // Duration Dropdown
                Text(
                  'Duration',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: _selectedDuration,
                  items: _durations,
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDuration = val);
                  },
                  isDark: isDark,
                ),
                const SizedBox(height: 20),

                // Difficulty Dropdown
                Text(
                  'Difficulty',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: _selectedDifficulty,
                  items: _difficulties,
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDifficulty = val);
                  },
                  isDark: isDark,
                ),
                const SizedBox(height: 36),

                // Submit Button
                PrimaryButton(
                  text: isEditing ? 'Save Changes' : 'Create Challenge',
                  isLoading: _isLoading,
                  onPressed: _saveChallenge,
                ),
                const SizedBox(height: 14),

                // Cancel Button
                PrimaryButton(
                  text: 'Cancel',
                  isOutlined: true,
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: isDark ? AppColors.darkCard : Colors.white,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

