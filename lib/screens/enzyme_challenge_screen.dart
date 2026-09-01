import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EnzymeChallengeScreen extends StatefulWidget {
  const EnzymeChallengeScreen({super.key});

  @override
  State<EnzymeChallengeScreen> createState() =>
      _EnzymeChallengeScreenState();
}

class _EnzymeChallengeScreenState extends State<EnzymeChallengeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;

  int currentMission = 0;
  int selectedAnswer = -1;
  int score = 0;
  int xpEarned = 0;

  bool answered = false;
  bool showExplanation = false;

  final List<_ChallengeData> challenges = [
    _ChallengeData(
      mission: 1,
      difficulty: 'EASY',
      title: 'Enzyme Basics',
      question: 'What is the main function of an enzyme?',
      answers: [
        'To increase the activation energy',
        'To speed up chemical reactions',
        'To become the final product',
        'To stop all chemical reactions',
      ],
      correctAnswer: 1,
      explanation:
      'Enzymes are biological catalysts. They speed up chemical reactions by lowering the activation energy needed for the reaction to occur.',
      xp: 50,
      icon: Icons.biotech_rounded,
      color: EVLabColors.emerald,
    ),
    _ChallengeData(
      mission: 2,
      difficulty: 'EASY',
      title: 'Meet the Substrate',
      question: 'What molecule binds to an enzyme at its active site?',
      answers: [
        'Product',
        'Substrate',
        'Inhibitor only',
        'Water',
      ],
      correctAnswer: 1,
      explanation:
      'The substrate is the reactant that binds to the enzyme at its active site. The enzyme helps convert the substrate into product(s).',
      xp: 50,
      icon: Icons.link_rounded,
      color: EVLabColors.blue,
    ),
    _ChallengeData(
      mission: 3,
      difficulty: 'MEDIUM',
      title: 'Active Site',
      question: 'Why is the shape of an enzyme important?',
      answers: [
        'It determines which substrates can interact with it',
        'It makes the enzyme invisible',
        'It prevents every reaction',
        'It changes the enzyme into DNA',
      ],
      correctAnswer: 0,
      explanation:
      'The active site has specific chemical and structural properties that allow particular substrates to bind and react.',
      xp: 75,
      icon: Icons.center_focus_strong_rounded,
      color: EVLabColors.purple,
    ),
    _ChallengeData(
      mission: 4,
      difficulty: 'MEDIUM',
      title: 'Temperature Check',
      question:
      'What can happen to many enzymes when temperature becomes too high?',
      answers: [
        'They always become stronger',
        'They turn into substrates',
        'They may denature and lose their function',
        'They produce unlimited ATP',
      ],
      correctAnswer: 2,
      explanation:
      'Excessive heat can disrupt the bonds maintaining an enzyme’s three-dimensional structure. This can change the active site and reduce enzyme activity.',
      xp: 75,
      icon: Icons.thermostat_rounded,
      color: EVLabColors.orange,
    ),
    _ChallengeData(
      mission: 5,
      difficulty: 'MEDIUM',
      title: 'pH Detective',
      question:
      'What usually happens when an enzyme is exposed to an extremely unsuitable pH?',
      answers: [
        'Its activity may decrease',
        'It automatically becomes a different enzyme',
        'It always reaches maximum activity',
        'Nothing can happen',
      ],
      correctAnswer: 0,
      explanation:
      'Enzymes generally have an optimal pH range. Large changes from that range can affect interactions within the enzyme and alter its active site.',
      xp: 75,
      icon: Icons.water_drop_rounded,
      color: EVLabColors.cyan,
    ),
    _ChallengeData(
      mission: 6,
      difficulty: 'HARD',
      title: 'Inhibitor Alert',
      question: 'What does an enzyme inhibitor do?',
      answers: [
        'It always increases enzyme activity',
        'It decreases or interferes with enzyme activity',
        'It becomes the enzyme',
        'It creates the active site',
      ],
      correctAnswer: 1,
      explanation:
      'An inhibitor is a substance that reduces or interferes with enzyme activity. Different inhibitors work through different mechanisms.',
      xp: 100,
      icon: Icons.block_rounded,
      color: EVLabColors.pink,
    ),
    _ChallengeData(
      mission: 7,
      difficulty: 'HARD',
      title: 'Catalysis',
      question: 'How do enzymes help reactions occur more easily?',
      answers: [
        'By lowering activation energy',
        'By increasing the amount of DNA',
        'By becoming permanently consumed',
        'By removing all reactants',
      ],
      correctAnswer: 0,
      explanation:
      'Enzymes provide an alternative reaction pathway with lower activation energy. This allows the reaction to proceed faster under suitable conditions.',
      xp: 100,
      icon: Icons.bolt_rounded,
      color: EVLabColors.yellow,
    ),
    _ChallengeData(
      mission: 8,
      difficulty: 'BOSS',
      title: 'Enzyme Expert',
      question:
      'Which statement about enzymes is scientifically correct?',
      answers: [
        'Enzymes are consumed completely in every reaction',
        'Enzymes change the equilibrium position of a reaction',
        'Enzymes can catalyze reactions without being permanently consumed',
        'Every enzyme works equally well at every pH',
      ],
      correctAnswer: 2,
      explanation:
      'Enzymes participate in reactions but are regenerated rather than permanently consumed. They accelerate the approach to equilibrium without changing the equilibrium position itself.',
      xp: 150,
      icon: Icons.emoji_events_rounded,
      color: EVLabColors.coral,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  _ChallengeData get currentChallenge => challenges[currentMission];

  double get progress => (currentMission + 1) / challenges.length;

  int get totalPossibleXP {
    return challenges.fold(
      0,
          (sum, challenge) => sum + challenge.xp,
    );
  }

  void selectAnswer(int index) {
    if (answered) return;

    setState(() {
      selectedAnswer = index;
    });
  }

  void checkAnswer() {
    if (selectedAnswer == -1 || answered) return;

    final challenge = currentChallenge;
    final correct = selectedAnswer == challenge.correctAnswer;

    setState(() {
      answered = true;
      showExplanation = true;

      if (correct) {
        score++;
        xpEarned += challenge.xp;
      }
    });
  }

  void nextMission() {
    if (currentMission < challenges.length - 1) {
      setState(() {
        currentMission++;
        selectedAnswer = -1;
        answered = false;
        showExplanation = false;
      });

      _fadeController
        ..reset()
        ..forward();
    } else {
      _showCompletionDialog();
    }
  }

  void restartChallenge() {
    setState(() {
      currentMission = 0;
      selectedAnswer = -1;
      score = 0;
      xpEarned = 0;
      answered = false;
      showExplanation = false;
    });

    _fadeController
      ..reset()
      ..forward();
  }

  void _showCompletionDialog() {
    final percentage = ((score / challenges.length) * 100).round();

    String title;
    String message;
    IconData icon;

    if (percentage >= 90) {
      title = 'ENZYME MASTER!';
      message =
      'Outstanding work! You have demonstrated excellent knowledge of enzyme science.';
      icon = Icons.workspace_premium_rounded;
    } else if (percentage >= 70) {
      title = 'GREAT JOB!';
      message =
      'You have a strong understanding of enzymes. Keep experimenting and learning!';
      icon = Icons.emoji_events_rounded;
    } else if (percentage >= 50) {
      title = 'GOOD START!';
      message =
      'You have the basics. Review the lessons and try the challenge again!';
      icon = Icons.science_rounded;
    } else {
      title = 'KEEP LEARNING!';
      message =
      'Every scientist makes mistakes. Review the lessons and try again!';
      icon = Icons.school_rounded;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale =
                        1.0 + (_pulseController.value * 0.08);

                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      gradient: EVLabGradients.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: EVLabColors.textDark,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: EVLabColors.textMedium,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(
                      child: _resultStat(
                        '$score/${challenges.length}',
                        'Correct',
                        EVLabColors.emerald,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _resultStat(
                        '$percentage%',
                        'Score',
                        EVLabColors.blue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _resultStat(
                        '+$xpEarned',
                        'XP',
                        EVLabColors.orange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: const Text(
                      'FINISH CHALLENGE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      restartChallenge();
                    },
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text(
                      'PLAY AGAIN',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
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

  Widget _resultStat(
      String value,
      String label,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: EVLabColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final challenge = currentChallenge;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Enzyme Challenge',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: EVLabColors.orange.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(20),
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
                      '$xpEarned XP',
                      style: const TextStyle(
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
        ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: _fadeController,
            curve: Curves.easeOut,
          ),
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
                _buildMissionHeader(challenge),

                const SizedBox(height: 18),

                _buildProgress(),

                const SizedBox(height: 25),

                _buildQuestionCard(challenge),

                const SizedBox(height: 18),

                _buildAnswers(challenge),

                if (showExplanation) ...[
                  const SizedBox(height: 18),
                  _buildExplanation(challenge),
                ],

                const SizedBox(height: 20),

                _buildActionButton(challenge),

                const SizedBox(height: 20),

                _buildScienceTip(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMissionHeader(_ChallengeData challenge) {
    final isBoss = challenge.difficulty == 'BOSS';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: isBoss
            ? EVLabGradients.purple
            : EVLabGradients.primary,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: (isBoss
                ? EVLabColors.purple
                : EVLabColors.emerald)
                .withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale =
                  1.0 + (_pulseController.value * 0.05);

              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.18,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                challenge.icon,
                color: Colors.white,
                size: 31,
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'MISSION ${challenge.mission}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  challenge.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 7),

                Row(
                  children: [
                    _difficultyBadge(
                      challenge.difficulty,
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.stars_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '+${challenge.xp} XP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
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

  Widget _difficultyBadge(String difficulty) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        difficulty,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Challenge Progress',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: EVLabColors.textDark,
              ),
            ),
            Text(
              '${currentMission + 1} / ${challenges.length}',
              style: const TextStyle(
                color: EVLabColors.textMedium,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 9),

        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 9,
            backgroundColor: const Color(0xFFE2E8F0),
            color: EVLabColors.emerald,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(_ChallengeData challenge) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
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
                  color: challenge.color.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.help_outline_rounded,
                  color: challenge.color,
                  size: 21,
                ),
              ),

              const SizedBox(width: 10),

              const Text(
                'QUESTION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: EVLabColors.textLight,
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          Text(
            challenge.question,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: EVLabColors.textDark,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswers(_ChallengeData challenge) {
    return Column(
      children: List.generate(
        challenge.answers.length,
            (index) {
          final isSelected =
              selectedAnswer == index;
          final isCorrect =
              index == challenge.correctAnswer;

          Color borderColor =
          const Color(0xFFE0E6EF);
          Color backgroundColor = Colors.white;
          Color iconColor =
              EVLabColors.textMedium;

          if (answered) {
            // Do not reveal the correct option by highlighting it. The
            // explanation panel below teaches the concept after submission.
            if (isSelected) {
              borderColor = isCorrect
                  ? EVLabColors.success
                  : EVLabColors.danger;
              backgroundColor = (isCorrect
                      ? EVLabColors.success
                      : EVLabColors.danger)
                  .withValues(alpha: 0.07);
              iconColor = isCorrect
                  ? EVLabColors.success
                  : EVLabColors.danger;
            }
          } else if (isSelected) {
            borderColor = EVLabColors.emerald;
            backgroundColor =
                EVLabColors.emerald.withValues(
                  alpha: 0.07,
                );
            iconColor = EVLabColors.emerald;
          }

          return Padding(
            padding: const EdgeInsets.only(
              bottom: 11,
            ),
            child: AnimatedContainer(
              duration:
              const Duration(milliseconds: 250),
              width: double.infinity,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius:
                BorderRadius.circular(17),
                border: Border.all(
                  color: borderColor,
                  width: isSelected || (answered && isCorrect)
                      ? 2
                      : 1,
                ),
                boxShadow: [
                  if (isSelected && !answered)
                    BoxShadow(
                      color: EVLabColors.emerald
                          .withValues(alpha: 0.10),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius:
                  BorderRadius.circular(17),
                  onTap: answered
                      ? null
                      : () => selectAnswer(index),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: iconColor.withValues(
                              alpha: 0.10,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: answered
                                ? Icon(
                              isSelected
                                  ? (isCorrect ? Icons.check_rounded : Icons.close_rounded)
                                  : Icons.circle_outlined,
                              color: iconColor,
                              size: 20,
                            )
                                : Text(
                              String.fromCharCode(
                                65 + index,
                              ),
                              style: TextStyle(
                                color: iconColor,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 13),

                        Expanded(
                          child: Text(
                            challenge.answers[index],
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.35,
                              fontWeight:
                              isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color:
                              EVLabColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExplanation(
      _ChallengeData challenge) {
    final correct =
        selectedAnswer == challenge.correctAnswer;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: correct
            ? EVLabColors.success.withValues(
          alpha: 0.08,
        )
            : EVLabColors.orange.withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: correct
              ? EVLabColors.success.withValues(
            alpha: 0.25,
          )
              : EVLabColors.orange.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                correct
                    ? Icons.check_circle_rounded
                    : Icons.lightbulb_rounded,
                color: correct
                    ? EVLabColors.success
                    : EVLabColors.orange,
                size: 22,
              ),

              const SizedBox(width: 9),

              Text(
                correct
                    ? 'CORRECT! +${challenge.xp} XP'
                    : 'LEARN FROM IT',
                style: TextStyle(
                  color: correct
                      ? EVLabColors.success
                      : EVLabColors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            challenge.explanation,
            style: const TextStyle(
              color: EVLabColors.textDark,
              height: 1.5,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      _ChallengeData challenge) {
    if (!answered) {
      return SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton.icon(
          onPressed:
          selectedAnswer == -1
              ? null
              : checkAnswer,
          icon: const Icon(
            Icons.check_rounded,
          ),
          label: const Text(
            'CHECK ANSWER',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
    }

    final isLast =
        currentMission == challenges.length - 1;

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: nextMission,
        icon: Icon(
          isLast
              ? Icons.emoji_events_rounded
              : Icons.arrow_forward_rounded,
        ),
        label: Text(
          isLast ? 'FINISH CHALLENGE' : 'NEXT MISSION',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildScienceTip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EVLabColors.background,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: EVLabColors.emerald.withValues(
            alpha: 0.15,
          ),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.tips_and_updates_rounded,
            color: EVLabColors.emeraldDark,
            size: 22,
          ),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'Scientist Tip: Don’t just memorize the answer. '
                  'Understand why the enzyme behaves that way. '
                  'That is how you become an enzyme expert!',
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

// ================================================================
// CHALLENGE MODEL
// ================================================================

class _ChallengeData {
  final int mission;
  final String difficulty;
  final String title;
  final String question;
  final List<String> answers;
  final int correctAnswer;
  final String explanation;
  final int xp;
  final IconData icon;
  final Color color;

  const _ChallengeData({
    required this.mission,
    required this.difficulty,
    required this.title,
    required this.question,
    required this.answers,
    required this.correctAnswer,
    required this.explanation,
    required this.xp,
    required this.icon,
    required this.color,
  });
}