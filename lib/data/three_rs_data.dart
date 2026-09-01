import '../models/three_rs.dart';

const threeRScenarios = <ThreeRScenario>[
  ThreeRScenario(
    title: 'Choose a safer model',
    situation: 'A researcher needs to study enzyme inhibition and can obtain the same mechanistic information with a validated cell-free biochemical assay.',
    question: 'Which 3R principle is the strongest match?',
    explanation: 'Replacement means using an appropriate non-animal method when it can answer the scientific question. Cell-free biochemical assays and computer models are examples of alternative approaches.',
    principle: ThreeR.replacement,
    choices: ['Replacement', 'Reduction', 'Refinement', 'None of the above'],
    correctIndex: 0,
  ),
  ThreeRScenario(
    title: 'Plan fewer experiments',
    situation: 'A team plans an enzyme experiment. Instead of repeating many unnecessary conditions, they use pilot data and statistical planning to select the smallest set of trials that can answer the hypothesis.',
    question: 'Which 3R principle is being applied?',
    explanation: 'Reduction focuses on obtaining valid scientific information with the fewest animals necessary. Careful experimental design and statistical planning support this goal.',
    principle: ThreeR.reduction,
    choices: ['Replacement', 'Reduction', 'Refinement', 'Randomization only'],
    correctIndex: 1,
  ),
  ThreeRScenario(
    title: 'Improve welfare',
    situation: 'When animal use cannot be replaced, researchers improve procedures, monitoring, housing, and handling to minimize pain and distress.',
    question: 'Which 3R principle is this?',
    explanation: 'Refinement means modifying procedures or care to minimize pain, distress, or lasting harm and improve animal well-being.',
    principle: ThreeR.refinement,
    choices: ['Replacement', 'Reduction', 'Refinement', 'Replication'],
    correctIndex: 2,
  ),
];

String threeRName(ThreeR r) => switch (r) { ThreeR.replacement => 'Replacement', ThreeR.reduction => 'Reduction', ThreeR.refinement => 'Refinement' };
String threeRDefinition(ThreeR r) => switch (r) {
  ThreeR.replacement => 'Use an appropriate alternative to animal models whenever the scientific question can be answered without animals.',
  ThreeR.reduction => 'Design studies so that the fewest animals necessary are used while preserving valid, rigorous results.',
  ThreeR.refinement => 'Improve procedures and care to minimize pain, distress, or lasting harm and improve animal welfare.',
};
