import 'dart:math';

import 'package:evlab/models/enzyme.dart';
import 'package:evlab/models/inhibitor.dart';

/// ===============================================================
/// EV-LAB ENZYME SIMULATION ENGINE
/// ===============================================================
///
/// Scientific simulation engine for the EV-LAB Virtual Laboratory.
///
/// Simulated factors:
///   1. Temperature
///   2. pH
///   3. Substrate concentration
///   4. Inhibitor presence
///
/// The engine produces:
///   - Relative enzyme activity (%)
///   - Individual factor effects
///   - Scientific explanations
///   - Graph-ready simulation points
///   - Michaelis-Menten calculations
///   - Inhibitor comparisons
///
/// IMPORTANT:
/// Activity values are relative calculated simulation values.
/// They are NOT direct measurements from a physical laboratory.
/// ===============================================================

class EnzymeSimulationResult {
  final double activity;

  final double temperatureEffect;
  final double phEffect;
  final double substrateEffect;
  final double inhibitorEffect;

  final String temperatureExplanation;
  final String phExplanation;
  final String substrateExplanation;
  final String inhibitorExplanation;

  final String overallExplanation;

  const EnzymeSimulationResult({
    required this.activity,
    required this.temperatureEffect,
    required this.phEffect,
    required this.substrateEffect,
    required this.inhibitorEffect,
    required this.temperatureExplanation,
    required this.phExplanation,
    required this.substrateExplanation,
    required this.inhibitorExplanation,
    required this.overallExplanation,
  });
}

class EnzymeSimulation {
  // =============================================================
  // MAIN SIMULATION
  // =============================================================

  static EnzymeSimulationResult simulate({
    required Enzyme enzyme,
    required double temperature,
    required double ph,
    required double substrate,
    required bool inhibitor,
  }) {
    final temperatureEffect = _calculateTemperatureEffect(
      enzyme,
      temperature,
    );

    final phEffect = _calculatePhEffect(
      enzyme,
      ph,
    );

    final substrateEffect = _calculateSubstrateEffect(
      enzyme,
      substrate,
    );

    final inhibitorEffect = _calculateInhibitorEffect(
      inhibitor,
    );

    // -----------------------------------------------------------
    // Relative activity calculation
    // -----------------------------------------------------------
    //
    // Activity is represented as a percentage of the maximum
    // simulated activity.
    //
    // 100% = maximum activity under the model.
    //
    // Each factor contributes multiplicatively:
    //
    // Activity =
    // Temperature × pH × Substrate × Inhibitor × 100
    //
    // -----------------------------------------------------------

    double activity =
        100.0 *
            temperatureEffect *
            phEffect *
            substrateEffect *
            inhibitorEffect;

    activity = safeActivity(activity);

    return EnzymeSimulationResult(
      activity: activity,
      temperatureEffect: temperatureEffect,
      phEffect: phEffect,
      substrateEffect: substrateEffect,
      inhibitorEffect: inhibitorEffect,
      temperatureExplanation: _temperatureExplanation(
        enzyme,
        temperature,
        temperatureEffect,
      ),
      phExplanation: _phExplanation(
        enzyme,
        ph,
        phEffect,
      ),
      substrateExplanation: _substrateExplanation(
        enzyme,
        substrate,
        substrateEffect,
      ),
      inhibitorExplanation: _inhibitorExplanation(
        inhibitor,
        inhibitorEffect,
      ),
      overallExplanation: _overallExplanation(
        enzyme,
        temperature,
        ph,
        substrate,
        inhibitor,
        activity,
        temperatureEffect,
        phEffect,
        substrateEffect,
        inhibitorEffect,
      ),
    );
  }

  // =============================================================
  // VIRTUAL LAB INTEGRATION
  // =============================================================
  //
  // This is the single entry point used by the interactive laboratory.
  // Temperature and pH use the enzyme's supplied reference curves with
  // linear interpolation; substrate follows Michaelis-Menten kinetics;
  // inhibition changes the kinetic parameters according to its mechanism.
  // =============================================================

  static EnzymeSimulationResult simulateVirtualLab({
    required Enzyme enzyme,
    required double temperature,
    required double ph,
    required double substrate,
    required InhibitionType inhibitorType,
    required double inhibitorRatio,
  }) {
    final temperatureEffect = enzyme.temperatureActivity.isNotEmpty
        ? _interpolateCurve(enzyme.temperatureActivity, temperature)
        : _smoothTemperatureEffect(enzyme, temperature);

    final phEffect = enzyme.phActivity.isNotEmpty
        ? _interpolateCurve(enzyme.phActivity, ph)
        : _smoothPhEffect(enzyme, ph);

    final safeSubstrate = substrate.clamp(0.0, double.infinity).toDouble();
    final safeKm = enzyme.km <= 0 ? 0.000001 : enzyme.km;
    final safeVmax = enzyme.vmax <= 0 ? 0.0 : enzyme.vmax;
    final ratio = inhibitorRatio.clamp(0.0, double.infinity).toDouble();

    double alpha = 1.0;
    double alphaPrime = 1.0;

    switch (inhibitorType) {
      case InhibitionType.none:
        break;
      case InhibitionType.competitive:
        alpha = 1.0 + ratio;
        break;
      case InhibitionType.noncompetitive:
        alpha = 1.0 + ratio;
        alphaPrime = 1.0 + ratio;
        break;
      case InhibitionType.uncompetitive:
        alphaPrime = 1.0 + ratio;
        break;
      case InhibitionType.mixed:
        // General mixed inhibition allows different affinities for free
        // enzyme and the enzyme-substrate complex. EV-LAB does not ask the
        // learner for a second Ki, so the UI uses an explicit educational
        // asymmetry: alpha = 1 + [I]/Ki and alpha' = 1 + 0.5[I]/Ki.
        // This preserves the correct mixed-inhibition equation while making
        // the assumption visible rather than incorrectly treating mixed
        // inhibition as pure noncompetitive inhibition.
        alpha = 1.0 + ratio;
        alphaPrime = 1.0 + (ratio * 0.5);
        break;
    }

    final denominator =
        (alpha * safeKm) + (alphaPrime * safeSubstrate);

    final reactionRate = safeVmax <= 0 || safeSubstrate <= 0
        ? 0.0
        : safeVmax * safeSubstrate / denominator;

    final double kineticFactor = safeVmax <= 0
        ? 0.0
        : (reactionRate / safeVmax).clamp(0.0, 1.0).toDouble();

    final activity = safeActivity(
      100.0 * temperatureEffect * phEffect * kineticFactor,
    );

    final inhibitorFactor = inhibitorType == InhibitionType.none
        ? 1.0
        : (reactionRate <= 0
            ? 0.0
            : (
                _baseMichaelisMenten(safeSubstrate, safeKm) <= 0
                    ? 0.0
                    : reactionRate /
                        (safeVmax *
                            _baseMichaelisMenten(safeSubstrate, safeKm))
              ).clamp(0.0, 1.0).toDouble());

    return EnzymeSimulationResult(
      activity: activity,
      temperatureEffect: temperatureEffect,
      phEffect: phEffect,
      substrateEffect: kineticFactor,
      inhibitorEffect: inhibitorFactor,
      temperatureExplanation: 'Temperature response uses the enzyme-specific reference curve when available.',
      phExplanation: 'pH response uses the enzyme-specific reference curve when available.',
      substrateExplanation: 'Substrate response follows Michaelis-Menten saturation behavior.',
      inhibitorExplanation: inhibitorType == InhibitionType.none
          ? 'No inhibitor is present.'
          : 'The selected inhibition mechanism changes the apparent kinetic parameters.',
      overallExplanation: 'The laboratory result combines temperature, pH, substrate kinetics, and the selected inhibition mechanism.',
    );
  }

  static double _baseMichaelisMenten(double substrate, double km) {
    if (substrate <= 0 || km <= 0) return 0.0;
    return substrate / (km + substrate);
  }

  static double _interpolateCurve(Map<double, double> data, double value) {
    final points = data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    if (points.isEmpty) return 1.0;
    // A reference dataset describes a measured range, not a flat response
    // outside that range. Extend the edge slope so extreme temperature and pH
    // values reduce activity instead of remaining artificially constant.
    if (points.length == 1) {
      return points.first.value.clamp(0.0, 1.0).toDouble();
    }
    if (value <= points.first.key) {
      return _extrapolate(points[0], points[1], value);
    }
    if (value >= points.last.key) {
      return _extrapolate(
        points[points.length - 2],
        points.last,
        value,
      );
    }

    for (var i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      if (value >= a.key && value <= b.key) {
        final span = b.key - a.key;
        if (span == 0) return a.value.clamp(0.0, 1.0).toDouble();
        final t = (value - a.key) / span;
        return (a.value + (b.value - a.value) * t).clamp(0.0, 1.0).toDouble();
      }
    }
    return 1.0;
  }

  static double _extrapolate(
    MapEntry<double, double> first,
    MapEntry<double, double> second,
    double value,
  ) {
    final span = second.key - first.key;
    if (span == 0) return first.value.clamp(0.0, 1.0).toDouble();
    final slope = (second.value - first.value) / span;
    return (first.value + slope * (value - first.key))
        .clamp(0.0, 1.0)
        .toDouble();
  }

  static double _smoothTemperatureEffect(Enzyme enzyme, double temperature) {
    final optimum = _extractOptimumTemperature(enzyme.optimumTemperature);
    if (optimum <= 0) return 1.0;
    final d = temperature - optimum;
    return exp(-(d * d) / (2.0 * 15.0 * 15.0)).clamp(0.0, 1.0).toDouble();
  }

  static double _smoothPhEffect(Enzyme enzyme, double ph) {
    final optimum = _extractOptimumPH(enzyme.optimumPH);
    if (optimum <= 0) return 1.0;
    final d = ph - optimum;
    return exp(-(d * d) / (2.0 * 2.0 * 2.0)).clamp(0.0, 1.0).toDouble();
  }

  // =============================================================
  // COMPATIBILITY METHOD
  // =============================================================

  static double calculateActivity({
    required Enzyme enzyme,
    required double temperature,
    required double ph,
    required double substrate,
    required bool inhibitor,
  }) {
    return simulate(
      enzyme: enzyme,
      temperature: temperature,
      ph: ph,
      substrate: substrate,
      inhibitor: inhibitor,
    ).activity;
  }

  // =============================================================
  // TEMPERATURE EFFECT
  // =============================================================

  static double _calculateTemperatureEffect(
      Enzyme enzyme,
      double temperature,
      ) {
    final optimum = _extractOptimumTemperature(
      enzyme.optimumTemperature,
    );

    if (optimum <= 0) return 1.0;

    final delta = temperature - optimum;

    // Smooth response below the optimum.
    if (delta <= 0) {
      return (1.0 - (delta.abs() / 22.0) * 0.70)
          .clamp(0.10, 1.0);
    }

    // Faster loss above optimum to represent thermal instability.
    return (1.0 - (delta / 13.0) * 0.90)
        .clamp(0.05, 1.0);
  }

  // =============================================================
  // pH EFFECT
  // =============================================================

  static double _calculatePhEffect(
      Enzyme enzyme,
      double ph,
      ) {
    final optimum = _extractOptimumPH(
      enzyme.optimumPH,
    );

    if (optimum <= 0) return 1.0;

    final distance = (ph - optimum).abs();

    if (distance <= 0.20) return 1.0;
    if (distance <= 0.60) {
      return (1.0 - ((distance - 0.20) / 0.40) * 0.15)
          .clamp(0.05, 1.0);
    }
    if (distance <= 1.20) {
      return (0.85 - ((distance - 0.60) / 0.60) * 0.30)
          .clamp(0.05, 0.85);
    }

    return (0.55 - ((distance - 1.20) / 2.0) * 0.40)
        .clamp(0.05, 0.55);
  }

  // =============================================================
  // SUBSTRATE EFFECT
  // =============================================================
  //
  // Michaelis-Menten equation:
  //
  // v = Vmax[S] / (Km + [S])
  //
  // For the relative activity calculation, the normalized
  // relationship is:
  //
  // v / Vmax = [S] / (Km + [S])
  //
  // Therefore the returned value is between 0 and 1.
  // =============================================================

  static double _calculateSubstrateEffect(
      Enzyme enzyme,
      double substrate,
      ) {
    if (substrate <= 0) {
      return 0.0;
    }

    final km = enzyme.km;

    if (km <= 0) {
      return 1.0;
    }

    final result = substrate / (km + substrate);

    return result.clamp(0.0, 1.0);
  }

  // =============================================================
  // INHIBITOR EFFECT
  // =============================================================

  static double _calculateInhibitorEffect(
      bool inhibitor,
      ) {
    if (!inhibitor) {
      return 1.0;
    }

    // Simulation assumption:
    // inhibitor presence reduces relative activity by 50%.
    return 0.50;
  }

  // =============================================================
  // OPTIMUM TEMPERATURE PARSER
  // =============================================================

  static double _extractOptimumTemperature(
      String value,
      ) {
    final matches = RegExp(
      r'[-+]?\d*\.?\d+',
    ).allMatches(value);

    if (matches.isEmpty) {
      return 0.0;
    }

    final numbers = matches
        .map(
          (match) => double.tryParse(
        match.group(0) ?? '',
      ),
    )
        .whereType<double>()
        .toList();

    if (numbers.isEmpty) {
      return 0.0;
    }

    // If a range is supplied, use the midpoint.
    if (numbers.length >= 2) {
      return (numbers[0] + numbers[1]) / 2;
    }

    return numbers.first;
  }

  // =============================================================
  // OPTIMUM pH PARSER
  // =============================================================

  static double _extractOptimumPH(
      String value,
      ) {
    final matches = RegExp(
      r'[-+]?\d*\.?\d+',
    ).allMatches(value);

    if (matches.isEmpty) {
      return 0.0;
    }

    final numbers = matches
        .map(
          (match) => double.tryParse(
        match.group(0) ?? '',
      ),
    )
        .whereType<double>()
        .toList();

    if (numbers.isEmpty) {
      return 0.0;
    }

    if (numbers.length >= 2) {
      return (numbers[0] + numbers[1]) / 2;
    }

    return numbers.first;
  }

  // =============================================================
  // TEMPERATURE EXPLANATION
  // =============================================================

  static String _temperatureExplanation(
      Enzyme enzyme,
      double temperature,
      double effect,
      ) {
    final optimum = _extractOptimumTemperature(
      enzyme.optimumTemperature,
    );

    if (temperature < optimum - 5.0) {
      return 'The temperature is below the approximate optimum '
          'temperature of ${optimum.toStringAsFixed(1)} °C. '
          'Lower temperatures generally reduce molecular motion, '
          'which can decrease the frequency of effective '
          'enzyme-substrate collisions.';
    }

    if (temperature > optimum + 5.0) {
      return 'The temperature is above the approximate optimum '
          'temperature of ${optimum.toStringAsFixed(1)} °C. '
          'Temperatures above the optimum can disrupt the enzyme '
          'structure and reduce catalytic activity.';
    }

    if (effect >= 0.90) {
      return 'The temperature is close to the enzyme optimum of '
          '${optimum.toStringAsFixed(1)} °C. The simulation therefore '
          'applies a favorable temperature effect.';
    }

    return 'The temperature is moderately different from the '
        'enzyme optimum. The simulation therefore applies a '
        'partial reduction in relative enzyme activity.';
  }

  // =============================================================
  // pH EXPLANATION
  // =============================================================

  static String _phExplanation(
      Enzyme enzyme,
      double ph,
      double effect,
      ) {
    final optimum = _extractOptimumPH(
      enzyme.optimumPH,
    );

    if ((ph - optimum).abs() <= 0.5) {
      return 'The pH is close to the enzyme\'s approximate optimum '
          'of ${optimum.toStringAsFixed(2)}. This provides a more '
          'favorable chemical environment for maintaining the '
          'active site and supporting catalysis.';
    }

    if (ph < optimum) {
      return 'The pH is more acidic than the enzyme\'s approximate '
          'optimum. Changes in hydrogen-ion concentration can '
          'alter charged groups on amino acids and affect the '
          'active site, reducing activity.';
    }

    return 'The pH is more basic than the enzyme\'s approximate '
        'optimum. Changes in hydrogen-ion concentration can '
        'alter the chemical environment and structure of the '
        'active site, reducing activity.';
  }

  // =============================================================
  // SUBSTRATE EXPLANATION
  // =============================================================

  static String _substrateExplanation(
      Enzyme enzyme,
      double substrate,
      double effect,
      ) {
    if (substrate <= 0) {
      return 'No substrate is available, so enzyme-substrate '
          'complexes cannot form and the simulated reaction '
          'activity is zero.';
    }

    final km = enzyme.km;

    if (km <= 0) {
      return 'The enzyme does not have a valid Km value in the '
          'current model, so substrate saturation cannot be '
          'calculated using the Michaelis-Menten relationship.';
    }

    if (substrate < km) {
      return 'The substrate concentration is below the enzyme\'s '
          'Km value of ${km.toStringAsFixed(3)}. The enzyme is '
          'therefore operating below half of its modeled '
          'maximum substrate-dependent rate, and increasing '
          'substrate can substantially increase the reaction rate.';
    }

    if (substrate >= km * 3.0) {
      return 'The substrate concentration is relatively high '
          'compared with the enzyme\'s Km. The enzyme is '
          'approaching substrate saturation, so additional '
          'substrate produces progressively smaller increases '
          'in the modeled reaction rate.';
    }

    return 'The substrate concentration is in an intermediate '
        'range relative to the enzyme\'s Km. Increasing substrate '
        'can still increase the modeled reaction rate according '
        'to Michaelis-Menten behavior.';
  }

  // =============================================================
  // INHIBITOR EXPLANATION
  // =============================================================

  static String _inhibitorExplanation(
      bool inhibitor,
      double effect,
      ) {
    if (inhibitor) {
      return 'An inhibitor is present in this simulation. The '
          'model applies a 50% relative activity factor to '
          'represent inhibition of the enzyme reaction.';
    }

    return 'No inhibitor is present. The simulation therefore '
        'does not apply an inhibitor-related reduction to the '
        'reaction rate.';
  }

  // =============================================================
  // OVERALL EXPLANATION
  // =============================================================

  static String _overallExplanation(
      Enzyme enzyme,
      double temperature,
      double ph,
      double substrate,
      bool inhibitor,
      double activity,
      double temperatureEffect,
      double phEffect,
      double substrateEffect,
      double inhibitorEffect,
      ) {
    final factors = <String>[];

    // Temperature
    if (temperatureEffect >= 0.90) {
      factors.add('temperature was favorable');
    } else if (temperatureEffect < 0.50) {
      factors.add('temperature strongly reduced activity');
    } else {
      factors.add('temperature moderately affected activity');
    }

    // pH
    if (phEffect >= 0.90) {
      factors.add('pH was favorable');
    } else if (phEffect < 0.50) {
      factors.add('pH strongly reduced activity');
    } else {
      factors.add('pH moderately affected activity');
    }

    // Substrate
    if (substrateEffect >= 0.75) {
      factors.add(
        'substrate concentration supported a high '
            'substrate-dependent reaction rate',
      );
    } else if (substrateEffect < 0.30) {
      factors.add(
        'substrate concentration limited the '
            'substrate-dependent reaction rate',
      );
    } else {
      factors.add(
        'substrate concentration produced an '
            'intermediate substrate-dependent reaction rate',
      );
    }

    // Inhibitor
    if (inhibitor) {
      factors.add(
        'the inhibitor reduced the simulated activity',
      );
    }

    String activityLevel;

    if (activity <= 0) {
      activityLevel = 'negligible';
    } else if (activity < 25) {
      activityLevel = 'very low';
    } else if (activity < 50) {
      activityLevel = 'low';
    } else if (activity < 75) {
      activityLevel = 'moderate';
    } else if (activity < 90) {
      activityLevel = 'high';
    } else {
      activityLevel = 'very high';
    }

    return 'The simulated ${enzyme.name} activity is '
        '${activity.toStringAsFixed(1)}%, representing '
        '$activityLevel relative activity under the selected '
        'conditions. The main modeled effects were that '
        '${factors.join(', ')}. The final value is calculated '
        'by combining the temperature, pH, substrate, and '
        'inhibitor factors in the simulation model.';
  }

  // =============================================================
  // INDIVIDUAL FACTOR ACCESS
  // =============================================================

  static double temperatureFactor({
    required Enzyme enzyme,
    required double temperature,
  }) {
    return _calculateTemperatureEffect(
      enzyme,
      temperature,
    );
  }

  static double phFactor({
    required Enzyme enzyme,
    required double ph,
  }) {
    return _calculatePhEffect(
      enzyme,
      ph,
    );
  }

  static double substrateFactor({
    required Enzyme enzyme,
    required double substrate,
  }) {
    return _calculateSubstrateEffect(
      enzyme,
      substrate,
    );
  }

  static double inhibitorFactor({
    required bool inhibitor,
  }) {
    return _calculateInhibitorEffect(
      inhibitor,
    );
  }

  // =============================================================
  // MICHAELIS-MENTEN CALCULATION
  // =============================================================

  static double michaelisMenten({
    required double substrate,
    required double km,
    required double vmax,
  }) {
    if (substrate <= 0 || km <= 0 || vmax <= 0) {
      return 0.0;
    }

    return (vmax * substrate) / (km + substrate);
  }

  // =============================================================
  // NORMALIZED MICHAELIS-MENTEN ACTIVITY
  // =============================================================

  static double normalizedSubstrateActivity({
    required double substrate,
    required double km,
  }) {
    if (substrate <= 0 || km <= 0) {
      return 0.0;
    }

    return (substrate / (km + substrate)).clamp(
      0.0,
      1.0,
    );
  }

  // =============================================================
  // TEMPERATURE CURVE
  // =============================================================

  static List<SimulationPoint> generateTemperatureCurve({
    required Enzyme enzyme,
    required double minimum,
    required double maximum,
    double step = 1.0,
    required double ph,
    required double substrate,
    required bool inhibitor,
  }) {
    final points = <SimulationPoint>[];

    if (step <= 0 || maximum < minimum) {
      return points;
    }

    for (
    double temperature = minimum;
    temperature <= maximum;
    temperature += step
    ) {
      final result = simulate(
        enzyme: enzyme,
        temperature: temperature,
        ph: ph,
        substrate: substrate,
        inhibitor: inhibitor,
      );

      points.add(
        SimulationPoint(
          x: temperature,
          y: result.activity,
        ),
      );
    }

    return points;
  }

  // =============================================================
  // pH CURVE
  // =============================================================

  static List<SimulationPoint> generatePhCurve({
    required Enzyme enzyme,
    required double minimum,
    required double maximum,
    double step = 0.1,
    required double temperature,
    required double substrate,
    required bool inhibitor,
  }) {
    final points = <SimulationPoint>[];

    if (step <= 0 || maximum < minimum) {
      return points;
    }

    for (
    double ph = minimum;
    ph <= maximum + 0.000001;
    ph += step
    ) {
      final result = simulate(
        enzyme: enzyme,
        temperature: temperature,
        ph: ph,
        substrate: substrate,
        inhibitor: inhibitor,
      );

      points.add(
        SimulationPoint(
          x: double.parse(ph.toStringAsFixed(4)),
          y: result.activity,
        ),
      );
    }

    return points;
  }

  // =============================================================
  // SUBSTRATE CURVE
  // =============================================================

  static List<SimulationPoint> generateSubstrateCurve({
    required Enzyme enzyme,
    required double minimum,
    required double maximum,
    double step = 0.5,
    required double temperature,
    required double ph,
    required bool inhibitor,
  }) {
    final points = <SimulationPoint>[];

    if (step <= 0 || maximum < minimum) {
      return points;
    }

    for (
    double substrate = minimum;
    substrate <= maximum + 0.000001;
    substrate += step
    ) {
      final result = simulate(
        enzyme: enzyme,
        temperature: temperature,
        ph: ph,
        substrate: substrate,
        inhibitor: inhibitor,
      );

      points.add(
        SimulationPoint(
          x: double.parse(
            substrate.toStringAsFixed(4),
          ),
          y: result.activity,
        ),
      );
    }

    return points;
  }

  // =============================================================
  // INHIBITOR COMPARISON
  // =============================================================

  static Map<String, double> compareInhibitor({
    required Enzyme enzyme,
    required double temperature,
    required double ph,
    required double substrate,
  }) {
    final withoutInhibitor = simulate(
      enzyme: enzyme,
      temperature: temperature,
      ph: ph,
      substrate: substrate,
      inhibitor: false,
    );

    final withInhibitor = simulate(
      enzyme: enzyme,
      temperature: temperature,
      ph: ph,
      substrate: substrate,
      inhibitor: true,
    );

    return {
      'withoutInhibitor': withoutInhibitor.activity,
      'withInhibitor': withInhibitor.activity,
      'difference':
      withoutInhibitor.activity - withInhibitor.activity,
    };
  }

  // =============================================================
  // ACTIVITY CATEGORY
  // =============================================================

  static String activityCategory(
      double activity,
      ) {
    if (activity <= 0) {
      return 'No Activity';
    }

    if (activity < 25) {
      return 'Very Low';
    }

    if (activity < 50) {
      return 'Low';
    }

    if (activity < 75) {
      return 'Moderate';
    }

    if (activity < 90) {
      return 'High';
    }

    return 'Very High';
  }

  // =============================================================
  // SAFE ACTIVITY
  // =============================================================

  /// Public interpolation helpers for scientific graph widgets.
  static double temperatureFactorForCurve(Enzyme enzyme, double temperature) {
    if (enzyme.temperatureActivity.isNotEmpty) {
      return _interpolateCurve(enzyme.temperatureActivity, temperature);
    }
    return _smoothTemperatureEffect(enzyme, temperature);
  }

  static double phFactorForCurve(Enzyme enzyme, double ph) {
    if (enzyme.phActivity.isNotEmpty) {
      return _interpolateCurve(enzyme.phActivity, ph);
    }
    return _smoothPhEffect(enzyme, ph);
  }

  static double safeActivity(
      double value,
      ) {
    if (value.isNaN || value.isInfinite) {
      return 0.0;
    }

    return value.clamp(0.0, 100.0);
  }
}

/// ===============================================================
/// GRAPH DATA POINT
/// ===============================================================

class SimulationPoint {
  final double x;
  final double y;

  const SimulationPoint({
    required this.x,
    required this.y,
  });
}
