import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // ============================================================
  // PLAYER DATA
  // ============================================================

  final int currentXP = 280;
  final int nextLevelXP = 400;

  final int lessonsCompleted = 3;
  final int totalLessons = 8;

  final int quizzesCompleted = 2;
  final int experimentsCompleted = 4;

  final double quizAccuracy = 0.85;

  // ============================================================
  // INITIALIZE
  // ============================================================

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text(
          'My Progress',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: FadeTransition(
        opacity: _fadeAnimation,

        child: ScaleTransition(
          scale: _scaleAnimation,

          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),

            padding: const EdgeInsets.fromLTRB(
              18,
              10,
              18,
              35,
            ),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                // ==================================================
                // PLAYER HEADER
                // ==================================================

                _buildPlayerHeader(),

                const SizedBox(height: 20),

                // ==================================================
                // LEVEL PROGRESS
                // ==================================================

                _buildLevelCard(),

                const SizedBox(height: 24),

                // ==================================================
                // STATISTICS
                // ==================================================

                const Text(
                  'Your Statistics',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: EVLabColors.textDark,
                  ),
                ),

                const SizedBox(height: 13),

                _buildStatistics(),

                const SizedBox(height: 25),

                // ==================================================
                // LEARNING PROGRESS
                // ==================================================

                const Text(
                  'Learning Progress',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: EVLabColors.textDark,
                  ),
                ),

                const SizedBox(height: 13),

                _buildLearningProgress(),

                const SizedBox(height: 25),

                // ==================================================
                // ACHIEVEMENTS
                // ==================================================

                const Text(
                  'Achievements',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: EVLabColors.textDark,
                  ),
                ),

                const SizedBox(height: 13),

                _buildAchievements(),

                const SizedBox(height: 25),

                // ==================================================
                // NEXT MISSION
                // ==================================================

                _buildNextMission(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PLAYER HEADER
  // ============================================================

  Widget _buildPlayerHeader() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        gradient: EVLabGradients.primary,

        borderRadius:
        BorderRadius.circular(25),

        boxShadow: [
          BoxShadow(
            color: EVLabColors.emerald
                .withValues(alpha: 0.20),

            blurRadius: 18,

            offset:
            const Offset(0, 8),
          ),
        ],
      ),

      child: Row(
        children: [

          // AVATAR
          Container(
            width: 72,
            height: 72,

            decoration: BoxDecoration(
              color: Colors.white
                  .withValues(alpha: 0.18),

              shape: BoxShape.circle,

              border: Border.all(
                color: Colors.white
                    .withValues(alpha: 0.35),

                width: 2,
              ),
            ),

            child: const Icon(
              Icons.science_rounded,

              color: Colors.white,

              size: 38,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                const Text(
                  'LEVEL 2',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.3,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'Enzyme Explorer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [

                    const Icon(
                      Icons.stars_rounded,
                      color: EVLabColors.yellow,
                      size: 17,
                    ),

                    const SizedBox(width: 5),

                    Text(
                      '$currentXP XP earned',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LEVEL CARD
  // ============================================================

  Widget _buildLevelCard() {
    final progress =
        currentXP / nextLevelXP;

    final remaining =
        nextLevelXP - currentXP;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.04),

            blurRadius: 12,

            offset:
            const Offset(0, 5),
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
                  color: EVLabColors.yellow
                      .withValues(alpha: 0.16),

                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.emoji_events_rounded,

                  color:
                  EVLabColors.orange,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Text(
                      'LEVEL 2',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                        FontWeight.bold,
                        color:
                        EVLabColors.textLight,
                      ),
                    ),

                    SizedBox(height: 2),

                    Text(
                      'Enzyme Explorer',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                        FontWeight.bold,
                        color:
                        EVLabColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '$currentXP / $nextLevelXP XP',
                style: const TextStyle(
                  fontWeight:
                  FontWeight.bold,

                  fontSize: 12,

                  color:
                  EVLabColors.textMedium,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          ClipRRect(
            borderRadius:
            BorderRadius.circular(10),

            child: LinearProgressIndicator(
              value: progress,

              minHeight: 10,

              backgroundColor:
              const Color(0xFFE7ECF3),

              valueColor:
              const AlwaysStoppedAnimation(
                EVLabColors.orange,
              ),
            ),
          ),

          const SizedBox(height: 9),

          Align(
            alignment:
            Alignment.centerRight,

            child: Text(
              '$remaining XP until Level 3',
              style: const TextStyle(
                fontSize: 11,
                color:
                EVLabColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  Widget _buildStatistics() {
    return GridView.count(
      crossAxisCount: 2,

      shrinkWrap: true,

      physics:
      const NeverScrollableScrollPhysics(),

      crossAxisSpacing: 12,

      mainAxisSpacing: 12,

      childAspectRatio: 1.45,

      children: [

        _statCard(
          icon: Icons.menu_book_rounded,
          value: '$lessonsCompleted',
          label: 'Lessons Completed',
          color: EVLabColors.emerald,
        ),

        _statCard(
          icon: Icons.quiz_rounded,
          value: '$quizzesCompleted',
          label: 'Quizzes Completed',
          color: EVLabColors.purple,
        ),

        _statCard(
          icon: Icons.science_rounded,
          value: '$experimentsCompleted',
          label: 'Experiments',
          color: EVLabColors.orange,
        ),

        _statCard(
          icon: Icons.track_changes_rounded,
          value:
          '${(quizAccuracy * 100).round()}%',
          label: 'Quiz Accuracy',
          color: EVLabColors.cyan,
        ),
      ],
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding:
      const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(19),

        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.035),

            blurRadius: 10,

            offset:
            const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Container(
            width: 38,
            height: 38,

            decoration: BoxDecoration(
              color:
              color.withValues(
                alpha: 0.12,
              ),

              borderRadius:
              BorderRadius.circular(12),
            ),

            child: Icon(
              icon,
              color: color,
              size: 21,
            ),
          ),

          const Spacer(),

          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight:
              FontWeight.bold,
              color:
              EVLabColors.textDark,
            ),
          ),

          Text(
            label,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,

            style: const TextStyle(
              fontSize: 10,
              color:
              EVLabColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LEARNING PROGRESS
  // ============================================================

  Widget _buildLearningProgress() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(22),
      ),

      child: Column(
        children: [

          _progressRow(
            icon: Icons.menu_book_rounded,
            title: 'Enzyme Academy',
            completed: lessonsCompleted,
            total: totalLessons,
            color: EVLabColors.emerald,
          ),

          const SizedBox(height: 20),

          _progressRow(
            icon: Icons.quiz_rounded,
            title: 'Knowledge Quizzes',
            completed: quizzesCompleted,
            total: 10,
            color: EVLabColors.purple,
          ),

          const SizedBox(height: 20),

          _progressRow(
            icon: Icons.science_rounded,
            title: 'Virtual Experiments',
            completed: experimentsCompleted,
            total: 10,
            color: EVLabColors.orange,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROGRESS ROW
  // ============================================================

  Widget _progressRow({
    required IconData icon,
    required String title,
    required int completed,
    required int total,
    required Color color,
  }) {
    final progress =
        completed / total;

    return Column(
      children: [

        Row(
          children: [

            Container(
              width: 42,
              height: 42,

              decoration: BoxDecoration(
                color:
                color.withValues(
                  alpha: 0.12,
                ),

                borderRadius:
                BorderRadius.circular(13),
              ),

              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight:
                  FontWeight.bold,

                  color:
                  EVLabColors.textDark,
                ),
              ),
            ),

            Text(
              '$completed / $total',
              style: const TextStyle(
                fontSize: 12,
                fontWeight:
                FontWeight.bold,
                color:
                EVLabColors.textMedium,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        ClipRRect(
          borderRadius:
          BorderRadius.circular(8),

          child: LinearProgressIndicator(
            value: progress,

            minHeight: 8,

            backgroundColor:
            const Color(0xFFE8EDF3),

            valueColor:
            AlwaysStoppedAnimation<Color>(
              color,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ACHIEVEMENTS
  // ============================================================

  Widget _buildAchievements() {
    return SizedBox(
      height: 150,

      child: ListView(
        scrollDirection:
        Axis.horizontal,

        physics:
        const BouncingScrollPhysics(),

        children: [

          _achievement(
            icon: Icons.menu_book_rounded,
            title: 'First Lesson',
            description:
            'Complete your first lesson.',
            color: EVLabColors.emerald,
            unlocked: true,
          ),

          _achievement(
            icon: Icons.quiz_rounded,
            title: 'Quiz Starter',
            description:
            'Complete your first quiz.',
            color: EVLabColors.purple,
            unlocked: true,
          ),

          _achievement(
            icon: Icons.science_rounded,
            title: 'Lab Explorer',
            description:
            'Run your first experiment.',
            color: EVLabColors.orange,
            unlocked: true,
          ),

          _achievement(
            icon: Icons.local_fire_department_rounded,
            title: 'On Fire',
            description:
            'Maintain a 7-day streak.',
            color: EVLabColors.coral,
            unlocked: false,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACHIEVEMENT CARD
  // ============================================================

  Widget _achievement({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required bool unlocked,
  }) {
    return Container(
      width: 155,

      margin:
      const EdgeInsets.only(right: 12),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(20),

        border: Border.all(
          color: unlocked
              ? color.withValues(
            alpha: 0.18,
          )
              : const Color(0xFFE5E9EF),
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.center,

        children: [

          Container(
            width: 50,
            height: 50,

            decoration: BoxDecoration(
              color: unlocked
                  ? color.withValues(
                alpha: 0.12,
              )
                  : const Color(
                0xFFE8ECF2,
              ),

              shape: BoxShape.circle,
            ),

            child: Icon(
              unlocked
                  ? icon
                  : Icons.lock_rounded,

              color: unlocked
                  ? color
                  : EVLabColors.textLight,

              size: 25,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            textAlign: TextAlign.center,

            maxLines: 1,

            overflow:
            TextOverflow.ellipsis,

            style: TextStyle(
              fontSize: 13,

              fontWeight:
              FontWeight.bold,

              color: unlocked
                  ? EVLabColors.textDark
                  : EVLabColors.textLight,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            unlocked
                ? 'Unlocked!'
                : 'Locked',

            style: TextStyle(
              fontSize: 10,

              fontWeight:
              FontWeight.w600,

              color: unlocked
                  ? color
                  : EVLabColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NEXT MISSION
  // ============================================================

  Widget _buildNextMission() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        gradient: EVLabGradients.purple,

        borderRadius:
        BorderRadius.circular(23),

        boxShadow: [
          BoxShadow(
            color: EVLabColors.purple
                .withValues(alpha: 0.18),

            blurRadius: 15,

            offset:
            const Offset(0, 7),
          ),
        ],
      ),

      child: Row(
        children: [

          Container(
            width: 54,
            height: 54,

            decoration: BoxDecoration(
              color: Colors.white
                  .withValues(alpha: 0.18),

              borderRadius:
              BorderRadius.circular(16),
            ),

            child: const Icon(
              Icons.flag_rounded,

              color: Colors.white,

              size: 29,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  'NEXT MISSION',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight:
                    FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Complete Lesson 4',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  '+50 XP • Learn enzyme models',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.arrow_forward_rounded,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}