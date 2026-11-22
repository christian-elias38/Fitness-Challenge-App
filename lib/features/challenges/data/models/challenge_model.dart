import 'package:equatable/equatable.dart';

class ChallengeModel extends Equatable {
  final String id;
  final String title;
  final String difficulty;
  final String duration;
  final int totalDays;
  final int currentDay;
  final bool completed;
  final bool isJoined;
  final String description;
  final String category;
  final int participantsCount;
  final String status; // 'Active', 'Upcoming', 'Completed'
  final List<String> goals;
  final String imageUrl;

  const ChallengeModel({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.duration,
    this.totalDays = 30,
    this.currentDay = 0,
    required this.completed,
    this.isJoined = false,
    required this.description,
    this.category = 'Fitness',
    this.participantsCount = 120,
    this.status = 'Active',
    this.goals = const [
      'Complete 30 workouts',
      'Stay consistent',
      'Track your progress',
    ],
    this.imageUrl = '',
  });

  double get progress {
    if (totalDays <= 0) return 0.0;
    if (completed) return 1.0;
    return (currentDay / totalDays).clamp(0.0, 1.0);
  }

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    // Parse duration integer if available
    int days = 30;
    final durStr = (json['duration'] ?? '').toString();
    final match = RegExp(r'\d+').firstMatch(durStr);
    if (match != null) {
      days = int.tryParse(match.group(0) ?? '30') ?? 30;
    }

    return ChallengeModel(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? 'Fitness Challenge',
      difficulty: json['difficulty'] ?? 'Intermediate',
      duration: json['duration'] ?? '$days Days',
      totalDays: json['totalDays'] is int ? json['totalDays'] : days,
      currentDay: json['currentDay'] is int ? json['currentDay'] : (json['completed'] == true ? days : 0),
      completed: json['completed'] ?? false,
      isJoined: json['isJoined'] ?? false,
      description: json['description'] ?? 'Build healthy habits and achieve your fitness goals.',
      category: json['category'] ?? 'Fitness',
      participantsCount: json['participantsCount'] is int ? json['participantsCount'] : 120,
      status: json['status'] ?? 'Active',
      goals: json['goals'] is List
          ? (json['goals'] as List).map((e) => e.toString()).toList()
          : const [
              'Complete 30 workouts',
              'Stay consistent',
              'Track your progress',
            ],
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'difficulty': difficulty,
      'duration': duration,
      'totalDays': totalDays,
      'currentDay': currentDay,
      'completed': completed,
      'isJoined': isJoined,
      'description': description,
      'category': category,
      'participantsCount': participantsCount,
      'status': status,
      'goals': goals,
      'imageUrl': imageUrl,
    };
  }

  ChallengeModel copyWith({
    String? id,
    String? title,
    String? difficulty,
    String? duration,
    int? totalDays,
    int? currentDay,
    bool? completed,
    bool? isJoined,
    String? description,
    String? category,
    int? participantsCount,
    String? status,
    List<String>? goals,
    String? imageUrl,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      difficulty: difficulty ?? this.difficulty,
      duration: duration ?? this.duration,
      totalDays: totalDays ?? this.totalDays,
      currentDay: currentDay ?? this.currentDay,
      completed: completed ?? this.completed,
      isJoined: isJoined ?? this.isJoined,
      description: description ?? this.description,
      category: category ?? this.category,
      participantsCount: participantsCount ?? this.participantsCount,
      status: status ?? this.status,
      goals: goals ?? this.goals,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        difficulty,
        duration,
        totalDays,
        currentDay,
        completed,
        isJoined,
        description,
        category,
        participantsCount,
        status,
        goals,
        imageUrl,
      ];
}
