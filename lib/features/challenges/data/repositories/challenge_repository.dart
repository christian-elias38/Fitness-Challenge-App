import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/challenge_model.dart';
import '../services/challenge_service.dart';

class ChallengeRepository {
  final ChallengeService _service = ChallengeService();
  static const String _storageKey = 'local_challenges_data_v1';

  List<ChallengeModel> _cachedChallenges = [];

  static final List<ChallengeModel> _defaultChallenges = [
    const ChallengeModel(
      id: 'c1',
      title: '30 Day Fitness Challenge',
      difficulty: 'Intermediate',
      duration: '30 Days',
      totalDays: 30,
      currentDay: 18,
      completed: false,
      isJoined: true,
      description:
          'Build healthy habits, get stronger, and feel better in just 30 days. This challenge includes daily workouts, nutrition tips and progress tracking.',
      category: 'Fitness',
      participantsCount: 120,
      status: 'Active',
      goals: [
        'Complete 30 workouts',
        'Stay consistent',
        'Track your progress',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?q=80&w=800&auto=format&fit=crop',
    ),
    const ChallengeModel(
      id: 'c2',
      title: 'Step Challenge',
      difficulty: 'Beginner',
      duration: '14 Days',
      totalDays: 14,
      currentDay: 5,
      completed: false,
      isJoined: false,
      description:
          'Hit 10,000 steps every day for 2 weeks. Boost cardiovascular endurance, burn calories, and build high energy daily movement habits.',
      category: 'Health',
      participantsCount: 85,
      status: 'Active',
      goals: [
        '10,000 steps per day',
        'Daily morning walk',
        'Log outdoor activity',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?q=80&w=800&auto=format&fit=crop',
    ),
    const ChallengeModel(
      id: 'c3',
      title: 'Strength Builder',
      difficulty: 'Intermediate',
      duration: '21 Days',
      totalDays: 21,
      currentDay: 12,
      completed: false,
      isJoined: false,
      description:
          'Progressive bodyweight and resistance training designed to tone muscles, enhance posture, and increase functional strength.',
      category: 'Strength',
      participantsCount: 56,
      status: 'Active',
      goals: [
        'Progressive overload sets',
        'Full body compound lifts',
        'Upper & core mastery',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=800&auto=format&fit=crop',
    ),
    const ChallengeModel(
      id: 'c4',
      title: 'Morning Cardio Blitz',
      difficulty: 'Beginner',
      duration: '7 Days',
      totalDays: 7,
      currentDay: 7,
      completed: true,
      isJoined: true,
      description:
          'Quick 20-minute morning metabolic conditioning workouts to fire up your fat burn and keep your energy soaring all day.',
      category: 'Cardio',
      participantsCount: 94,
      status: 'Completed',
      goals: [
        '7 consecutive sunrise workouts',
        'Interval heart-rate spikes',
        'Hydration streak',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1434596922112-19c563067271?q=80&w=800&auto=format&fit=crop',
    ),
    const ChallengeModel(
      id: 'c5',
      title: 'Core & Abs Crusher',
      difficulty: 'Advanced',
      duration: '15 Days',
      totalDays: 15,
      currentDay: 0,
      completed: false,
      isJoined: false,
      description:
          'Target your core with intense plank variations, hollow body holds, and rotational power movements for sculpted midsection strength.',
      category: 'Fitness',
      participantsCount: 110,
      status: 'Upcoming',
      goals: [
        'Targeted abdominal circuits',
        'Isometric core holds',
        'Lower back resilience',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?q=80&w=800&auto=format&fit=crop',
    ),
    const ChallengeModel(
      id: 'c6',
      title: 'Mindful Recovery & Mobility',
      difficulty: 'Beginner',
      duration: '10 Days',
      totalDays: 10,
      currentDay: 0,
      completed: false,
      isJoined: false,
      description:
          'Gentle dynamic stretching, yoga flow, and breathing sessions to reduce soreness, de-stress, and optimize muscle recovery.',
      category: 'Health',
      participantsCount: 64,
      status: 'Upcoming',
      goals: [
        'Daily 15-min stretch routine',
        'Deep breathwork sessions',
        'Joint mobility checks',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=800&auto=format&fit=crop',
    ),
  ];

  Future<List<ChallengeModel>> fetchChallenges() async {
    // 1. Try reading from SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedJson = prefs.getString(_storageKey);
      if (storedJson != null && storedJson.isNotEmpty) {
        final List<dynamic> list = jsonDecode(storedJson);
        _cachedChallenges = list.map((e) => ChallengeModel.fromJson(e)).toList();
        if (_cachedChallenges.isNotEmpty) {
          return _cachedChallenges;
        }
      }
    } catch (_) {}

    // 2. Try remote API service if configured
    try {
      final remote = await _service.fetchChallenges();
      if (remote.isNotEmpty) {
        _cachedChallenges = remote;
        _saveToLocal();
        return _cachedChallenges;
      }
    } catch (_) {}

    // 3. Fallback to default high-fidelity mock list matching screenshots
    _cachedChallenges = List.from(_defaultChallenges);
    _saveToLocal();
    return _cachedChallenges;
  }

  Future<ChallengeModel> addChallenge(ChallengeModel challenge) async {
    final newChallenge = challenge.copyWith(
      id: challenge.id.isEmpty
          ? 'c_${DateTime.now().millisecondsSinceEpoch}'
          : challenge.id,
      participantsCount: 1,
      isJoined: true,
      currentDay: 0,
    );

    // Try service if reachable
    try {
      await _service.addChallenge(newChallenge);
    } catch (_) {}

    _cachedChallenges.insert(0, newChallenge);
    await _saveToLocal();
    return newChallenge;
  }

  Future<ChallengeModel> updateChallenge(ChallengeModel challenge) async {
    try {
      await _service.updateChallenge(challenge);
    } catch (_) {}

    final index = _cachedChallenges.indexWhere((c) => c.id == challenge.id);
    if (index != -1) {
      _cachedChallenges[index] = challenge;
    } else {
      _cachedChallenges.add(challenge);
    }
    await _saveToLocal();
    return challenge;
  }

  Future<void> deleteChallenge(String id) async {
    try {
      await _service.deleteChallenge(id);
    } catch (_) {}

    _cachedChallenges.removeWhere((c) => c.id == id);
    await _saveToLocal();
  }

  Future<ChallengeModel> toggleJoinChallenge(String id) async {
    final index = _cachedChallenges.indexWhere((c) => c.id == id);
    if (index != -1) {
      final item = _cachedChallenges[index];
      final newJoined = !item.isJoined;
      final updated = item.copyWith(
        isJoined: newJoined,
        participantsCount: newJoined
            ? item.participantsCount + 1
            : (item.participantsCount > 0 ? item.participantsCount - 1 : 0),
        currentDay: newJoined && item.currentDay == 0 ? 1 : item.currentDay,
      );
      _cachedChallenges[index] = updated;
      await _saveToLocal();
      return updated;
    }
    throw Exception('Challenge not found');
  }

  Future<ChallengeModel> advanceProgress(String id) async {
    final index = _cachedChallenges.indexWhere((c) => c.id == id);
    if (index != -1) {
      final item = _cachedChallenges[index];
      final nextDay = (item.currentDay + 1).clamp(0, item.totalDays);
      final isNowCompleted = nextDay >= item.totalDays;
      final updated = item.copyWith(
        currentDay: nextDay,
        completed: isNowCompleted,
        status: isNowCompleted ? 'Completed' : item.status,
      );
      _cachedChallenges[index] = updated;
      await _saveToLocal();
      return updated;
    }
    throw Exception('Challenge not found');
  }

  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _cachedChallenges.map((e) => e.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(list));
    } catch (_) {}
  }
}
