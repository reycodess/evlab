import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';

/// ===============================================================
/// EV-LAB PROGRESS SERVICE
/// ===============================================================
///
/// Central system for tracking the player's learning progress.
///
/// Tracks:
/// • XP
/// • Level
/// • Completed lessons
/// • Completed quizzes
/// • Quiz score
/// • Completed experiments
/// • Badges
///
/// Learner milestones are stored locally after each change so learning can
/// continue across app sessions without an account or connection.
/// ===============================================================

class ProgressService extends ChangeNotifier {
  // =============================================================
  // SINGLETON
  // =============================================================

  static final ProgressService instance =
  ProgressService._internal();

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    if (_isLoaded) return;
    try {
      final data = await DatabaseHelper.instance.getLearnerProgress();
      _xp = (data['xp'] as num?)?.toInt() ?? 0;
      _completedLessons = (data['completed_lessons'] as num?)?.toInt() ?? 0;
      _completedQuizzes = (data['completed_quizzes'] as num?)?.toInt() ?? 0;
      _quizCorrectAnswers = (data['quiz_correct_answers'] as num?)?.toInt() ?? 0;
      _completedExperiments = (data['completed_experiments'] as num?)?.toInt() ?? 0;
      _completedThreeRScenarios = (data['completed_three_rs'] as num?)?.toInt() ?? 0;
      _completedLessonNumbers
        ..clear()
        ..addAll((jsonDecode(data['lesson_numbers'] as String? ?? '[]') as List)
            .whereType<num>().map((value) => value.toInt()));
      _earnedBadges
        ..clear()
        ..addAll((jsonDecode(data['badges'] as String? ?? '[]') as List)
            .whereType<String>());
      _checkBadges();
    } catch (error) {
      debugPrint('EV-LAB progress restore failed: $error');
    }
    _isLoaded = true;
    notifyListeners();
  }

  void _save() {
    DatabaseHelper.instance.saveLearnerProgress({
      'xp': _xp,
      'completed_lessons': _completedLessons,
      'completed_quizzes': _completedQuizzes,
      'quiz_correct_answers': _quizCorrectAnswers,
      'completed_experiments': _completedExperiments,
      'completed_three_rs': _completedThreeRScenarios,
      'lesson_numbers': jsonEncode(_completedLessonNumbers.toList()),
      'badges': jsonEncode(_earnedBadges.toList()),
    }).catchError((Object error) {
      debugPrint('EV-LAB progress save failed: $error');
    });
  }

  ProgressService._internal();

  // =============================================================
  // PLAYER DATA
  // =============================================================

  int _xp = 0;

  int _completedLessons = 0;

  int _completedQuizzes = 0;

  int _quizCorrectAnswers = 0;

  int _completedExperiments = 0;

  int _completedThreeRScenarios = 0;

  final Set<int> _completedLessonNumbers = {};

  final Set<String> _earnedBadges = {};

  // =============================================================
  // GETTERS
  // =============================================================

  int get xp => _xp;

  int get completedLessons => _completedLessons;

  int get completedQuizzes => _completedQuizzes;

  int get quizCorrectAnswers => _quizCorrectAnswers;

  int get completedExperiments => _completedExperiments;

  int get completedThreeRScenarios => _completedThreeRScenarios;

  Set<int> get completedLessonNumbers =>
      Set.unmodifiable(_completedLessonNumbers);

  Set<String> get earnedBadges =>
      Set.unmodifiable(_earnedBadges);

  // =============================================================
  // LEVEL SYSTEM
  // =============================================================

  /// Every level requires 400 XP.
  ///
  /// Level 1:
  /// 0–399 XP
  ///
  /// Level 2:
  /// 400–799 XP
  ///
  /// Level 3:
  /// 800–1199 XP
  ///
  /// and so on.
  int get level {
    return (_xp ~/ 400) + 1;
  }

  /// XP earned inside the current level.
  int get currentLevelXP {
    return _xp % 400;
  }

  /// XP required to reach the next level.
  int get xpForNextLevel {
    return 400;
  }

  /// Progress from 0.0 to 1.0 for the current level.
  double get levelProgress {
    return currentLevelXP / xpForNextLevel;
  }

  // =============================================================
  // PLAYER RANK
  // =============================================================

  String get rank {
    if (level >= 10) {
      return 'Master Enzyme Scientist';
    }

    if (level >= 7) {
      return 'Enzyme Specialist';
    }

    if (level >= 5) {
      return 'Research Scientist';
    }

    if (level >= 3) {
      return 'Enzyme Explorer';
    }

    return 'Young Scientist';
  }

  // =============================================================
  // ADD XP
  // =============================================================

  void addXP(int amount) {
    if (amount <= 0) {
      return;
    }

    _xp += amount;

    _checkBadges();
    _save();
    notifyListeners();
  }

  // =============================================================
  // LESSON SYSTEM
  // =============================================================

  bool isLessonCompleted(int lessonNumber) {
    return _completedLessonNumbers.contains(lessonNumber);
  }

  void completeLesson(int lessonNumber) {
    if (_completedLessonNumbers.contains(lessonNumber)) {
      return;
    }

    _completedLessonNumbers.add(lessonNumber);

    _completedLessons++;

    // Reward for completing a lesson.
    addXP(50);

    _checkBadges();

    notifyListeners();
  }

  // =============================================================
  // QUIZ SYSTEM
  // =============================================================

  void completeQuiz({
    required int correctAnswers,
    required int totalQuestions,
  }) {
    if (totalQuestions <= 0) {
      return;
    }

    _completedQuizzes++;

    _quizCorrectAnswers += correctAnswers;

    // Base reward.
    int reward = 25;

    // Additional reward based on performance.
    final percentage =
        correctAnswers / totalQuestions;

    if (percentage >= 1.0) {
      reward += 75;
    } else if (percentage >= 0.80) {
      reward += 50;
    } else if (percentage >= 0.60) {
      reward += 25;
    }

    addXP(reward);

    _checkBadges();

    notifyListeners();
  }

  // =============================================================
  // EXPERIMENT SYSTEM
  // =============================================================

  void completeExperiment() {
    _completedExperiments++;

    // Reward for performing an experiment.
    addXP(40);

    _checkBadges();

    notifyListeners();
  }


  void completeThreeRScenario({required bool correct}) {
    _completedThreeRScenarios++;
    addXP(correct ? 40 : 15);
    _checkBadges();
    notifyListeners();
  }

  // =============================================================
  // BADGE SYSTEM
  // =============================================================

  bool hasBadge(String badgeId) {
    return _earnedBadges.contains(badgeId);
  }

  void _checkBadges() {
    // -----------------------------------------------------------
    // FIRST STEPS
    // -----------------------------------------------------------

    if (_completedLessons >= 1) {
      _earnedBadges.add('first_lesson');
    }

    // -----------------------------------------------------------
    // KNOWLEDGE SEEKER
    // -----------------------------------------------------------

    if (_completedLessons >= 3) {
      _earnedBadges.add('knowledge_seeker');
    }

    // -----------------------------------------------------------
    // ENZYME SCHOLAR
    // -----------------------------------------------------------

    if (_completedLessons >= 8) {
      _earnedBadges.add('enzyme_scholar');
    }

    // -----------------------------------------------------------
    // QUIZ BEGINNER
    // -----------------------------------------------------------

    if (_completedQuizzes >= 1) {
      _earnedBadges.add('quiz_beginner');
    }

    // -----------------------------------------------------------
    // QUIZ MASTER
    // -----------------------------------------------------------

    if (_completedQuizzes >= 5) {
      _earnedBadges.add('quiz_master');
    }

    // -----------------------------------------------------------
    // PERFECT SCORE
    // -----------------------------------------------------------

    if (_quizCorrectAnswers > 0 &&
        _completedQuizzes > 0) {
      // This badge will be awarded when a perfect quiz
      // is completed. The actual perfect-score logic
      // can be expanded later.
    }

    // -----------------------------------------------------------
    // FIRST EXPERIMENT
    // -----------------------------------------------------------

    if (_completedExperiments >= 1) {
      _earnedBadges.add('first_experiment');
    }

    // -----------------------------------------------------------
    // EXPERIMENT SCIENTIST
    // -----------------------------------------------------------

    if (_completedExperiments >= 5) {
      _earnedBadges.add('experiment_scientist');
    }

    if (_completedThreeRScenarios >= 3) {
      _earnedBadges.add('three_rs_champion');
    }

    // -----------------------------------------------------------
    // XP BADGES
    // -----------------------------------------------------------

    if (_xp >= 500) {
      _earnedBadges.add('rising_scientist');
    }

    if (_xp >= 1000) {
      _earnedBadges.add('enzyme_expert');
    }
  }

  // =============================================================
  // BADGE INFORMATION
  // =============================================================

  static const Map<String, Map<String, dynamic>>
  badgeData = {
    'first_lesson': {
      'name': 'First Discovery',
      'description':
      'Complete your first enzyme lesson.',
      'icon': '🔬',
      'xp': 0,
    },

    'knowledge_seeker': {
      'name': 'Knowledge Seeker',
      'description':
      'Complete 3 enzyme lessons.',
      'icon': '📚',
      'xp': 0,
    },

    'enzyme_scholar': {
      'name': 'Enzyme Scholar',
      'description':
      'Complete all 8 core enzyme lessons.',
      'icon': '🎓',
      'xp': 0,
    },

    'quiz_beginner': {
      'name': 'Quiz Starter',
      'description':
      'Complete your first enzyme quiz.',
      'icon': '🧠',
      'xp': 0,
    },

    'quiz_master': {
      'name': 'Quiz Master',
      'description':
      'Complete 5 enzyme quizzes.',
      'icon': '🏆',
      'xp': 0,
    },

    'first_experiment': {
      'name': 'Lab Apprentice',
      'description':
      'Complete your first virtual experiment.',
      'icon': '🧪',
      'xp': 0,
    },

    'three_rs_champion': {
      'name': '3Rs Champion',
      'description': 'Complete all three responsible-research scenarios.',
      'icon': '🌱',
      'xp': 0,
    },

    'experiment_scientist': {
      'name': 'Experiment Scientist',
      'description':
      'Complete 5 virtual experiments.',
      'icon': '⚗️',
      'xp': 0,
    },

    'rising_scientist': {
      'name': 'Rising Scientist',
      'description':
      'Earn 500 XP.',
      'icon': '⭐',
      'xp': 0,
    },

    'enzyme_expert': {
      'name': 'Enzyme Expert',
      'description':
      'Earn 1,000 XP.',
      'icon': '🧬',
      'xp': 0,
    },
  };

  // =============================================================
  // BADGE COUNT
  // =============================================================

  int get badgeCount {
    return _earnedBadges.length;
  }

  // =============================================================
  // RESET PROGRESS
  // =============================================================
  //
  // Useful during development/testing.
  // We can later remove this from the user-facing app.
  // =============================================================

  void resetProgress() {
    _xp = 0;

    _completedLessons = 0;

    _completedQuizzes = 0;

    _quizCorrectAnswers = 0;

    _completedExperiments = 0;

    _completedThreeRScenarios = 0;

    _completedLessonNumbers.clear();

    _earnedBadges.clear();
    _save();
    notifyListeners();
  }
}
