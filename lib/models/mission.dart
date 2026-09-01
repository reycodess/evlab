import 'package:evlab/models/inhibitor.dart';

class Mission {
  final int id;
  final String title;
  final String description;
  final String objective;
  final String enzymeName;

  final double targetTemperature;
  final double targetPh;
  final double targetSubstrate;

  final InhibitionType inhibitorType;
  final double inhibitorRatio;

  final double tolerance;
  final int xpReward;

  final String difficulty;
  final String hint;

  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.objective,
    required this.enzymeName,
    required this.targetTemperature,
    required this.targetPh,
    required this.targetSubstrate,
    required this.inhibitorType,
    required this.inhibitorRatio,
    required this.tolerance,
    required this.xpReward,
    required this.difficulty,
    required this.hint,
  });
}