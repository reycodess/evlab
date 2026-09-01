import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EnzymeQuizScreen extends StatefulWidget {
  const EnzymeQuizScreen({super.key});

  @override
  State<EnzymeQuizScreen> createState() => _EnzymeQuizScreenState();
}

class _EnzymeQuizScreenState extends State<EnzymeQuizScreen> {
  // ============================================================
  // QUIZ QUESTIONS
  // ============================================================

  final List<QuizQuestion> _questions = [
    QuizQuestion(
      question: 'What is an enzyme?',
      options: [
        'A type of carbohydrate',
        'A biological catalyst',
        'A type of DNA',
        'A waste product',
      ],
      correctAnswer: 1,
      explanation:
      'Enzymes are biological catalysts that speed up chemical reactions without being consumed by the reaction.',
      topic: 'Enzyme Basics',
    ),

    QuizQuestion(
      question: 'What are most enzymes made of?',
      options: [
        'Lipids',
        'Carbohydrates',
        'Proteins',
        'Minerals',
      ],
      correctAnswer: 2,
      explanation:
      'Most enzymes are proteins. However, some RNA molecules called ribozymes can also catalyze reactions.',
      topic: 'Enzyme Basics',
    ),

    QuizQuestion(
      question: 'What is the molecule an enzyme acts upon called?',
      options: [
        'Product',
        'Substrate',
        'Inhibitor',
        'Cofactor',
      ],
      correctAnswer: 1,
      explanation:
      'The substrate is the reactant molecule that binds to an enzyme and is transformed during the reaction.',
      topic: 'Enzyme Basics',
    ),

    QuizQuestion(
      question: 'Where does the substrate usually bind to an enzyme?',
      options: [
        'The nucleus',
        'The active site',
        'The cell wall',
        'The peptide bond',
      ],
      correctAnswer: 1,
      explanation:
      'The active site is the region of an enzyme where the substrate binds and the catalytic reaction occurs.',
      topic: 'Enzyme Structure',
    ),

    QuizQuestion(
      question: 'What is the main function of the active site?',
      options: [
        'Store DNA',
        'Produce ATP directly',
        'Bind the substrate and facilitate the reaction',
        'Destroy the enzyme',
      ],
      correctAnswer: 2,
      explanation:
      'The active site provides a specific environment where the substrate binds and the enzyme helps lower the activation energy.',
      topic: 'Active Site',
    ),

    QuizQuestion(
      question: 'Which model suggests that the active site has a shape complementary to the substrate?',
      options: [
        'Fluid mosaic model',
        'Lock-and-key model',
        'Cell theory',
        'Endosymbiotic model',
      ],
      correctAnswer: 1,
      explanation:
      'The lock-and-key model compares the enzyme and substrate to a lock and its matching key.',
      topic: 'Enzyme Models',
    ),

    QuizQuestion(
      question: 'What does the induced-fit model suggest?',
      options: [
        'Enzymes never change shape',
        'The substrate destroys the enzyme',
        'The enzyme can change shape when the substrate binds',
        'All substrates fit every enzyme',
      ],
      correctAnswer: 2,
      explanation:
      'The induced-fit model proposes that substrate binding can cause conformational changes in the enzyme that improve the interaction.',
      topic: 'Enzyme Models',
    ),

    QuizQuestion(
      question: 'What do enzymes generally do to activation energy?',
      options: [
        'Increase it',
        'Eliminate it completely',
        'Lower it',
        'Convert it into ATP',
      ],
      correctAnswer: 2,
      explanation:
      'Enzymes lower the activation energy required for a reaction, allowing the reaction to proceed faster.',
      topic: 'Catalysis',
    ),

    QuizQuestion(
      question: 'What usually happens to enzyme activity when temperature rises above an enzyme’s optimum?',
      options: [
        'It always increases',
        'It may decrease because the enzyme can lose its functional structure',
        'It becomes exactly 100%',
        'Nothing can happen',
      ],
      correctAnswer: 1,
      explanation:
      'At temperatures above the optimum, excessive heat can disrupt interactions that maintain enzyme structure and reduce activity.',
      topic: 'Factors Affecting Activity',
    ),

    QuizQuestion(
      question: 'What is denaturation?',
      options: [
        'The production of more substrate',
        'A change in protein structure that can impair function',
        'The creation of DNA',
        'The conversion of ATP into glucose',
      ],
      correctAnswer: 1,
      explanation:
      'Denaturation is the disruption of a protein’s functional structure. For enzymes, this can reduce or eliminate catalytic activity.',
      topic: 'Factors Affecting Activity',
    ),

    QuizQuestion(
      question: 'Why does pH affect enzyme activity?',
      options: [
        'pH can affect chemical interactions and the shape or charge of enzyme molecules',
        'pH always creates more enzymes',
        'pH changes DNA into protein',
        'pH has no effect on enzymes',
      ],
      correctAnswer: 0,
      explanation:
      'Changes in pH can alter the charges and interactions within an enzyme, potentially affecting its structure and active site.',
      topic: 'Factors Affecting Activity',
    ),

    QuizQuestion(
      question: 'What generally happens as substrate concentration increases when enzyme concentration is fixed?',
      options: [
        'Activity can increase until the enzymes become saturated',
        'Activity always becomes zero',
        'All enzymes disappear',
        'Temperature automatically decreases',
      ],
      correctAnswer: 0,
      explanation:
      'Increasing substrate concentration can increase reaction rate until most available active sites are occupied.',
      topic: 'Enzyme Kinetics',
    ),

    QuizQuestion(
      question: 'What is enzyme saturation?',
      options: [
        'When all enzymes are destroyed',
        'When most available active sites are occupied by substrate',
        'When the solution freezes',
        'When pH reaches zero',
      ],
      correctAnswer: 1,
      explanation:
      'Enzyme saturation occurs when substrate is abundant enough that most available active sites are occupied.',
      topic: 'Enzyme Kinetics',
    ),

    QuizQuestion(
      question: 'What is a competitive inhibitor?',
      options: [
        'A molecule that competes with the substrate for the active site',
        'A molecule that always destroys the enzyme',
        'A molecule that creates more active sites',
        'A type of product',
      ],
      correctAnswer: 0,
      explanation:
      'A competitive inhibitor can compete with the substrate for access to the enzyme’s active site.',
      topic: 'Enzyme Inhibition',
    ),

    QuizQuestion(
      question: 'Which statement about enzymes is correct?',
      options: [
        'Enzymes are permanently consumed after every reaction',
        'Enzymes change the final equilibrium of every reaction',
        'Enzymes can be reused because they are not consumed by the reaction',
        'Every enzyme works on every substrate',
      ],
      correctAnswer: 2,
      explanation:
      'Enzymes participate in reactions without being permanently consumed, allowing them to catalyze repeated reactions.',
      topic: 'Enzyme Basics',
    ),

    QuizQuestion(
      question: 'Which enzyme breaks down starch into smaller carbohydrates?',
      options: [
        'Lipase',
        'Amylase',
        'Protease',
        'DNA polymerase',
      ],
      correctAnswer: 1,
      explanation:
      'Amylases catalyze the hydrolysis of starch into smaller carbohydrate products.',
      topic: 'Enzymes in Biology',
    ),

    QuizQuestion(
      question: 'Which type of enzyme breaks down proteins?',
      options: [
        'Protease',
        'Lipase',
        'Amylase',
        'Ligase',
      ],
      correctAnswer: 0,
      explanation:
      'Proteases catalyze the breakdown of proteins into smaller peptides or amino acids.',
      topic: 'Enzyme Classes',
    ),

    QuizQuestion(
      question: 'Which type of enzyme breaks down fats?',
      options: [
        'Amylase',
        'Lipase',
        'Protease',
        'Helicase',
      ],
      correctAnswer: 1,
      explanation:
      'Lipases catalyze the hydrolysis of lipids, producing products such as fatty acids and glycerol depending on the substrate.',
      topic: 'Enzyme Classes',
    ),

    QuizQuestion(
      question: 'Why are enzymes important to living organisms?',
      options: [
        'They make every reaction spontaneous',
        'They allow many biochemical reactions to occur fast enough to support life',
        'They replace DNA',
        'They provide all of the cell’s energy directly',
      ],
      correctAnswer: 1,
      explanation:
      'Many biochemical reactions would occur too slowly under normal cellular conditions without enzyme catalysis.',
      topic: 'Enzymes and Life',
    ),

    QuizQuestion(
      question: 'What happens to an enzyme after it catalyzes a reaction?',
      options: [
        'It must always be destroyed',
        'It becomes DNA',
        'It can generally participate in another catalytic cycle',
        'It permanently becomes the product',
      ],
      correctAnswer: 2,
      explanation:
      'Because enzymes are catalysts, they are generally regenerated after the reaction and can participate in additional reaction cycles.',
      topic: 'Enzyme Basics',
    ),
  ];

  // ============================================================
  // STATE
  // ============================================================

  int _currentQuestion = 0;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;

  int? _selectedAnswer;
  bool _answered = false;

  final List<bool> _answerHistory = [];

  // ============================================================
  // GETTERS
  // ============================================================

  QuizQuestion get currentQuizQuestion =>
      _questions[_currentQuestion];

  double get progress =>
      (_currentQuestion + 1) / _questions.length;

  bool get isLastQuestion =>
      _currentQuestion == _questions.length - 1;

  int get xp {
    return _score * 10 + (_bestStreak * 5);
  }

  // ============================================================
  // ANSWER
  // ============================================================

  void _selectAnswer(int index) {
    if (_answered) return;

    final question = currentQuizQuestion;
    final isCorrect = index == question.correctAnswer;

    setState(() {
      _selectedAnswer = index;
      _answered = true;

      _answerHistory.add(isCorrect);

      if (isCorrect) {
        _score++;
        _streak++;

        if (_streak > _bestStreak) {
          _bestStreak = _streak;
        }
      } else {
        _streak = 0;
      }
    });
  }

  // ============================================================
  // NEXT QUESTION
  // ============================================================

  void _nextQuestion() {
    if (!_answered) return;

    if (isLastQuestion) {
      _showResults();
      return;
    }

    setState(() {
      _currentQuestion++;
      _selectedAnswer = null;
      _answered = false;
    });
  }

  // ============================================================
  // SHOW RESULTS
  // ============================================================

  void _showResults() {
    final percentage =
        (_score / _questions.length) * 100;

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
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    gradient: EVLabGradients.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    percentage >= 80
                        ? Icons.emoji_events_rounded
                        : percentage >= 60
                        ? Icons.star_rounded
                        : Icons.school_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  percentage >= 80
                      ? 'Excellent Work!'
                      : percentage >= 60
                      ? 'Good Job!'
                      : 'Keep Learning!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: EVLabColors.textDark,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'You completed the Enzyme Knowledge Challenge.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: EVLabColors.textMedium,
                  ),
                ),

                const SizedBox(height: 22),

                _resultStat(
                  'Score',
                  '$_score / ${_questions.length}',
                  Icons.quiz_rounded,
                  EVLabColors.blue,
                ),

                const SizedBox(height: 10),

                _resultStat(
                  'Accuracy',
                  '${percentage.toStringAsFixed(0)}%',
                  Icons.track_changes_rounded,
                  EVLabColors.emerald,
                ),

                const SizedBox(height: 10),

                _resultStat(
                  'Best Streak',
                  '$_bestStreak',
                  Icons.local_fire_department_rounded,
                  EVLabColors.orange,
                ),

                const SizedBox(height: 10),

                _resultStat(
                  'XP Earned',
                  '+$xp XP',
                  Icons.stars_rounded,
                  EVLabColors.purple,
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _restartQuiz();
                    },
                    icon: const Icon(
                      Icons.refresh_rounded,
                    ),
                    label: const Text(
                      'PLAY AGAIN',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'BACK TO ACADEMY',
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
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 22,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: EVLabColors.textMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RESTART
  // ============================================================

  void _restartQuiz() {
    setState(() {
      _currentQuestion = 0;
      _score = 0;
      _streak = 0;
      _bestStreak = 0;
      _selectedAnswer = null;
      _answered = false;
      _answerHistory.clear();
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final question = currentQuizQuestion;

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
          if (_streak > 0)
            Padding(
              padding: const EdgeInsets.only(
                right: 14,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: EVLabColors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$_streak',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            _buildProgressHeader(),

            Expanded(
              child: SingleChildScrollView(
                physics:
                const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  18,
                  10,
                  18,
                  25,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    _buildTopicBadge(
                      question.topic,
                    ),

                    const SizedBox(height: 14),

                    _buildQuestionCard(
                      question,
                    ),

                    const SizedBox(height: 18),

                    _buildAnswerOptions(
                      question,
                    ),

                    if (_answered) ...[
                      const SizedBox(height: 18),
                      _buildFeedbackCard(
                        question,
                      ),
                    ],

                    const SizedBox(height: 20),

                    if (_answered)
                      _buildNextButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROGRESS HEADER
  // ============================================================

  Widget _buildProgressHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        18,
        4,
        18,
        15,
      ),
      color: EVLabColors.background,
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestion + 1} '
                    'of ${_questions.length}',
                style: const TextStyle(
                  color: EVLabColors.textMedium,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),

              Row(
                children: [
                  const Icon(
                    Icons.stars_rounded,
                    color: EVLabColors.yellow,
                    size: 19,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$_score correct',
                    style: const TextStyle(
                      color: EVLabColors.textDark,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius:
            BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor:
              const Color(0xFFE2E8F0),
              color: EVLabColors.emerald,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOPIC BADGE
  // ============================================================

  Widget _buildTopicBadge(String topic) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: EVLabColors.emerald.withValues(
          alpha: 0.10,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.menu_book_rounded,
            color: EVLabColors.emeraldDark,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            topic,
            style: const TextStyle(
              color: EVLabColors.emeraldDark,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUESTION CARD
  // ============================================================

  Widget _buildQuestionCard(
      QuizQuestion question,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: EVLabGradients.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: EVLabColors.emerald.withValues(
              alpha: 0.18,
            ),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'QUESTION',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.3,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            question.question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                color: Colors.white70,
                size: 17,
              ),
              const SizedBox(width: 6),
              Text(
                'Choose the best answer',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ANSWER OPTIONS
  // ============================================================

  Widget _buildAnswerOptions(
      QuizQuestion question,
      ) {
    return Column(
      children: List.generate(
        question.options.length,
            (index) {
          return Padding(
            padding: const EdgeInsets.only(
              bottom: 11,
            ),
            child: _buildAnswerOption(
              question,
              index,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnswerOption(
      QuizQuestion question,
      int index,
      ) {
    final selected =
        _selectedAnswer == index;

    final correct =
        question.correctAnswer == index;

    Color backgroundColor =
        Colors.white;

    Color borderColor =
    const Color(0xFFE2E8F0);

    Color textColor =
        EVLabColors.textDark;

    IconData? trailingIcon;

    if (_answered && selected) {
      backgroundColor = correct
          ? EVLabColors.success.withValues(alpha: 0.10)
          : EVLabColors.danger.withValues(alpha: 0.10);
      borderColor = correct ? EVLabColors.success : EVLabColors.danger;
      textColor = correct ? EVLabColors.success : EVLabColors.danger;
      trailingIcon = correct
          ? Icons.check_circle_rounded
          : Icons.cancel_rounded;
    } else if (selected) {
      backgroundColor =
          EVLabColors.emerald.withValues(
            alpha: 0.08,
          );

      borderColor =
          EVLabColors.emerald;

      textColor =
          EVLabColors.emeraldDark;
    }

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius:
        BorderRadius.circular(18),
        onTap: () => _selectAnswer(index),
        child: AnimatedContainer(
          duration:
          const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(18),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: borderColor
                      .withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  String.fromCharCode(
                    65 + index,
                  ),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Text(
                  question.options[index],
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    height: 1.35,
                  ),
                ),
              ),

              if (trailingIcon != null)
                Icon(
                  trailingIcon,
                  color: textColor,
                  size: 23,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FEEDBACK
  // ============================================================

  Widget _buildFeedbackCard(
      QuizQuestion question,
      ) {
    final correct =
        _selectedAnswer ==
            question.correctAnswer;

    final color = correct
        ? EVLabColors.success
        : EVLabColors.danger;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.08,
        ),
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(
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
                    : Icons.info_rounded,
                color: color,
                size: 24,
              ),

              const SizedBox(width: 9),

              Text(
                correct
                    ? 'Correct! +10 XP'
                    : 'Not quite!',
                style: TextStyle(
                  color: color,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            question.explanation,
            style: const TextStyle(
              color: EVLabColors.textDark,
              height: 1.5,
              fontSize: 13,
            ),
          ),

          if (correct && _streak >= 2) ...[
            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: EVLabColors.orange,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  '$_streak question streak!',
                  style: const TextStyle(
                    color: EVLabColors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // NEXT BUTTON
  // ============================================================

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _nextQuestion,
        icon: Icon(
          isLastQuestion
              ? Icons.emoji_events_rounded
              : Icons.arrow_forward_rounded,
        ),
        label: Text(
          isLastQuestion
              ? 'SEE MY RESULTS'
              : 'NEXT QUESTION',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
          EVLabColors.emerald,
          foregroundColor:
          Colors.white,
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(17),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// QUIZ QUESTION MODEL
// ================================================================

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;
  final String topic;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.topic,
  });
}