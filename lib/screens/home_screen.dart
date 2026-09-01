import 'package:flutter/material.dart';
import 'package:evlab/theme/app_theme.dart';

import '../widgets/home_header.dart';
import '../widgets/feature_card.dart';
import '../services/progress_service.dart';

import 'structure_screen.dart';
import 'enzyme_activity_screen.dart';
import 'about_screen.dart';
import 'enzyme_library_screen.dart';
import 'scientific_basis_screen.dart';
import 'experiment_history_screen.dart';
import 'mission_screen.dart';
import 'enzyme_quiz_screen.dart';
import 'learning_hub_screen.dart';
import 'progress_screen.dart';
import 'enzyme_selection_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void openPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            18,
            12,
            18,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton.filledTonal(
                    tooltip: 'Settings',
                    onPressed: () => openPage(context, const SettingsScreen()),
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),

              const HomeHeader(),

              const SizedBox(height: 12),

              _buildPlayerCard(),

              const SizedBox(height: 18),

              _buildMissionCard(context),

              const SizedBox(height: 25),

              const Text(
                'Your Progress',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: EVLabColors.textDark,
                ),
              ),

              const SizedBox(height: 12),

              _buildProgressStats(),

              const SizedBox(height: 28),

              const Text(
                'Play & Learn',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: EVLabColors.textDark,
                ),
              ),

              const SizedBox(height: 12),

              _buildGameModeCard(context),

              const SizedBox(height: 28),

              const Text(
                'Learn & Practice',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: EVLabColors.textDark,
                ),
              ),

              const SizedBox(height: 12),

              FeatureCard(
                icon: Icons.flag_rounded,
                title: 'Missions',
                subtitle:
                'Complete guided enzyme missions and earn XP.',
                color: EVLabColors.purple,
                onTap: () =>
                    openPage(context, const MissionScreen()),
              ),

              FeatureCard(
                icon: Icons.quiz_rounded,
                title: 'Enzyme Quiz',
                subtitle:
                'Test your enzyme knowledge and build your score.',
                color: EVLabColors.cyan,
                onTap: () =>
                    openPage(context, const EnzymeQuizScreen()),
              ),

              FeatureCard(
                icon: Icons.auto_stories_rounded,
                title: 'Learning Hub',
                subtitle:
                'Access lessons, challenges, and interactive learning.',
                color: EVLabColors.emerald,
                onTap: () =>
                    openPage(context, const LearningHubScreen()),
              ),

              FeatureCard(
                icon: Icons.emoji_events_rounded,
                title: 'My Progress',
                subtitle:
                'Track XP, missions, badges, and learning progress.',
                color: EVLabColors.orange,
                onTap: () =>
                    openPage(context, const ProgressScreen()),
              ),

              FeatureCard(
                icon: Icons.science_rounded,
                title: 'Choose an Enzyme',
                subtitle:
                'Select an enzyme before entering the virtual lab.',
                color: EVLabColors.pink,
                onTap: () =>
                    openPage(context, const EnzymeSelectionScreen()),
              ),

              const SizedBox(height: 28),


              const Text(
                'Explore EV-LAB',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: EVLabColors.textDark,
                ),
              ),

              const SizedBox(height: 12),

              FeatureCard(
                icon: Icons.account_tree,
                title: 'Enzyme Structure',
                subtitle:
                'Learn the anatomy and functions of enzymes.',
                color: EVLabColors.blue,
                onTap: () {
                  openPage(
                    context,
                    const StructureScreen(),
                  );
                },
              ),

              FeatureCard(
                icon: Icons.menu_book,
                title: 'Enzyme Library',
                subtitle:
                'Browse enzymes and their scientific information.',
                color: EVLabColors.purple,
                onTap: () {
                  openPage(
                    context,
                    const EnzymeLibraryScreen(),
                  );
                },
              ),

              FeatureCard(
                icon: Icons.biotech,
                title: 'Enzyme Activity',
                subtitle:
                'Understand how enzymes affect reaction rates.',
                color: EVLabColors.emerald,
                onTap: () {
                  openPage(
                    context,
                    const EnzymeActivityScreen(),
                  );
                },
              ),

              FeatureCard(
                icon: Icons.bar_chart_rounded,
                title: 'Laboratory Results',
                subtitle:
                'Review your previous experiment results.',
                color: EVLabColors.orange,
                onTap: () {
                  openPage(
                    context,
                    const ExperimentHistoryScreen(),
                  );
                },
              ),

              FeatureCard(
                icon: Icons.science_outlined,
                title: 'Scientific Basis',
                subtitle:
                'Learn the scientific principles used by EV-LAB.',
                color: EVLabColors.cyan,
                onTap: () {
                  openPage(
                    context,
                    const ScientificBasisScreen(),
                  );
                },
              ),

              FeatureCard(
                icon: Icons.info_outline,
                title: 'About EV-LAB',
                subtitle:
                'Learn more about the virtual laboratory.',
                color: EVLabColors.pink,
                onTap: () {
                  openPage(
                    context,
                    const AboutScreen(),
                  );
                },
              ),

              const SizedBox(height: 24),

              _buildScientificNote(),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // PLAYER PROFILE
  // ==============================================================

  Widget _buildPlayerCard() {
    final progress = ProgressService.instance;

    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: EVLabGradients.blue,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: EVLabColors.blue.withValues(alpha: 0.18),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'EV-LAB RESEARCHER',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Level ${progress.level}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${progress.xp} XP earned',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.science_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${progress.completedExperiments}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==============================================================
  // DAILY MISSION
  // ==============================================================

  Widget _buildMissionCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: EVLabGradients.purple,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: EVLabColors.purple.withValues(alpha: 0.20),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MISSION 01',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'The Perfect Condition',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.lock_open_rounded,
                color: Colors.white,
              ),
            ],
          ),

          const SizedBox(height: 15),

          const Text(
            'Find the temperature and pH conditions '
                'that produce the highest enzyme activity.',
            style: TextStyle(
              color: Colors.white,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 17),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                openPage(
                  context,
                  const MissionScreen(),
                );
              },
              icon: const Icon(
                Icons.play_arrow_rounded,
              ),
              label: const Text(
                'START MISSION',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: EVLabColors.purple,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // PROGRESS STATS
  // ==============================================================

  Widget _buildProgressStats() {
    final progress = ProgressService.instance;

    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        return Row(
          children: [
            Expanded(
              child: _statCard(
                icon: Icons.stars_rounded,
                value: '${progress.xp}',
                label: 'XP',
                color: EVLabColors.yellow,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _statCard(
                icon: Icons.emoji_events_rounded,
                value: '${progress.earnedBadges.length}',
                label: 'Badges',
                color: EVLabColors.orange,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _statCard(
                icon: Icons.science_rounded,
                value: '${progress.completedExperiments}',
                label: 'Experiments',
                color: EVLabColors.cyan,
              ),
            ),
          ],
        );
      },
    );
  }

  // ==============================================================
  // STAT CARD
  // ==============================================================

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: EVLabColors.textDark,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: EVLabColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // GAME MODE
  // ==============================================================

  Widget _buildGameModeCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        openPage(
          context,
          const LearningHubScreen(),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: EVLabGradients.orange,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: EVLabColors.orange.withValues(alpha: 0.20),
              blurRadius: 15,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.videogame_asset_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),

            const SizedBox(width: 15),

            const Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'FREE LAB',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    'Experiment Freely',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 3),

                  Text(
                    'Test conditions and discover what happens!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // SCIENTIFIC NOTE
  // ==============================================================

  Widget _buildScientificNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EVLabColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: EVLabColors.emerald.withValues(alpha: 0.15),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_outlined,
            color: EVLabColors.emeraldDark,
            size: 22,
          ),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'EV-LAB is an educational simulation. '
                  'Its models are based on established enzyme '
                  'kinetics and reference data, but simulations '
                  'do not replace actual laboratory experiments.',
              style: TextStyle(
                color: EVLabColors.textMedium,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}