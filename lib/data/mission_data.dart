import 'package:evlab/models/inhibitor.dart';
import '../models/mission.dart';

class MissionData {
  static const List<Mission> missions = [
    // ============================================================
    // LEVEL 1
    // ============================================================

    Mission(
      id: 1,
      title: 'The Perfect Temperature',
      description:
      'Amylase is not working efficiently. Your first task is to find a temperature where the enzyme works best.',
      objective:
      'Adjust the temperature close to the enzyme\'s optimum temperature.',
      enzymeName: 'Amylase',
      targetTemperature: 40,
      targetPh: 8,
      targetSubstrate: 5,
      inhibitorType: InhibitionType.none,
      inhibitorRatio: 0,
      tolerance: 2,
      xpReward: 100,
      difficulty: 'Beginner',
      hint:
      'Enzymes usually have an optimum temperature where their activity is highest.',
    ),

    // ============================================================
    // LEVEL 2
    // ============================================================

    Mission(
      id: 2,
      title: 'Find the Right pH',
      description:
      'The enzyme is placed in an environment that is too acidic or too basic. Adjust the pH to improve its activity.',
      objective:
      'Find a pH close to the optimum pH of the enzyme.',
      enzymeName: 'Amylase',
      targetTemperature: 40,
      targetPh: 8,
      targetSubstrate: 5,
      inhibitorType: InhibitionType.none,
      inhibitorRatio: 0,
      tolerance: 0.5,
      xpReward: 150,
      difficulty: 'Beginner',
      hint:
      'Changing pH can alter the shape and charge of an enzyme, affecting its activity.',
    ),

    // ============================================================
    // LEVEL 3
    // ============================================================

    Mission(
      id: 3,
      title: 'Feed the Enzyme',
      description:
      'The enzyme does not have enough substrate available. Find a suitable substrate concentration.',
      objective:
      'Adjust the substrate concentration to increase reaction rate.',
      enzymeName: 'Amylase',
      targetTemperature: 40,
      targetPh: 8,
      targetSubstrate: 10,
      inhibitorType: InhibitionType.none,
      inhibitorRatio: 0,
      tolerance: 1,
      xpReward: 200,
      difficulty: 'Intermediate',
      hint:
      'Increasing substrate concentration generally increases reaction rate until the enzyme approaches saturation.',
    ),

    // ============================================================
    // LEVEL 4
    // ============================================================

    Mission(
      id: 4,
      title: 'The Enzyme Sabotage',
      description:
      'Something is interfering with the enzyme. Identify and control the inhibitor.',
      objective:
      'Investigate the effect of a competitive inhibitor.',
      enzymeName: 'Amylase',
      targetTemperature: 40,
      targetPh: 8,
      targetSubstrate: 10,
      inhibitorType: InhibitionType.competitive,
      inhibitorRatio: 1,
      tolerance: 0.2,
      xpReward: 250,
      difficulty: 'Intermediate',
      hint:
      'A competitive inhibitor competes with the substrate for the enzyme\'s active site.',
    ),

    // ============================================================
    // LEVEL 5
    // ============================================================

    Mission(
      id: 5,
      title: 'Save the Reaction',
      description:
      'The reaction is being strongly inhibited. Your mission is to determine how the inhibitor affects enzyme activity.',
      objective:
      'Compare enzyme activity with and without a noncompetitive inhibitor.',
      enzymeName: 'Catalase',
      targetTemperature: 25,
      targetPh: 7,
      targetSubstrate: 25,
      inhibitorType: InhibitionType.noncompetitive,
      inhibitorRatio: 1,
      tolerance: 0.2,
      xpReward: 300,
      difficulty: 'Advanced',
      hint:
      'Noncompetitive inhibition decreases the effective Vmax of the reaction.',
    ),

    // ============================================================
    // LEVEL 6
    // ============================================================

    Mission(
      id: 6,
      title: 'The Complete Experiment',
      description:
      'Everything is wrong: temperature, pH, substrate concentration, and inhibition. Fix the experiment.',
      objective:
      'Optimize the experimental conditions and maximize enzyme activity.',
      enzymeName: 'Catalase',
      targetTemperature: 25,
      targetPh: 7,
      targetSubstrate: 50,
      inhibitorType: InhibitionType.none,
      inhibitorRatio: 0,
      tolerance: 2,
      xpReward: 500,
      difficulty: 'Expert',
      hint:
      'Consider all four factors together. Temperature, pH, substrate concentration, and inhibitors can all affect enzyme activity.',
    ),
  ];

  static Mission getMission(int id) {
    return missions.firstWhere(
          (mission) => mission.id == id,
      orElse: () => missions.first,
    );
  }
}