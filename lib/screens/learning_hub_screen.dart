import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'enzyme_lesson_screen.dart';
import 'enzyme_challenge_screen.dart';

class LearningHubScreen extends StatefulWidget {
  const LearningHubScreen({super.key});

  @override
  State<LearningHubScreen> createState() =>
      _LearningHubScreenState();
}

class _LearningHubScreenState extends State<LearningHubScreen>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: Curves.easeOutCubic,
      ),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pageController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
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
          'Enzyme Academy',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale =
                      1.0 + (_pulseController.value * 0.04);

                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: EVLabColors.orange.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.stars_rounded,
                        color: EVLabColors.orange,
                        size: 18,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '0 XP',
                        style: TextStyle(
                          color: EVLabColors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                18,
                12,
                18,
                35,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  _buildHero(),

                  const SizedBox(height: 25),

                  _buildSectionTitle(),

                  const SizedBox(height: 18),

                  _buildProgressCard(),

                  const SizedBox(height: 26),

                  _buildLessonsHeader(),

                  const SizedBox(height: 13),

                  ..._buildLessonCards(context),

                  const SizedBox(height: 14),

                  _buildChallengeCard(context),

                  const SizedBox(height: 22),

                  _buildAcademyTip(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHero() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final verticalOffset =
            _pulseController.value * 3;

        return Transform.translate(
          offset: Offset(0, -verticalOffset),
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(23),
        decoration: BoxDecoration(
          gradient: EVLabGradients.primary,
          borderRadius: BorderRadius.circular(27),
          boxShadow: [
            BoxShadow(
              color: EVLabColors.emerald.withValues(
                alpha: 0.22,
              ),
              blurRadius: 20,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -25,
              top: -35,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.05,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Positioned(
              right: 25,
              bottom: -50,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.04,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.18,
                    ),
                    borderRadius:
                    BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: 0.15,
                      ),
                    ),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 38,
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
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle() {
    return const Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'Your Learning Journey',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: EVLabColors.textDark,
          ),
        ),

        SizedBox(height: 7),

        Text(
          'Build your knowledge step by step and become a better scientist.',
          style: TextStyle(
            color: EVLabColors.textMedium,
            height: 1.4,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PROGRESS CARD
  // ============================================================

  Widget _buildProgressCard() {
    const double progress = 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.045,
            ),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFF3CD),
                      Color(0xFFFFE8A1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: EVLabColors.orange,
                  size: 27,
                ),
              ),

              const SizedBox(width: 13),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LEVEL 1',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: EVLabColors.textLight,
                        letterSpacing: 0.8,
                      ),
                    ),

                    SizedBox(height: 2),

                    Text(
                      'Young Scientist',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: EVLabColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),

              const Column(
                crossAxisAlignment:
                CrossAxisAlignment.end,
                children: [
                  Text(
                    '0 XP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: EVLabColors.orange,
                    ),
                  ),

                  SizedBox(height: 2),

                  Text(
                    'of 400 XP',
                    style: TextStyle(
                      fontSize: 10,
                      color: EVLabColors.textLight,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 17),

          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                  BorderRadius.circular(10),
                  child:
                  const LinearProgressIndicator(
                    value: progress,
                    minHeight: 9,
                    backgroundColor:
                    Color(0xFFE7ECF3),
                    color: EVLabColors.orange,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              const Text(
                '0%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: EVLabColors.textMedium,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Row(
            children: [
              _miniProgressItem(
                Icons.menu_book_rounded,
                '8 Lessons',
              ),
              const SizedBox(width: 14),
              _miniProgressItem(
                Icons.quiz_rounded,
                '8 Missions',
              ),
              const SizedBox(width: 14),
              _miniProgressItem(
                Icons.emoji_events_rounded,
                '0 Badges',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniProgressItem(
      IconData icon,
      String text,
      ) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 15,
            color: EVLabColors.textLight,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: EVLabColors.textMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LESSON HEADER
  // ============================================================

  Widget _buildLessonsHeader() {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Lessons',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: EVLabColors.textDark,
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: EVLabColors.emerald.withValues(
              alpha: 0.09,
            ),
            borderRadius:
            BorderRadius.circular(15),
          ),
          child: const Text(
            '8 TOPICS',
            style: TextStyle(
              color: EVLabColors.emeraldDark,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LESSONS
  // ============================================================

  List<Widget> _buildLessonCards(
      BuildContext context,
      ) {
    final lessons = [
      _LessonData(
        number: 1,
        title: 'What Are Enzymes?',
        description:
        'Discover enzymes and why life depends on them.',
        icon: Icons.biotech_rounded,
        color: EVLabColors.emerald,
      ),

      _LessonData(
        number: 2,
        title: 'Enzyme Structure',
        description:
        'Explore protein structure and why shape matters.',
        icon: Icons.account_tree_rounded,
        color: EVLabColors.blue,
      ),

      _LessonData(
        number: 3,
        title: 'Active Site & Substrate',
        description:
        'Learn how enzymes recognize and interact with substrates.',
        icon: Icons.center_focus_strong_rounded,
        color: EVLabColors.purple,
      ),

      _LessonData(
        number: 4,
        title: 'Lock & Key vs. Induced Fit',
        description:
        'Compare two models of enzyme-substrate interaction.',
        icon: Icons.key_rounded,
        color: EVLabColors.pink,
      ),

      _LessonData(
        number: 5,
        title: 'How Enzymes Work',
        description:
        'Understand activation energy and catalysis.',
        icon: Icons.bolt_rounded,
        color: EVLabColors.orange,
      ),

      _LessonData(
        number: 6,
        title: 'Factors Affecting Activity',
        description:
        'Explore temperature, pH, substrate, and inhibitors.',
        icon: Icons.speed_rounded,
        color: EVLabColors.cyan,
      ),

      _LessonData(
        number: 7,
        title: 'Enzyme Classes',
        description:
        'Meet the major classes of enzymes.',
        icon: Icons.category_rounded,
        color: EVLabColors.coral,
      ),

      _LessonData(
        number: 8,
        title: 'Enzymes in Real Life',
        description:
        'Discover how enzymes are used in organisms and industries.',
        icon: Icons.public_rounded,
        color: EVLabColors.emeraldDark,
      ),
    ];

    return List.generate(
      lessons.length,
          (index) {
        final lesson = lessons[index];

        return Padding(
          padding:
          const EdgeInsets.only(bottom: 11),
          child: _buildLessonCard(
            context,
            lesson,
            index,
          ),
        );
      },
    );
  }

  Widget _buildLessonCard(
      BuildContext context,
      _LessonData lesson,
      int index,
      ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
      elevation: 0,
      child: InkWell(
        borderRadius:
        BorderRadius.circular(21),
        splashColor: lesson.color.withValues(
          alpha: 0.08,
        ),
        highlightColor:
        lesson.color.withValues(
          alpha: 0.04,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  EnzymeLessonScreen(
                    lessonNumber:
                    lesson.number,
                    title: lesson.title,
                    subtitle:
                    lesson.description,
                    icon: lesson.icon,
                    color: lesson.color,
                  ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(21),
            border: Border.all(
              color: const Color(
                0xFFE8EDF2,
              ),
            ),
          ),
          child: Row(
            children: [
              // LESSON ICON
              Container(
                width: 61,
                height: 61,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      lesson.color.withValues(
                        alpha: 0.16,
                      ),
                      lesson.color.withValues(
                        alpha: 0.07,
                      ),
                    ],
                  ),
                  borderRadius:
                  BorderRadius.circular(18),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      lesson.icon,
                      color: lesson.color,
                      size: 29,
                    ),

                    Positioned(
                      right: 5,
                      top: 5,
                      child: Container(
                        width: 17,
                        height: 17,
                        decoration:
                        BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(
                                alpha: 0.07,
                              ),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${lesson.number}',
                            style: TextStyle(
                              color:
                              lesson.color,
                              fontSize: 9,
                              fontWeight:
                              FontWeight.bold,
                            ),
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
                    Text(
                      'LESSON ${lesson.number}',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight:
                        FontWeight.bold,
                        letterSpacing: 1,
                        color: lesson.color,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      lesson.title,
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.bold,
                        color:
                        EVLabColors.textDark,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      lesson.description,
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color:
                        EVLabColors.textMedium,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ARROW
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: lesson.color
                      .withValues(
                    alpha: 0.09,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: lesson.color,
                  size: 19,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CHALLENGE
  // ============================================================

  Widget _buildChallengeCard(
      BuildContext context,
      ) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius:
        BorderRadius.circular(24),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
              const EnzymeChallengeScreen(),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(21),
          decoration: BoxDecoration(
            gradient: EVLabGradients.purple,
            borderRadius:
            BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: EVLabColors.purple
                    .withValues(
                  alpha: 0.20,
                ),
                blurRadius: 17,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -35,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration:
                  BoxDecoration(
                    color: Colors.white
                        .withValues(
                      alpha: 0.05,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Row(
                children: [
                  AnimatedBuilder(
                    animation:
                    _pulseController,
                    builder:
                        (context, child) {
                      final scale =
                          1.0 +
                              (_pulseController
                                  .value *
                                  0.06);

                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration:
                      BoxDecoration(
                        color: Colors.white
                            .withValues(
                          alpha: 0.18,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          18,
                        ),
                      ),
                      child:
                      const Icon(
                        Icons.quiz_rounded,
                        color:
                        Colors.white,
                        size: 32,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Text(
                          'KNOWLEDGE CHALLENGE',
                          style:
                          TextStyle(
                            color: Colors
                                .white70,
                            fontSize: 9,
                            fontWeight:
                            FontWeight
                                .bold,
                            letterSpacing:
                            1,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          'Test Your Enzyme IQ',
                          style:
                          TextStyle(
                            color:
                            Colors.white,
                            fontSize: 18,
                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          'Complete missions and earn XP.',
                          style:
                          TextStyle(
                            color: Colors
                                .white70,
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  Container(
                    width: 38,
                    height: 38,
                    decoration:
                    BoxDecoration(
                      color: Colors.white
                          .withValues(
                        alpha: 0.16,
                      ),
                      shape:
                      BoxShape.circle,
                    ),
                    child:
                    const Icon(
                      Icons
                          .arrow_forward_rounded,
                      color:
                      Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ACADEMY TIP
  // ============================================================

  Widget _buildAcademyTip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: EVLabColors.emerald.withValues(
            alpha: 0.12,
          ),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.tips_and_updates_rounded,
            color: EVLabColors.emerald,
            size: 23,
          ),

          SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'SCIENTIST TIP',
                  style: TextStyle(
                    color:
                    EVLabColors.emeraldDark,
                    fontSize: 10,
                    fontWeight:
                    FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Don’t rush through the lessons. Understanding why enzymes behave the way they do will help you make better predictions in the Virtual Lab.',
                  style: TextStyle(
                    color:
                    EVLabColors.textMedium,
                    fontSize: 11,
                    height: 1.5,
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
// LESSON MODEL
// ================================================================

class _LessonData {
  final int number;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _LessonData({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}