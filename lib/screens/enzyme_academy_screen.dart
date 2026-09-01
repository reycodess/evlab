import 'package:flutter/material.dart';
import 'package:evlab/theme/app_theme.dart';

class EnzymeAcademyScreen extends StatelessWidget {
  const EnzymeAcademyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text(
          'Enzyme Academy',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
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

              // ==================================================
              // ACADEMY HEADER
              // ==================================================

              _buildAcademyHeader(),

              const SizedBox(height: 25),

              // ==================================================
              // LEARNING PROGRESS
              // ==================================================

              _buildProgressCard(),

              const SizedBox(height: 28),

              const Text(
                'Learn Enzymes',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: EVLabColors.textDark,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Master the science of enzymes through interactive lessons.',
                style: TextStyle(
                  color: EVLabColors.textMedium,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // LESSONS
              // ==================================================

              _buildLessonCard(
                context,
                number: '01',
                icon: Icons.science_rounded,
                title: 'What Are Enzymes?',
                description:
                'Discover what enzymes are and why they are essential for life.',
                color: EVLabColors.emerald,
                status: 'START',
                locked: false,
              ),

              _buildLessonCard(
                context,
                number: '02',
                icon: Icons.bolt_rounded,
                title: 'Activation Energy',
                description:
                'Learn how enzymes help reactions happen faster by lowering activation energy.',
                color: EVLabColors.yellow,
                status: 'LOCKED',
                locked: true,
              ),

              _buildLessonCard(
                context,
                number: '03',
                icon: Icons.link_rounded,
                title: 'Enzyme–Substrate Interaction',
                description:
                'Explore how substrates interact with enzyme active sites.',
                color: EVLabColors.blue,
                status: 'LOCKED',
                locked: true,
              ),

              _buildLessonCard(
                context,
                number: '04',
                icon: Icons.extension_rounded,
                title: 'Enzyme Specificity',
                description:
                'Understand why enzymes recognize specific substrates.',
                color: EVLabColors.purple,
                status: 'LOCKED',
                locked: true,
              ),

              _buildLessonCard(
                context,
                number: '05',
                icon: Icons.thermostat_rounded,
                title: 'Factors Affecting Enzyme Activity',
                description:
                'Explore temperature, pH, substrate concentration, and enzyme concentration.',
                color: EVLabColors.orange,
                status: 'LOCKED',
                locked: true,
              ),

              _buildLessonCard(
                context,
                number: '06',
                icon: Icons.block_rounded,
                title: 'Enzyme Inhibition',
                description:
                'Learn how inhibitors affect enzyme activity and reaction rates.',
                color: EVLabColors.coral,
                status: 'LOCKED',
                locked: true,
              ),

              _buildLessonCard(
                context,
                number: '07',
                icon: Icons.hub_rounded,
                title: 'Cofactors & Coenzymes',
                description:
                'Discover molecules that help certain enzymes perform their functions.',
                color: EVLabColors.cyan,
                status: 'LOCKED',
                locked: true,
              ),

              _buildLessonCard(
                context,
                number: '08',
                icon: Icons.public_rounded,
                title: 'Enzymes in Everyday Life',
                description:
                'Discover how enzymes are used in food, medicine, industry, and daily life.',
                color: EVLabColors.pink,
                status: 'LOCKED',
                locked: true,
              ),

              const SizedBox(height: 20),

              // ==================================================
              // LAB CONNECTION
              // ==================================================

              _buildLabConnection(context),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // ACADEMY HEADER
  // ==============================================================

  Widget _buildAcademyHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: EVLabGradients.primary,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: EVLabColors.emerald.withValues(
              alpha: 0.20,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.18,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),

          const SizedBox(width: 16),

          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'ENZYME ACADEMY',
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
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Learn • Explore • Experiment',
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

  // ==============================================================
  // PROGRESS CARD
  // ==============================================================

  Widget _buildProgressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: EVLabColors.emerald.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: EVLabColors.emeraldDark,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Text(
                  'Your Academy Progress',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: EVLabColors.textDark,
                  ),
                ),
              ),

              const Text(
                '0 / 8',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: EVLabColors.emeraldDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0,
              minHeight: 9,
              backgroundColor: Color(0xFFE3EAF0),
              valueColor: AlwaysStoppedAnimation<Color>(
                EVLabColors.emerald,
              ),
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Complete lessons to unlock new topics and earn XP.',
            style: TextStyle(
              color: EVLabColors.textMedium,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // LESSON CARD
  // ==============================================================

  Widget _buildLessonCard(
      BuildContext context, {
        required String number,
        required IconData icon,
        required String title,
        required String description,
        required Color color,
        required String status,
        required bool locked,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: locked
              ? Colors.transparent
              : color.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.035,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: locked
              ? null
              : () {
            _openLesson(
              context,
              title,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // LESSON NUMBER / ICON

                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: locked
                        ? Colors.grey.shade100
                        : color.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius:
                    BorderRadius.circular(17),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        locked
                            ? Icons.lock_rounded
                            : icon,
                        color: locked
                            ? EVLabColors.textLight
                            : color,
                        size: 27,
                      ),

                      if (!locked)
                        Positioned(
                          bottom: 3,
                          right: 4,
                          child: Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius:
                              BorderRadius.circular(5),
                            ),
                            child: Text(
                              number,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                // TEXT

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                FontWeight.bold,
                                color: locked
                                    ? EVLabColors.textLight
                                    : EVLabColors.textDark,
                              ),
                            ),
                          ),

                          if (!locked)
                            Container(
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(
                                  alpha: 0.10,
                                ),
                                borderRadius:
                                BorderRadius.circular(
                                  8,
                                ),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 9,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      Text(
                        description,
                        style: TextStyle(
                          color: locked
                              ? EVLabColors.textLight
                              : EVLabColors.textMedium,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Icon(
                  locked
                      ? Icons.lock_outline_rounded
                      : Icons.arrow_forward_ios_rounded,
                  color: locked
                      ? EVLabColors.textLight
                      : color,
                  size: 17,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // LAB CONNECTION
  // ==============================================================

  Widget _buildLabConnection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: EVLabGradients.orange,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: EVLabColors.orange.withValues(
              alpha: 0.18,
            ),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.18,
              ),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.science_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'READY TO EXPERIMENT?',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Take what you learned into the Virtual Lab.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
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

  // ==============================================================
  // OPEN LESSON
  // ==============================================================

  void _openLesson(
      BuildContext context,
      String lessonTitle,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _LessonPlaceholder(
          title: lessonTitle,
        ),
      ),
    );
  }
}

// ==================================================================
// TEMPORARY LESSON SCREEN
// ==================================================================

class _LessonPlaceholder extends StatelessWidget {
  final String title;

  const _LessonPlaceholder({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: EVLabGradients.primary,
                  borderRadius:
                  BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 45,
                ),
              ),

              const SizedBox(height: 25),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: EVLabColors.textDark,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'This lesson is coming next. '
                    'You will learn the concept through '
                    'interactive explanations, examples, '
                    'and challenges.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: EVLabColors.textMedium,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: EVLabColors.emerald.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: const Text(
                  '+10 XP when completed',
                  style: TextStyle(
                    color: EVLabColors.emeraldDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}