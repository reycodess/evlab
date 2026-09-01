import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../services/progress_service.dart';

class EnzymeLessonScreen extends StatefulWidget {
  final int lessonNumber;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const EnzymeLessonScreen({
    super.key,
    required this.lessonNumber,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  State<EnzymeLessonScreen> createState() =>
      _EnzymeLessonScreenState();
}

class _EnzymeLessonScreenState
    extends State<EnzymeLessonScreen>
    with SingleTickerProviderStateMixin {
  final ProgressService progress =
      ProgressService.instance;

  late AnimationController _animationController;

  late Animation<double> _fadeAnimation;

  bool _completedBefore = false;

  @override
  void initState() {
    super.initState();

    _completedBefore =
        progress.isLessonCompleted(widget.lessonNumber);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 700,
      ),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
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
        title: Text(
          'Lesson ${widget.lessonNumber}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          AnimatedBuilder(
            animation: progress,
            builder: (context, _) {
              return Padding(
                padding: const EdgeInsets.only(
                  right: 14,
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: EVLabColors.yellow.withValues(
                        alpha: 0.18,
                      ),
                      borderRadius:
                      BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.stars_rounded,
                          color: EVLabColors.orange,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${progress.xp} XP',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color:
                            EVLabColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics:
          const BouncingScrollPhysics(),
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
              _buildHero(),

              const SizedBox(height: 18),

              _buildProgressCard(),

              const SizedBox(height: 22),

              _buildIntroduction(),

              const SizedBox(height: 20),

              _buildLessonContent(),

              const SizedBox(height: 24),

              _buildKeyTakeaway(),

              const SizedBox(height: 24),

              _buildCompletionButton(context),
            ],
          ),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.color,
            widget.color.withValues(
              alpha: 0.70,
            ),
          ],
        ),
        borderRadius:
        BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: widget.color.withValues(
              alpha: 0.22,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.18,
              ),
              borderRadius:
              BorderRadius.circular(18),
            ),
            child: Icon(
              widget.icon,
              color: Colors.white,
              size: 34,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'LESSON ${widget.lessonNumber}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                if (_completedBefore)
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'COMPLETED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight:
                          FontWeight.bold,
                          letterSpacing: 1,
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
  // PLAYER PROGRESS
  // ============================================================

  Widget _buildProgressCard() {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(21),
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
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      gradient:
                      EVLabGradients.orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.stars_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LEVEL ${progress.level}',
                          style: const TextStyle(
                            color:
                            EVLabColors.textLight,
                            fontSize: 10,
                            fontWeight:
                            FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          progress.rank,
                          style: const TextStyle(
                            color:
                            EVLabColors.textDark,
                            fontSize: 16,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    '${progress.currentLevelXP} / '
                        '${progress.xpForNextLevel} XP',
                    style: const TextStyle(
                      color:
                      EVLabColors.textMedium,
                      fontSize: 11,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              ClipRRect(
                borderRadius:
                BorderRadius.circular(10),
                child:
                LinearProgressIndicator(
                  value: progress.levelProgress,
                  minHeight: 8,
                  backgroundColor:
                  const Color(0xFFE7ECF3),
                  color:
                  EVLabColors.orange,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // INTRODUCTION
  // ============================================================

  Widget _buildIntroduction() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(21),
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
              Icon(
                Icons.lightbulb_outline_rounded,
                color: widget.color,
              ),

              const SizedBox(width: 10),

              const Text(
                'What You Will Learn',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                  EVLabColors.textDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Text(
            widget.subtitle,
            style: const TextStyle(
              color:
              EVLabColors.textMedium,
              height: 1.5,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LESSON CONTENT
  // ============================================================

  Widget _buildLessonContent() {
    switch (widget.lessonNumber) {
      case 1:
        return _lessonWhatAreEnzymes();

      case 2:
        return _lessonStructure();

      case 3:
        return _lessonActiveSite();

      case 4:
        return _lessonModels();

      case 5:
        return _lessonHowEnzymesWork();

      case 6:
        return _lessonFactors();

      case 7:
        return _lessonClasses();

      case 8:
        return _lessonRealLife();

      default:
        return _genericLesson();
    }
  }

  // ============================================================
  // LESSON 1
  // ============================================================

  Widget _lessonWhatAreEnzymes() {
    return _contentSection(
      title: 'What Are Enzymes?',
      icon: Icons.biotech_rounded,
      children: [
        _infoText(
          'Enzymes are biological catalysts. They speed up '
              'chemical reactions in living organisms without being '
              'consumed by the reaction.',
        ),

        _infoText(
          'Most enzymes are proteins. Their three-dimensional '
              'structure allows them to interact with specific '
              'molecules called substrates.',
        ),

        _factCard(
          'KEY IDEA',
          'Enzymes increase reaction rates by lowering '
              'the activation energy required for a reaction.',
        ),
      ],
    );
  }

  // ============================================================
  // LESSON 2
  // ============================================================

  Widget _lessonStructure() {
    return _contentSection(
      title: 'Enzyme Structure',
      icon: Icons.account_tree_rounded,
      children: [
        _infoText(
          'The structure of an enzyme is closely related to '
              'its function. Changes in structure can affect how '
              'well an enzyme performs its catalytic role.',
        ),

        _infoText(
          'Enzymes have specific regions where substrates can '
              'bind. This region is called the active site.',
        ),

        _factCard(
          'REMEMBER',
          'An enzyme must maintain the correct shape of its '
              'active site for effective substrate binding.',
        ),
      ],
    );
  }

  // ============================================================
  // LESSON 3
  // ============================================================

  Widget _lessonActiveSite() {
    return _contentSection(
      title: 'Active Site & Substrate',
      icon:
      Icons.center_focus_strong_rounded,
      children: [
        _infoText(
          'The substrate is the molecule that an enzyme acts '
              'upon. The active site is the region of the enzyme '
              'where the substrate binds.',
        ),

        _infoText(
          'Interactions between the substrate and active site '
              'help position the substrate so the reaction can occur '
              'more efficiently.',
        ),

        _factCard(
          'THINK ABOUT IT',
          'Why does an enzyme usually interact with particular '
              'substrates rather than every molecule?',
        ),
      ],
    );
  }

  // ============================================================
  // LESSON 4
  // ============================================================

  Widget _lessonModels() {
    return _contentSection(
      title: 'Lock & Key vs. Induced Fit',
      icon: Icons.key_rounded,
      children: [
        _infoText(
          'The lock-and-key model describes the active site as '
              'having a shape complementary to its substrate.',
        ),

        _infoText(
          'The induced-fit model explains that substrate binding '
              'can cause the enzyme to adjust its shape slightly, '
              'helping create favorable interactions for catalysis.',
        ),

        _factCard(
          'MODERN VIEW',
          'The induced-fit model provides a more flexible '
              'description of many enzyme-substrate interactions.',
        ),
      ],
    );
  }

  // ============================================================
  // LESSON 5
  // ============================================================

  Widget _lessonHowEnzymesWork() {
    return _contentSection(
      title: 'How Enzymes Work',
      icon: Icons.bolt_rounded,
      children: [
        _infoText(
          'Chemical reactions require an initial energy input '
              'called activation energy.',
        ),

        _infoText(
          'Enzymes lower the activation energy of a reaction. '
              'This allows the reaction to proceed faster under '
              'appropriate conditions.',
        ),

        _factCard(
          'IMPORTANT',
          'Enzymes do not change the overall energy released '
              'or absorbed by a reaction. They change the pathway '
              'and lower the activation energy barrier.',
        ),
      ],
    );
  }

  // ============================================================
  // LESSON 6
  // ============================================================

  Widget _lessonFactors() {
    return _contentSection(
      title: 'Factors Affecting Activity',
      icon: Icons.speed_rounded,
      children: [
        _infoText(
          'Enzyme activity can be affected by environmental '
              'conditions such as temperature and pH.',
        ),

        _infoText(
          'Substrate concentration can also affect reaction '
              'rate. At sufficiently high substrate concentrations, '
              'enzyme active sites can become saturated.',
        ),

        _infoText(
          'Inhibitors are substances that decrease enzyme '
              'activity through different mechanisms.',
        ),

        _factCard(
          'IN EV-LAB',
          'You can investigate temperature, pH, substrate '
              'concentration, and inhibitor effects using the '
              'virtual laboratory.',
        ),
      ],
    );
  }

  // ============================================================
  // LESSON 7
  // ============================================================

  Widget _lessonClasses() {
    return _contentSection(
      title: 'Enzyme Classes',
      icon: Icons.category_rounded,
      children: [
        _infoText(
          'Enzymes are classified according to the types of '
              'reactions they catalyze.',
        ),

        _bullet(
          'Oxidoreductases',
          'Catalyze oxidation-reduction reactions.',
        ),

        _bullet(
          'Transferases',
          'Transfer functional groups between molecules.',
        ),

        _bullet(
          'Hydrolases',
          'Break bonds using water.',
        ),

        _bullet(
          'Lyases',
          'Add or remove groups to form or break bonds without '
              'hydrolysis or oxidation-reduction.',
        ),

        _bullet(
          'Isomerases',
          'Catalyze rearrangements within molecules.',
        ),

        _bullet(
          'Ligases',
          'Join molecules, generally coupled to energy input.',
        ),
      ],
    );
  }

  // ============================================================
  // LESSON 8
  // ============================================================

  Widget _lessonRealLife() {
    return _contentSection(
      title: 'Enzymes in Real Life',
      icon: Icons.public_rounded,
      children: [
        _infoText(
          'Enzymes are essential in living organisms because '
              'many biological reactions would occur too slowly '
              'without catalysis.',
        ),

        _infoText(
          'They are also useful in biotechnology, food '
              'processing, medicine, detergents, and other '
              'industrial applications.',
        ),

        _factCard(
          'EXAMPLES',
          'Amylase helps break down starch, lipases act on '
              'lipids, and many other enzymes support important '
              'biological and industrial processes.',
        ),
      ],
    );
  }

  // ============================================================
  // GENERIC LESSON
  // ============================================================

  Widget _genericLesson() {
    return _contentSection(
      title: widget.title,
      icon: widget.icon,
      children: [
        _infoText(widget.subtitle),
      ],
    );
  }

  // ============================================================
  // CONTENT SECTION
  // ============================================================

  Widget _contentSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(21),
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
              Icon(
                icon,
                color: widget.color,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color:
                    EVLabColors.textDark,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ...children,
        ],
      ),
    );
  }

  // ============================================================
  // TEXT
  // ============================================================

  Widget _infoText(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: EVLabColors.textMedium,
          height: 1.55,
          fontSize: 14,
        ),
      ),
    );
  }

  // ============================================================
  // BULLET
  // ============================================================

  Widget _bullet(
      String title,
      String description,
      ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 13,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 9,
            height: 9,
            margin: const EdgeInsets.only(
              top: 6,
              right: 10,
            ),
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),

          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color:
                  EVLabColors.textMedium,
                  height: 1.45,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                      color:
                      EVLabColors.textDark,
                    ),
                  ),
                  TextSpan(
                    text: description,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FACT CARD
  // ============================================================

  Widget _factCard(
      String title,
      String text,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: widget.color.withValues(
          alpha: 0.08,
        ),
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: widget.color.withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            color: widget.color,
            size: 23,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight:
                    FontWeight.bold,
                    color: widget.color,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  text,
                  style: const TextStyle(
                    color:
                    EVLabColors.textMedium,
                    height: 1.4,
                    fontSize: 13,
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
  // KEY TAKEAWAY
  // ============================================================

  Widget _buildKeyTakeaway() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: EVLabGradients.primary,
        borderRadius:
        BorderRadius.circular(21),
        boxShadow: [
          BoxShadow(
            color: EVLabColors.emerald
                .withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.18,
              ),
              borderRadius:
              BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'KEY TAKEAWAY',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight:
                    FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Understanding enzymes means understanding '
                      'how their structure, environment, and '
                      'interactions influence biological reactions.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.45,
                    fontWeight:
                    FontWeight.w500,
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
  // COMPLETION BUTTON
  // ============================================================

  Widget _buildCompletionButton(
      BuildContext context,
      ) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final completed =
        progress.isLessonCompleted(
          widget.lessonNumber,
        );

        return SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton.icon(
            onPressed: completed
                ? () {
              Navigator.pop(context);
            }
                : () {
              _completeLesson(context);
            },
            icon: Icon(
              completed
                  ? Icons.check_circle_rounded
                  : Icons.school_rounded,
            ),
            label: Text(
              completed
                  ? 'LESSON COMPLETED • BACK TO ACADEMY'
                  : 'COMPLETE LESSON • +50 XP',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: completed
                  ? EVLabColors.success
                  : widget.color,
              foregroundColor: Colors.white,
              elevation: 0,
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(17),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // COMPLETE LESSON
  // ============================================================

  void _completeLesson(
      BuildContext context,
      ) {
    if (progress.isLessonCompleted(
      widget.lessonNumber,
    )) {
      return;
    }

    progress.completeLesson(
      widget.lessonNumber,
    );

    setState(() {
      _completedBefore = true;
    });

    _showCompletionDialog(context);
  }

  // ============================================================
  // COMPLETION DIALOG
  // ============================================================

  void _showCompletionDialog(
      BuildContext context,
      ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(26),
          ),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    gradient:
                    EVLabGradients.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'LESSON COMPLETE!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight:
                    FontWeight.bold,
                    color:
                    EVLabColors.textDark,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Great work, Scientist!',
                  style: TextStyle(
                    color:
                    EVLabColors.textMedium,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: EVLabColors.yellow
                        .withValues(
                      alpha: 0.15,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      18,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons
                            .stars_rounded,
                        color:
                        EVLabColors.orange,
                        size: 35,
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      const Text(
                        '+50 XP',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight:
                          FontWeight.bold,
                          color:
                          EVLabColors.orange,
                        ),
                      ),

                      const SizedBox(
                        height: 3,
                      ),

                      Text(
                        'Level ${progress.level} • '
                            '${progress.rank}',
                        style:
                        const TextStyle(
                          color:
                          EVLabColors.textMedium,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        dialogContext,
                      );
                    },
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      widget.color,
                      foregroundColor:
                      Colors.white,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                          15,
                        ),
                      ),
                    ),
                    child: const Text(
                      'CONTINUE',
                      style: TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}