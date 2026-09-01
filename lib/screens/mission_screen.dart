import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'learning_hub_screen.dart';
import 'enzyme_quiz_screen.dart';
import 'progress_screen.dart';

class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final List<bool> completedMissions = List.filled(8, false);

  final List<MissionData> missions = const [
    MissionData(
      number: 1,
      title: 'Enzyme Recruit',
      description:
      'Discover what enzymes are, what they do, and why they are essential for life.',
      category: 'FOUNDATION',
      xp: 50,
      icon: Icons.biotech_rounded,
      color: EVLabColors.emerald,
      difficulty: 'Easy',
    ),
    MissionData(
      number: 2,
      title: 'Master of Shape',
      description:
      'Explore enzyme structure, active sites, and enzyme-substrate specificity.',
      category: 'STRUCTURE',
      xp: 75,
      icon: Icons.account_tree_rounded,
      color: EVLabColors.blue,
      difficulty: 'Easy',
    ),
    MissionData(
      number: 3,
      title: 'Reaction Accelerator',
      description:
      'Learn how enzymes lower activation energy and speed up chemical reactions.',
      category: 'CATALYSIS',
      xp: 100,
      icon: Icons.bolt_rounded,
      color: EVLabColors.orange,
      difficulty: 'Medium',
    ),
    MissionData(
      number: 4,
      title: 'Environment Expert',
      description:
      'Investigate how temperature and pH can change enzyme activity.',
      category: 'CONDITIONS',
      xp: 125,
      icon: Icons.thermostat_rounded,
      color: EVLabColors.cyan,
      difficulty: 'Medium',
    ),
    MissionData(
      number: 5,
      title: 'Substrate Scientist',
      description:
      'Explore substrate concentration and discover how it affects reaction rate.',
      category: 'KINETICS',
      xp: 125,
      icon: Icons.scatter_plot_rounded,
      color: EVLabColors.purple,
      difficulty: 'Medium',
    ),
    MissionData(
      number: 6,
      title: 'Inhibitor Hunter',
      description:
      'Learn how inhibitors affect enzymes and compare different inhibition mechanisms.',
      category: 'INHIBITION',
      xp: 150,
      icon: Icons.block_rounded,
      color: EVLabColors.pink,
      difficulty: 'Hard',
    ),
    MissionData(
      number: 7,
      title: 'Enzyme Classifier',
      description:
      'Discover the major enzyme classes and learn how enzymes are classified.',
      category: 'CLASSIFICATION',
      xp: 175,
      icon: Icons.category_rounded,
      color: EVLabColors.coral,
      difficulty: 'Hard',
    ),
    MissionData(
      number: 8,
      title: 'Real-World Biochemist',
      description:
      'Discover how enzymes are used in digestion, medicine, food, and biotechnology.',
      category: 'APPLICATION',
      xp: 200,
      icon: Icons.public_rounded,
      color: EVLabColors.emeraldDark,
      difficulty: 'Expert',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  int get completedCount {
    return completedMissions.where((value) => value).length;
  }

  int get earnedXP {
    int total = 0;

    for (int i = 0; i < missions.length; i++) {
      if (completedMissions[i]) {
        total += missions[i].xp;
      }
    }

    return total;
  }

  int get totalXP {
    return missions.fold(
      0,
          (sum, mission) => sum + mission.xp,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Missions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'My Progress',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProgressScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.emoji_events_rounded,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          18,
          10,
          18,
          30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(),

            const SizedBox(height: 20),

            _buildProgressSummary(),

            const SizedBox(height: 26),

            const Text(
              'Your Missions',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: EVLabColors.textDark,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Complete missions to earn XP and become an enzyme expert.',
              style: TextStyle(
                color: EVLabColors.textMedium,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            ...List.generate(
              missions.length,
                  (index) {
                return _animatedMissionCard(
                  missions[index],
                  index,
                );
              },
            ),

            const SizedBox(height: 10),

            _buildFinalReward(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        gradient: EVLabGradients.purple,
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: EVLabColors.purple.withValues(
              alpha: 0.22,
            ),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.18,
              ),
              borderRadius: BorderRadius.circular(21),
            ),
            child: const Icon(
              Icons.flag_rounded,
              color: Colors.white,
              size: 39,
            ),
          ),

          const SizedBox(width: 16),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EV-LAB MISSIONS',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.3,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Become an Enzyme Expert',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Learn • Complete • Level Up',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROGRESS SUMMARY
  // ============================================================

  Widget _buildProgressSummary() {
    final progress = completedMissions.isEmpty
        ? 0.0
        : completedCount / completedMissions.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: EVLabColors.yellow.withValues(
                    alpha: 0.18,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: EVLabColors.orange,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MISSION PROGRESS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: EVLabColors.textLight,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Keep going, scientist!',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: EVLabColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '$completedCount / ${missions.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: EVLabColors.purple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TweenAnimationBuilder<double>(
              tween: Tween(
                begin: 0,
                end: progress,
              ),
              duration: const Duration(
                milliseconds: 900,
              ),
              builder: (
                  context,
                  value,
                  child,
                  ) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 9,
                  backgroundColor:
                  const Color(0xFFE7ECF3),
                  color: EVLabColors.purple,
                );
              },
            ),
          ),

          const SizedBox(height: 9),

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$earnedXP XP earned',
                style: const TextStyle(
                  fontSize: 11,
                  color: EVLabColors.textMedium,
                ),
              ),
              Text(
                '$totalXP XP available',
                style: const TextStyle(
                  fontSize: 11,
                  color: EVLabColors.textMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ANIMATED MISSION
  // ============================================================

  Widget _animatedMissionCard(
      MissionData mission,
      int index,
      ) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final start = (index * 0.08).clamp(0.0, 0.7);
        final animation = CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            start,
            1.0,
            curve: Curves.easeOutCubic,
          ),
        );

        return Transform.translate(
          offset: Offset(
            0,
            25 * (1 - animation.value),
          ),
          child: Opacity(
            opacity: animation.value,
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 12,
              ),
              child: _buildMissionCard(
                mission,
                index,
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // MISSION CARD
  // ============================================================

  Widget _buildMissionCard(
      MissionData mission,
      int index,
      ) {
    final completed = completedMissions[index];

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          _openMission(mission, index);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: completed
                  ? EVLabColors.success.withValues(
                alpha: 0.35,
              )
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 63,
                    height: 63,
                    decoration: BoxDecoration(
                      color: mission.color.withValues(
                        alpha: 0.12,
                      ),
                      borderRadius:
                      BorderRadius.circular(19),
                    ),
                    child: Icon(
                      mission.icon,
                      color: mission.color,
                      size: 31,
                    ),
                  ),

                  if (completed)
                    Positioned(
                      right: -3,
                      top: -3,
                      child: Container(
                        width: 23,
                        height: 23,
                        decoration: const BoxDecoration(
                          color: EVLabColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'MISSION ${mission.number}',
                          style: TextStyle(
                            color: mission.color,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const Spacer(),
                        _buildDifficulty(
                          mission.difficulty,
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      mission.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: EVLabColors.textDark,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      mission.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: EVLabColors.textMedium,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 9),

                    Row(
                      children: [
                        Icon(
                          Icons.stars_rounded,
                          size: 15,
                          color: EVLabColors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${mission.xp} XP',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: EVLabColors.orange,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          mission.category,
                          style: const TextStyle(
                            fontSize: 9,
                            color: EVLabColors.textLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                completed
                    ? Icons.check_circle_rounded
                    : Icons.arrow_forward_ios_rounded,
                color: completed
                    ? EVLabColors.success
                    : mission.color,
                size: completed ? 24 : 17,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DIFFICULTY
  // ============================================================

  Widget _buildDifficulty(String difficulty) {
    Color color;

    switch (difficulty) {
      case 'Easy':
        color = EVLabColors.success;
        break;
      case 'Medium':
        color = EVLabColors.orange;
        break;
      case 'Hard':
        color = EVLabColors.coral;
        break;
      default:
        color = EVLabColors.purple;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  // ============================================================
  // OPEN MISSION
  // ============================================================

  void _openMission(
      MissionData mission,
      int index,
      ) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LearningHubScreen(),
        ),
      );
      return;
    }

    if (index == 3 || index == 4 || index == 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${mission.title} is connected to the Virtual Laboratory.',
          ),
          action: SnackBarAction(
            label: 'OPEN',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProgressScreen(),
                ),
              );
            },
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EnzymeQuizScreen(),
      ),
    );
  }

  // ============================================================
  // FINAL REWARD
  // ============================================================

  Widget _buildFinalReward() {
    final allComplete = completedCount == missions.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: allComplete
            ? EVLabGradients.primary
            : EVLabGradients.dark,
        borderRadius: BorderRadius.circular(23),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.14,
              ),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(
              allComplete
                  ? Icons.workspace_premium_rounded
                  : Icons.lock_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  allComplete
                      ? 'MASTER SCIENTIST'
                      : 'FINAL REWARD',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  allComplete
                      ? 'You mastered enzyme science!'
                      : 'Complete every mission to unlock.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// MISSION MODEL
// ================================================================

class MissionData {
  final int number;
  final String title;
  final String description;
  final String category;
  final int xp;
  final IconData icon;
  final Color color;
  final String difficulty;

  const MissionData({
    required this.number,
    required this.title,
    required this.description,
    required this.category,
    required this.xp,
    required this.icon,
    required this.color,
    required this.difficulty,
  });
}