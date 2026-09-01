import 'dart:math';

/// ============================================================================
/// EV-LAB SCIENTIFIC SIMULATION ENGINE
/// ============================================================================
///
/// Calculates relative enzyme activity from:
///   1. Temperature
///   2. pH
///   3. Substrate concentration
///   4. Inhibitor concentration
///
/// Kinetic model:
///   - Michaelis-Menten kinetics
///   - Competitive inhibition using [I]/Ki
///   - Temperature response factor
///   - pH response factor
///
/// IMPORTANT:
/// Temperature and pH response curves are mathematical approximations unless
/// they are replaced with enzyme-specific reference/experimental datasets.
///
/// The engine returns normalized activity values suitable for the EV-LAB
/// virtual laboratory.
/// ============================================================================

class EnzymeSimulationResult {
  /// Final relative enzyme activity expressed as a percentage (0–100%).
  final double activityPercent;

  /// Fraction of Vmax contributed by the substrate concentration alone.
  final double substrateFactor;

  /// Relative activity caused by temperature.
  final double temperatureFactor;

  /// Relative activity caused by pH.
  final double phFactor;

  /// Relative inhibitor factor.
  ///
  /// 1.0 = no inhibition
  /// values approaching 0 = stronger inhibition
  final double inhibitorFactor;

  /// Calculated reaction rate relative to Vmax.
  final double reactionRate;

  const EnzymeSimulationResult({
    required this.activityPercent,
    required this.substrateFactor,
    required this.temperatureFactor,
    required this.phFactor,
    required this.inhibitorFactor,
    required this.reactionRate,
  });
}

class EnzymeSimulation {
  // ==========================================================================
  // MAIN CALCULATION
  // ==========================================================================

  static EnzymeSimulationResult calculate({
    required double temperature,
    required double ph,
    required double substrate,
    required double km,
    required double vmax,
    required double optimumTemperature,
    required double optimumPh,
    required double inhibitorRatio,
  }) {
    // ------------------------------------------------------------------------
    // INPUT VALIDATION
    // ------------------------------------------------------------------------

    final safeTemperature = temperature;
    final safePh = ph;
    final safeSubstrate = max(0.0, substrate);
    final safeKm = max(0.0, km);
    final safeVmax = max(0.0, vmax);
    final safeInhibitorRatio = max(0.0, inhibitorRatio);

    // ------------------------------------------------------------------------
    // 1. TEMPERATURE EFFECT
    // ------------------------------------------------------------------------
    //
    // Activity is highest near the enzyme's optimum temperature.
    //
    // NOTE:
    // This is currently a normalized mathematical approximation.
    // For the research version, enzyme-specific reference data should be
    // used where available.
    // ------------------------------------------------------------------------

    final temperatureFactor = _temperatureActivity(
      safeTemperature,
      optimumTemperature,
    );

    // ------------------------------------------------------------------------
    // 2. pH EFFECT
    // ------------------------------------------------------------------------
    //
    // Activity is highest near the enzyme's optimum pH and decreases as pH
    // moves farther away from the optimum.
    //
    // NOTE:
    // This is currently a normalized mathematical approximation.
    // ------------------------------------------------------------------------

    final phFactor = _phActivity(
      safePh,
      optimumPh,
    );

    // ------------------------------------------------------------------------
    // 3. COMPETITIVE INHIBITION
    // ------------------------------------------------------------------------
    //
    // Competitive inhibition:
    //
    //     alpha = 1 + [I]/Ki
    //
    // Since inhibitorRatio represents:
    //
    //     [I]/Ki
    //
    // we calculate:
    //
    //     alpha = 1 + inhibitorRatio
    //
    // The Michaelis-Menten equation becomes:
    //
    //     v = Vmax[S] / (alpha*Km + [S])
    //
    // This means competitive inhibition increases the apparent Km.
    // ------------------------------------------------------------------------

    final alpha = 1.0 + safeInhibitorRatio;

    // ------------------------------------------------------------------------
    // 4. SUBSTRATE + INHIBITOR KINETICS
    // ------------------------------------------------------------------------

    double kineticRate;

    if (safeSubstrate <= 0 || safeVmax <= 0) {
      kineticRate = 0.0;
    } else if (safeKm <= 0) {
      kineticRate = safeVmax;
    } else {
      kineticRate = safeVmax *
          safeSubstrate /
          ((alpha * safeKm) + safeSubstrate);
    }

    // ------------------------------------------------------------------------
    // 5. NORMALIZE KINETIC RATE TO Vmax
    // ------------------------------------------------------------------------

    final kineticFactor = safeVmax <= 0
        ? 0.0
        : (kineticRate / safeVmax).clamp(0.0, 1.0);

    // ------------------------------------------------------------------------
    // 6. INHIBITOR FACTOR
    // ------------------------------------------------------------------------
    //
    // This value is provided separately so the UI can explain the effect
    // of the inhibitor.
    //
    // For competitive inhibition:
    //
    //     inhibitorFactor = 1 / alpha
    //
    // This is an explanatory normalized factor and should NOT be multiplied
    // into the kinetic rate again, because inhibition has already been
    // incorporated into the Michaelis-Menten equation above.
    // ------------------------------------------------------------------------

    final inhibitorFactor =
    (1.0 / alpha).clamp(0.0, 1.0);

    // ------------------------------------------------------------------------
    // 7. COMBINE ENVIRONMENTAL FACTORS
    // ------------------------------------------------------------------------
    //
    // Temperature and pH act as environmental activity modifiers.
    //
    // The kinetic factor already includes substrate concentration and
    // competitive inhibition.
    // ------------------------------------------------------------------------

    final normalizedRate =
        kineticFactor *
            temperatureFactor *
            phFactor;

    // ------------------------------------------------------------------------
    // 8. FINAL ACTIVITY PERCENTAGE
    // ------------------------------------------------------------------------

    final activityPercent =
    (normalizedRate * 100.0)
        .clamp(0.0, 100.0);

    // ------------------------------------------------------------------------
    // 9. FINAL REACTION RATE
    // ------------------------------------------------------------------------

    final reactionRate =
        safeVmax * normalizedRate;

    return EnzymeSimulationResult(
      activityPercent: activityPercent,
      substrateFactor: kineticFactor,
      temperatureFactor: temperatureFactor,
      phFactor: phFactor,
      inhibitorFactor: inhibitorFactor,
      reactionRate: reactionRate,
    );
  }

  // ==========================================================================
  // TEMPERATURE RESPONSE
  // ==========================================================================

  static double _temperatureActivity(
      double temperature,
      double optimumTemperature,
      ) {
    final difference =
        temperature - optimumTemperature;

    // Width determines how rapidly activity decreases away from the
    // optimum temperature.
    //
    // This is a mathematical approximation and should eventually be replaced
    // by enzyme-specific reference data.
    const width = 15.0;

    final factor = exp(
      -(difference * difference) /
          (2.0 * width * width),
    );

    return factor.clamp(0.0, 1.0);
  }

  // ==========================================================================
  // pH RESPONSE
  // ==========================================================================

  static double _phActivity(
      double ph,
      double optimumPh,
      ) {
    final difference =
        ph - optimumPh;

    // Width determines how rapidly activity decreases away from the
    // optimum pH.
    //
    // This is a mathematical approximation and should eventually be replaced
    // by enzyme-specific reference data.
    const width = 2.0;

    final factor = exp(
      -(difference * difference) /
          (2.0 * width * width),
    );

    return factor.clamp(0.0, 1.0);
  }
}