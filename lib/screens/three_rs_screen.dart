import 'package:flutter/material.dart';

import '../data/three_rs_data.dart';
import '../models/three_rs.dart';
import '../services/progress_service.dart';

class ThreeRsScreen extends StatefulWidget {
  const ThreeRsScreen({super.key});

  @override
  State<ThreeRsScreen> createState() => _ThreeRsScreenState();
}

class _ThreeRsScreenState extends State<ThreeRsScreen> {
  int index = 0;
  int? selected;
  bool answered = false;

  ThreeRScenario get scenario => threeRScenarios[index];

  bool get correct => selected == scenario.correctIndex;

  void answer(int i) {
    if (answered) return;

    setState(() {
      selected = i;
    });
  }

  void submit() {
    if (selected == null || answered) return;

    setState(() {
      answered = true;
    });

    ProgressService.instance.completeThreeRScenario(
      correct: correct,
    );
  }

  void next() {
    if (index == threeRScenarios.length - 1) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      index++;
      selected = null;
      answered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = ProgressService.instance;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text(
          'The 3Rs of Responsible Research',
        ),
        backgroundColor: const Color(0xFF173B57),
        foregroundColor: Colors.white,
      ),

      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [

          // ============================================================
          // HEADER
          // ============================================================

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF173B57),
                  Color(0xFF287D7D),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),

            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  '🧬 3Rs LAB',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 6),

                Text(
                  'Make better science with better choices.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  'Replacement • Reduction • Refinement',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ============================================================
          // THREE R CARDS
          // ============================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _rCard(
                ThreeR.replacement,
                'Replace',
                '🔬',
                const Color(0xFF4C6FFF),
              ),

              const SizedBox(width: 8),

              _rCard(
                ThreeR.reduction,
                'Reduce',
                '📉',
                const Color(0xFF00A878),
              ),

              const SizedBox(width: 8),

              _rCard(
                ThreeR.refinement,
                'Refine',
                '🛡️',
                const Color(0xFFFF9F43),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ============================================================
          // PROGRESS
          // ============================================================

          AnimatedBuilder(
            animation: progress,

            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),

                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

                  children: [

                    Text(
                      'Completed: '
                          '${progress.completedThreeRScenarios}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      'XP: ${progress.xp}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF287D7D),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // ============================================================
          // SCENARIO CARD
          // ============================================================

          Card(
            elevation: 2,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),

            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Text(
                    'SCENARIO '
                        '${index + 1} OF '
                        '${threeRScenarios.length}',

                    style: const TextStyle(
                      color: Color(0xFF287D7D),
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    scenario.title,

                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    scenario.situation,

                    style: const TextStyle(
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    scenario.question,

                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ==================================================
                  // ANSWER CHOICES
                  // ==================================================

                  ...List.generate(
                    scenario.choices.length,

                        (i) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: 8,
                      ),

                      child: _choiceButton(i),
                    ),
                  ),

                  // ==================================================
                  // ANSWER EXPLANATION
                  // ==================================================

                  if (answered) ...[

                    const SizedBox(height: 4),

                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(14),

                      decoration: BoxDecoration(
                        color: correct
                            ? const Color(0xFFE7F8EF)
                            : const Color(0xFFFFECEC),

                        borderRadius:
                        BorderRadius.circular(14),

                        border: Border.all(
                          color: correct
                              ? const Color(0xFF8AD8B1)
                              : const Color(0xFFFFB5B5),
                        ),
                      ),

                      child: Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          Icon(
                            correct
                                ? Icons.check_circle
                                : Icons.info_outline,

                            color: correct
                                ? const Color(0xFF168A52)
                                : const Color(0xFFD64545),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              correct
                                  ? 'Correct! +40 XP\n'
                                  '${scenario.explanation}'
                                  : 'Not quite. +15 XP\n'
                                  '${scenario.explanation}',

                              style: const TextStyle(
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // ==================================================
                  // ACTION BUTTON
                  // ==================================================

                  SizedBox(
                    width: double.infinity,

                    child: FilledButton(
                      onPressed: answered
                          ? next
                          : selected == null
                          ? null
                          : submit,

                      style: FilledButton.styleFrom(
                        backgroundColor:
                        const Color(0xFF287D7D),

                        padding:
                        const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                      ),

                      child: Text(
                        answered
                            ? index ==
                            threeRScenarios.length - 1
                            ? 'FINISH'
                            : 'NEXT SCENARIO'
                            : 'CHECK ANSWER',

                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ============================================================
          // SCIENTIFIC BASIS
          // ============================================================

          const Text(
            'Scientific basis',

            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'EV-LAB uses the NIH/OLAW and NCBI descriptions '
                'of the Three Rs. Replacement uses appropriate '
                'alternatives to animals; Reduction aims to use '
                'the minimum number necessary for valid science; '
                'Refinement minimizes pain, distress, or lasting '
                'harm and improves welfare.',

            style: TextStyle(
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ==============================================================
  // ANSWER BUTTON
  // ==============================================================

  Widget _choiceButton(int i) {
    final isSelected = selected == i;

    Color borderColor = Colors.grey.shade300;
    Color backgroundColor = Colors.white;

    if (answered && isSelected) {
      if (correct) {
        borderColor = const Color(0xFF168A52);
        backgroundColor = const Color(0xFFE7F8EF);
      } else {
        borderColor = const Color(0xFFD64545);
        backgroundColor = const Color(0xFFFFECEC);
      }
    } else if (isSelected) {
      borderColor = const Color(0xFF287D7D);
      backgroundColor = const Color(0xFFE8F5F5);
    }

    return OutlinedButton(
      onPressed: answered
          ? null
          : () => answer(i),

      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.black87,
        disabledForegroundColor: Colors.black87,

        side: BorderSide(
          color: borderColor,
          width: isSelected ? 2 : 1,
        ),

        padding: const EdgeInsets.all(14),

        alignment: Alignment.centerLeft,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      child: Row(
        children: [

          Icon(
            isSelected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,

            color: isSelected
                ? const Color(0xFF287D7D)
                : Colors.grey,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              scenario.choices[i],

              style: const TextStyle(
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // 3R CARD
  // ==============================================================

  Widget _rCard(
      ThreeR r,
      String title,
      String icon,
      Color color,
      ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),

        child: Column(
          children: [

            Text(
              icon,

              style: const TextStyle(
                fontSize: 24,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              title,

              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              threeRDefinition(r),

              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,

              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}