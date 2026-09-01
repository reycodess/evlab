enum ThreeR { replacement, reduction, refinement }

class ThreeRScenario {
  final String title, situation, question, explanation;
  final ThreeR principle;
  final List<String> choices;
  final int correctIndex;
  const ThreeRScenario({required this.title, required this.situation, required this.question, required this.explanation, required this.principle, required this.choices, required this.correctIndex});
}
