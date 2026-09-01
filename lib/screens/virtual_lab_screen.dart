import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import 'package:evlab/models/enzyme.dart';
import 'package:evlab/models/inhibitor.dart';
import 'package:evlab/services/enzyme_simulation.dart';

import '../widgets/virtual_thermometer.dart';
import '../widgets/realistic_ph_control.dart';
import '../widgets/phet_lab_bench.dart';

import '../database/database_helper.dart';
import '../theme/app_theme.dart';
import '../services/progress_service.dart';
import 'result_screen.dart';

// ============================================================================
// EV-LAB VIRTUAL LAB
// COMPLETE REPLACEMENT SCREEN
// ============================================================================

class ExperimentTrial {
  final double temperature;
  final double ph;
  final double substrate;
  final InhibitionType inhibitorType;
  final double inhibitorRatio;
  final double activity;
  final double mixingQuality;

  ExperimentTrial({
    required this.temperature,
    required this.ph,
    required this.substrate,
    required this.inhibitorType,
    required this.inhibitorRatio,
    required this.activity,
    required this.mixingQuality,
  });

  bool get inhibitor =>
      inhibitorType != InhibitionType.none;
}

// ============================================================================
// VIRTUAL LAB SCREEN
// ============================================================================

class VirtualLabScreen extends StatefulWidget {
  final Enzyme enzyme;

  const VirtualLabScreen({
    super.key,
    required this.enzyme,
  });

  @override
  State<VirtualLabScreen> createState() =>
      _VirtualLabScreenState();
}

class _VirtualLabScreenState extends State<VirtualLabScreen>
    with TickerProviderStateMixin {
  // ==========================================================================
  // EXPERIMENT STATE
  // ==========================================================================

  double temperature = 37.0;
  double ph = 7.0;
  double substrate = 1.0;

  InhibitionType inhibitorType = InhibitionType.none;
  double inhibitorRatio = 0.0;

  double activity = 0.0;

  // Hands-on laboratory state. These make the experiment more than
  // simply changing values and pressing RUN.
  double mixingQuality = 0.0;
  int pipetteDrops = 0;
  bool samplePrepared = false;

  // Equipment must be collected before the corresponding instrument can be used.
  bool thermometerCollected = false;
  bool phMeterCollected = false;
  bool pipetteCollected = false;
  bool stirrerCollected = false;
  bool inhibitorCollected = false;
  bool show3DModel = false;

  bool isRunning = false;
  bool showAnalysis = false;

  final List<ExperimentTrial> trials = [];

  // ==========================================================================
  // ANIMATION CONTROLLERS
  // ==========================================================================

  late AnimationController _reactionController;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late AnimationController _resultController;
  late AnimationController _moleculeController;

  // ==========================================================================
  // MISSION
  // ==========================================================================

  int missionNumber = 1;
  int completedMissions = 0;

  bool missionMode = false;

  String missionTitle = 'First Laboratory Experiment';

  String missionDescription =
      'Adjust laboratory conditions and discover how they affect enzyme activity.';

  double? missionTargetActivity;

  // ==========================================================================
  // INITIALIZATION
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    _setInitialConditions();
    activity = calculateActivity();

    // The new bench workflow is visible rather than a hidden drawer.
    // Instruments are available immediately so the environmental controls
    // can always be interacted with. Preparation still gates the run action.
    thermometerCollected = true;
    phMeterCollected = true;
    pipetteCollected = true;
    stirrerCollected = true;

    _reactionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    if (EVLabSettings.animationsEnabled.value) _particleController.repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (EVLabSettings.animationsEnabled.value) _pulseController.repeat(reverse: true);

    _resultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _moleculeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (EVLabSettings.animationsEnabled.value) _moleculeController.repeat();

    // Delay the WebView-backed GLB until the rest of the laboratory is rendered.
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => show3DModel = true);
    });
  }

  @override
  void dispose() {
    _reactionController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    _resultController.dispose();
    _moleculeController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // INITIAL CONDITIONS
  // ==========================================================================

  void _setInitialConditions() {
    final optimumTemperature = _extractNumber(
      widget.enzyme.optimumTemperature,
      37.0,
    );
    final optimumPh = _extractNumber(
      widget.enzyme.optimumPH,
      7.0,
    );

    // Start slightly away from optimum so the learner immediately sees that
    // the environmental controls actually change the simulated activity.
    temperature = (optimumTemperature - 5.0).clamp(0.0, 100.0);
    ph = (optimumPh + 0.5).clamp(0.0, 14.0);

    switch (widget.enzyme.name.toLowerCase()) {
      case 'amylase':
        substrate = 5.0;
        break;
      case 'catalase':
        substrate = 25.0;
        break;
      case 'lipase':
        substrate = 0.50;
        break;
      default:
        substrate = 1.0;
    }

    inhibitorType = InhibitionType.none;
    inhibitorRatio = 0.0;
  }

  // ==========================================================================
  // SUBSTRATE
  // ==========================================================================

  double get substrateMinimum {
    switch (widget.enzyme.name.toLowerCase()) {
      case 'amylase':
        return 0.5;

      case 'catalase':
        return 1.0;

      case 'lipase':
        return 0.05;

      default:
        return 0.1;
    }
  }

  double get substrateMaximum {
    switch (widget.enzyme.name.toLowerCase()) {
      case 'amylase':
        return 20.0;

      case 'catalase':
        return 100.0;

      case 'lipase':
        return 1.0;

      default:
        return 10.0;
    }
  }

  String get substrateUnit {
    switch (widget.enzyme.name.toLowerCase()) {
      case 'amylase':
        return 'mM';

      case 'catalase':
        return 'mM H₂O₂';

      case 'lipase':
        return 'mM pNPP';

      default:
        return 'mM';
    }
  }

  int get substrateDecimals =>
      widget.enzyme.name.toLowerCase() == 'lipase' ? 2 : 1;

  // ==========================================================================
  // INHIBITOR
  // ==========================================================================

  String get inhibitorName =>
      InhibitorData.getByType(inhibitorType).name;

  String get inhibitorDescription =>
      InhibitorData.getByType(inhibitorType).description;

  // ==========================================================================
  // NUMBER EXTRACTION
  // ==========================================================================

  double _extractNumber(
      String value,
      double fallback,
      ) {
    final match = RegExp(
      r'[-+]?[0-9]*\.?[0-9]+',
    ).firstMatch(value);

    if (match == null) {
      return fallback;
    }

    return double.tryParse(match.group(0)!) ?? fallback;
  }

  // ==========================================================================
  // INTERPOLATION
  // ==========================================================================

  double _interpolateActivity(
      Map<double, double> data,
      double value,
      ) {
    if (data.isEmpty) {
      return 1.0;
    }

    final points = data.entries.toList()
      ..sort(
            (a, b) => a.key.compareTo(b.key),
      );

    if (value <= points.first.key) {
      return points.first.value;
    }

    if (value >= points.last.key) {
      return points.last.value;
    }

    for (int i = 0; i < points.length - 1; i++) {
      final x1 = points[i].key;
      final y1 = points[i].value;

      final x2 = points[i + 1].key;
      final y2 = points[i + 1].value;

      if (value >= x1 && value <= x2) {
        final fraction = (value - x1) / (x2 - x1);

        return y1 + ((y2 - y1) * fraction);
      }
    }

    return 1.0;
  }

  // ==========================================================================
  // MICHAELIS-MENTEN
  // ==========================================================================

  double _calculateNormalVelocity({
    required double substrateConcentration,
    required double km,
    required double vmax,
  }) {
    if (substrateConcentration <= 0 ||
        km <= 0 ||
        vmax <= 0) {
      return 0.0;
    }

    return vmax *
        substrateConcentration /
        (km + substrateConcentration);
  }

  // ==========================================================================
  // INHIBITION KINETICS
  // ==========================================================================

  double _calculateInhibitedVelocity({
    required double substrateConcentration,
    required double km,
    required double vmax,
  }) {
    if (substrateConcentration <= 0 ||
        km <= 0 ||
        vmax <= 0) {
      return 0.0;
    }

    if (inhibitorType == InhibitionType.none ||
        inhibitorRatio <= 0) {
      return _calculateNormalVelocity(
        substrateConcentration: substrateConcentration,
        km: km,
        vmax: vmax,
      );
    }

    final ratio = inhibitorRatio;

    switch (inhibitorType) {
      case InhibitionType.none:
        return _calculateNormalVelocity(
          substrateConcentration: substrateConcentration,
          km: km,
          vmax: vmax,
        );

      case InhibitionType.competitive:
        final alpha = 1.0 + ratio;
        final apparentKm = km * alpha;

        return vmax *
            substrateConcentration /
            (apparentKm + substrateConcentration);

      case InhibitionType.noncompetitive:
        final alpha = 1.0 + ratio;
        final apparentVmax = vmax / alpha;

        return apparentVmax *
            substrateConcentration /
            (km + substrateConcentration);

      case InhibitionType.uncompetitive:
        final alphaPrime = 1.0 + ratio;

        final apparentKm = km / alphaPrime;
        final apparentVmax = vmax / alphaPrime;

        return apparentVmax *
            substrateConcentration /
            (apparentKm + substrateConcentration);

      case InhibitionType.mixed:
        // General mixed inhibition: alpha and alpha' may differ.
        // The lab uses an explicit educational asymmetry because only one
        // inhibitor-strength control is exposed to the learner.
        final alpha = 1.0 + ratio;
        final alphaPrime = 1.0 + (ratio * 0.5);

        return vmax *
            substrateConcentration /
            (alpha * km +
                alphaPrime * substrateConcentration);
    }
  }

  // ==========================================================================
  // TEMPERATURE EFFECT
  // ==========================================================================

  double _temperatureEffect() {
    final optimum = _extractNumber(
      widget.enzyme.optimumTemperature,
      37.0,
    );

    if (widget.enzyme.temperatureActivity.isNotEmpty) {
      return _interpolateActivity(
        widget.enzyme.temperatureActivity,
        temperature,
      ).clamp(0.0, 1.0);
    }

    final difference = (temperature - optimum).abs();

    if (difference <= 2) return 1.0;
    if (difference <= 5) return 0.9;
    if (difference <= 10) return 0.75;
    if (difference <= 20) return 0.55;

    return 0.3;
  }

  // ==========================================================================
  // PH EFFECT
  // ==========================================================================

  double _phEffect() {
    final optimum = _extractNumber(
      widget.enzyme.optimumPH,
      7.0,
    );

    if (widget.enzyme.phActivity.isNotEmpty) {
      return _interpolateActivity(
        widget.enzyme.phActivity,
        ph,
      ).clamp(0.0, 1.0);
    }

    final difference = (ph - optimum).abs();

    if (difference <= 0.2) return 1.0;
    if (difference <= 0.5) return 0.9;
    if (difference <= 1) return 0.75;
    if (difference <= 2) return 0.5;

    return 0.25;
  }

  // ==========================================================================
  // SUBSTRATE EFFECT
  // ==========================================================================

  double _substrateEffect() {
    if (widget.enzyme.vmax <= 0) {
      return 0.0;
    }

    final velocity = _calculateInhibitedVelocity(
      substrateConcentration: substrate,
      km: widget.enzyme.km,
      vmax: widget.enzyme.vmax,
    );

    return (velocity / widget.enzyme.vmax).clamp(0.0, 1.0);
  }

  // ==========================================================================
  // ACTIVITY
  // ==========================================================================

  double calculateActivity() {
    // Route the actual scientific calculation through the shared simulation
    // engine. This keeps the laboratory UI and the rest of EV-LAB using the
    // same kinetic model instead of maintaining a second hidden formula here.
    final simulation = EnzymeSimulation.simulateVirtualLab(
      enzyme: widget.enzyme,
      temperature: temperature,
      ph: ph,
      substrate: substrate,
      inhibitorType: inhibitorType,
      inhibitorRatio: inhibitorRatio,
    );

    // Mixing quality represents practical sample handling. It is intentionally
    // a modest modifier so the scientific condition model remains dominant.
    final handlingEffect = 0.80 + (mixingQuality * 0.20);

    return (simulation.activity * handlingEffect)
        .clamp(0.0, 100.0);
  }

  // ==========================================================================
  // RUN EXPERIMENT
  // ==========================================================================

  Future<void> runExperiment() async {
    if (isRunning || !_readyToRun) return;

    FocusManager.instance.primaryFocus?.unfocus();

    // Snapshot the prepared sample before the run begins. This keeps the
    // recorded result tied to the learner's actual mixing and settings.
    final finalActivity = calculateActivity();
    final trial = ExperimentTrial(
      temperature: temperature,
      ph: ph,
      substrate: substrate,
      inhibitorType: inhibitorType,
      inhibitorRatio: inhibitorRatio,
      activity: finalActivity,
      mixingQuality: mixingQuality,
    );

    setState(() {
      isRunning = true;
      activity = 0.0;
      showAnalysis = false;
    });

    _reactionController.repeat();

    await Future.delayed(
      const Duration(milliseconds: 1800),
    );

    _reactionController.stop();

    try {
      await DatabaseHelper.instance
          .insertExperiment({
        'enzyme_name': widget.enzyme.name,
        'temperature': temperature,
        'ph': ph,
        'substrate': substrate,
        'substrate_unit': substrateUnit,
        'inhibitor_type': inhibitorType.name,
        'inhibitor_ratio': inhibitorRatio,
        'activity': finalActivity,
        'created_at': DateTime.now().toIso8601String(),
      })
          .timeout(
        const Duration(seconds: 3),
      );
    } catch (e) {
      debugPrint(
        'EV-LAB database error: $e',
      );
    }

    if (!mounted) return;

    setState(() {
      activity = finalActivity;
      isRunning = false;
      trials.add(trial);
      showAnalysis = true;
    });

    _resultController.forward(from: 0);

    ProgressService.instance.completeExperiment();

    _checkMission(finalActivity);

    await Future.delayed(
      const Duration(milliseconds: 350),
    );

    if (mounted) {
      _showExperimentComplete();
    }
  }

  // ==========================================================================
  // EXPERIMENT COMPLETE
  // ==========================================================================

  void _showExperimentComplete() {
    if (!mounted || activity <= 0) return;

    final level = getActivityLevel();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.fromLTRB(
            22,
            18,
            22,
            24,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Icon(
                activity >= 75
                    ? Icons.check_circle
                    : Icons.analytics,
                size: 54,
                color: getActivityColor(),
              ),
              const SizedBox(height: 12),
              const Text(
                'EXPERIMENT COMPLETE',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${activity.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: getActivityColor(),
                ),
              ),
              Text(
                level,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: getActivityColor(),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _shortScientificConclusion(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: EVLabColors.textMedium,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'VIEW FULL ANALYSIS',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================================
  // SCIENTIFIC EXPLANATION
  // ==========================================================================

  String _shortScientificConclusion() {
    if (activity >= 75) {
      return 'The selected conditions are favorable for enzyme activity. '
          'The temperature and pH are relatively close to the enzyme’s '
          'validated optimum, while substrate availability supports '
          'a relatively high reaction velocity.';
    }

    if (activity >= 40) {
      return 'The enzyme is still active, but one or more experimental '
          'conditions are reducing the reaction rate. Changing temperature, '
          'pH, substrate concentration, or inhibitor concentration may '
          'increase activity.';
    }

    return 'The selected conditions strongly limit the simulated reaction. '
        'The enzyme may be operating away from its favorable temperature '
        'or pH range, or the effective reaction velocity is being limited '
        'by substrate or inhibition.';
  }

  String _fullScientificExplanation() {
    final temperatureEffect = _temperatureEffect();
    final phEffect = _phEffect();
    final substrateEffect = _substrateEffect();

    final optimumTemperature = _extractNumber(
      widget.enzyme.optimumTemperature,
      37,
    );

    final optimumPH = _extractNumber(
      widget.enzyme.optimumPH,
      7,
    );

    final buffer = StringBuffer();

    buffer.writeln('TEMPERATURE',);

    if (temperatureEffect >= 0.9) {
      buffer.writeln(
        'The selected temperature of '
            '${temperature.toStringAsFixed(1)}°C is close to the '
            'validated optimum of ${optimumTemperature.toStringAsFixed(1)}°C. '
            'This produces a favorable temperature contribution to the '
            'simulated reaction.',
      );
    } else {
      buffer.writeln(
        'The selected temperature of '
            '${temperature.toStringAsFixed(1)}°C differs from the '
            'validated optimum of ${optimumTemperature.toStringAsFixed(1)}°C. '
            'This lowers the temperature contribution to the simulated '
            'reaction activity.',
      );
    }

    buffer.writeln('PH',);

    if (phEffect >= 0.9) {
      buffer.writeln(
        'The selected pH of ${ph.toStringAsFixed(1)} is close to the '
            'validated optimum of ${optimumPH.toStringAsFixed(1)}. '
            'Therefore, the pH contribution remains relatively favorable.',
      );
    } else {
      buffer.writeln(
        'The selected pH of ${ph.toStringAsFixed(1)} differs from the '
            'validated optimum of ${optimumPH.toStringAsFixed(1)}. '
            'Changes in pH can alter the ionization state of amino acid '
            'side chains involved in enzyme structure and catalysis, '
            'which is represented in the simulation by a lower pH factor.',
      );
    }

    buffer.writeln('SUBSTRATE',);

    buffer.writeln(
      'The simulation calculates substrate-dependent velocity using '
          'the Michaelis-Menten relationship. As substrate concentration '
          'increases, reaction velocity approaches the enzyme’s Vmax rather '
          'than increasing indefinitely. The current substrate contribution '
          'is approximately ${(substrateEffect * 100).toStringAsFixed(1)}%.',
    );

    buffer.writeln('INHIBITOR',);

    if (inhibitorType == InhibitionType.none) {
      buffer.writeln(
        'No inhibitor is present, so the inhibition component does not '
            'reduce the calculated substrate-dependent velocity.',
      );
    } else {
      buffer.writeln(
        '$inhibitorName is selected at an [I]/Ki ratio of '
            '${inhibitorRatio.toStringAsFixed(2)}. '
            'The simulation applies the corresponding inhibition model '
            'to modify the kinetic parameters and reaction velocity.',
      );
    }

    buffer.writeln('OVERALL RESULT',);

    buffer.writeln(
      'The final simulated activity is '
          '${activity.toStringAsFixed(1)}%. '
          'This value results from the combined temperature, pH, substrate, '
          'and inhibition effects used by the model.',
    );

    return buffer.toString();
  }

  // ==========================================================================
  // MISSIONS
  // ==========================================================================

  void startMission() {
    setState(() {
      missionMode = true;
      missionNumber++;
      activity = 0.0;
      showAnalysis = false;
      samplePrepared = false;
      mixingQuality = 0.0;
      pipetteDrops = 0;

      switch (missionNumber) {
        case 2:
          missionTitle = 'Find the Optimum Temperature';

          missionDescription =
          'Adjust the temperature until the enzyme reaches high activity.';

          missionTargetActivity = 75.0;
          break;

        case 3:
          missionTitle = 'Find the Best pH';

          missionDescription =
          'Change pH and discover the range where the enzyme works best.';

          missionTargetActivity = 75.0;
          break;

        case 4:
          missionTitle = 'Beat the Inhibitor';

          missionDescription =
          'Use your knowledge of inhibition to obtain at least 50% activity.';

          missionTargetActivity = 50.0;
          break;

        default:
          missionTitle = 'Master Enzyme Activity';

          missionDescription =
          'Create experimental conditions that produce high enzyme activity.';

          // 75% is attainable by every included enzyme within its configured
          // substrate range; 80% was not attainable for amylase at Vmax.
          missionTargetActivity = 75.0;
      }
    });
  }

  void _checkMission(double result) {
    if (!missionMode ||
        missionTargetActivity == null) {
      return;
    }

    if (result >= missionTargetActivity!) {
      setState(() {
        ProgressService.instance.addXP(100);
        completedMissions++;
        missionMode = false;
      });

      Future.delayed(
        const Duration(milliseconds: 350),
            () {
          if (mounted) {
            _showMissionSuccess();
          }
        },
      );
    }
  }

  void _showMissionSuccess() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: EVLabColors.yellow,
                size: 32,
              ),
              SizedBox(width: 10),
              Text('Mission Complete!'),
            ],
          ),
          content: const Text(
            'Excellent laboratory work!\n\n'
                '+100 XP\n'
                'You successfully reached the target activity.',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CONTINUE'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================================
  // RESET
  // ==========================================================================

  void resetExperiment() {
    if (isRunning) return;

    setState(() {
      _setInitialConditions();

      activity = 0.0;
      mixingQuality = 0.0;
      pipetteDrops = 0;
      samplePrepared = false;

      trials.clear();

      missionMode = false;
      missionTargetActivity = null;

      showAnalysis = false;
      thermometerCollected = false;
      phMeterCollected = false;
      pipetteCollected = false;
      stirrerCollected = false;
      inhibitorCollected = false;
    });

    _reactionController.reset();
    _resultController.reset();
  }

  // ==========================================================================
  // ACTIVITY LEVEL
  // ==========================================================================

  String getActivityLevel() {
    if (activity >= 75) {
      return 'High Activity';
    }

    if (activity >= 40) {
      return 'Moderate Activity';
    }

    return 'Low Activity';
  }

  Color getActivityColor() {
    if (activity >= 75) {
      return EVLabColors.success;
    }

    if (activity >= 40) {
      return EVLabColors.warning;
    }

    return EVLabColors.danger;
  }

  bool get _readyToRun =>
      samplePrepared &&
      mixingQuality >= 0.55;

  // Retained as a reusable legacy panel; the single main bench is used now.
  // ignore: unused_element
  Widget _buildBenchSetup() {
    final steps = <Map<String, dynamic>>[
      {
        'title': 'Calibrate thermometer',
        'subtitle': thermometerCollected
            ? 'Thermometer is calibrated and ready.'
            : 'Tap CALIBRATE to put the digital probe on the bench.',
        'icon': Icons.thermostat,
        'done': thermometerCollected,
        'action': () => setState(() => thermometerCollected = true),
        'label': thermometerCollected ? 'READY' : 'CALIBRATE',
      },
      {
        'title': 'Calibrate pH meter',
        'subtitle': phMeterCollected
            ? 'pH probe is calibrated and ready.'
            : 'Tap CALIBRATE to prepare the pH probe.',
        'icon': Icons.water_drop,
        'done': phMeterCollected,
        'action': () => setState(() => phMeterCollected = true),
        'label': phMeterCollected ? 'READY' : 'CALIBRATE',
      },
      {
        'title': 'Load micropipette',
        'subtitle': pipetteCollected
            ? 'Pipette loaded. Add substrate drops at the bench.'
            : 'Load a virtual pipette before adding substrate.',
        'icon': Icons.colorize,
        'done': pipetteCollected,
        'action': () => setState(() => pipetteCollected = true),
        'label': pipetteCollected ? 'LOADED' : 'LOAD',
      },
      {
        'title': 'Power magnetic stirrer',
        'subtitle': stirrerCollected
            ? 'Stirrer is powered and ready for mixing.'
            : 'Power the stirrer before mixing the reaction.',
        'icon': Icons.sync,
        'done': stirrerCollected,
        'action': () => setState(() => stirrerCollected = true),
        'label': stirrerCollected ? 'ON' : 'POWER',
      },
      {
        'title': 'Prepare inhibitor vial',
        'subtitle': inhibitorCollected
            ? 'Inhibitor vial is on the bench and ready.'
            : 'Optional: prepare the inhibitor before testing inhibition.',
        'icon': Icons.science,
        'done': inhibitorCollected,
        'action': () => setState(() => inhibitorCollected = true),
        'label': inhibitorCollected ? 'READY' : 'PREPARE',
      },
    ];

    final readyCount = steps.take(4).where((e) => e['done'] as bool).length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF102A43), Color(0xFF173B57)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.playlist_add_check, color: Colors.white),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'BENCH SETUP',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .8,
                  ),
                ),
              ),
              Text(
                '$readyCount/4 CORE READY',
                style: const TextStyle(
                  color: Color(0xFF8EF0D0),
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Prepare and calibrate the instruments at the bench. No hidden drawer: every tool has a visible job.',
            style: TextStyle(color: Colors.white70, height: 1.35),
          ),
          const SizedBox(height: 14),
          ...steps.map((step) {
            final done = step['done'] as bool;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: done ? .12 : .07),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: done ? const Color(0xFF55EFC4) : Colors.white12,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    done ? Icons.check_circle : step['icon'] as IconData,
                    color: done ? const Color(0xFF55EFC4) : Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step['subtitle'] as String,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 10,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: done ? null : step['action'] as VoidCallback,
                    child: Text(step['label'] as String),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }



  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              45,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHero(),

                const SizedBox(height: 14),

                _buildExperimentStatus(),

                if (EVLabSettings.scientificGuidance.value) ...[
                  const SizedBox(height: 12),
                  _buildLabCoach(),
                ],

                const SizedBox(height: 14),

                _buildPhetStyleBench(),

                const SizedBox(height: 10),

                _buildDetailedLabModules(),

                const SizedBox(height: 14),

                _buildMission(),

                const SizedBox(height: 16),

                _buildRunButton(),

                if (showAnalysis) ...[
                  const SizedBox(height: 20),
                  _buildResultReveal(),

                  const SizedBox(height: 16),
                  _buildMolecularModel(),

                  const SizedBox(height: 16),
                  _buildAnalysis(),

                  const SizedBox(height: 16),
                  _buildGraphs(),

                  const SizedBox(height: 14),
                  _buildInLabDetailedResultAction(),
                ],

                if (trials.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildHistory(),

                  const SizedBox(height: 14),

                  _buildResultsButton(),
                ],

                const SizedBox(height: 16),

                _buildScientificReference(),
              ],
            ),
          ),

          if (isRunning)
            _buildRunningOverlay(),
        ],
      ),
    );
  }

  Widget _buildLabCoach() {
    final String title;
    final String body;
    final IconData icon;
    final double progress;

    if (isRunning) {
      title = 'REACTION IN PROGRESS';
      body = 'Watch the reaction chamber. The selected temperature, pH, substrate concentration, inhibitor, and preparation quality are being combined by the simulation.';
      icon = Icons.science_rounded;
      progress = .82;
    } else if (!samplePrepared) {
      title = 'STEP 1 · PREPARE YOUR SAMPLE';
      body = 'Use the pipette to add substrate, then stir the mixture. Your handling quality affects the recorded trial, so preparation is part of the experiment—not just decoration.';
      icon = Icons.colorize_rounded;
      progress = .25;
    } else if (mixingQuality < .55) {
      title = 'STEP 2 · MIX THOROUGHLY';
      body = 'Keep stirring until the sample is adequately mixed. A well-prepared sample gives the simulation enough handling quality to run the trial.';
      icon = Icons.rotate_right_rounded;
      progress = .50;
    } else if (!showAnalysis) {
      title = 'STEP 3 · PREDICT THEN RUN';
      body = 'Before pressing Run, look at the live activity estimate and think about which condition is helping or limiting the enzyme. Then run the trial and compare your prediction with the result.';
      icon = Icons.lightbulb_outline_rounded;
      progress = .72;
    } else {
      title = 'STEP 4 · ANALYZE YOUR EVIDENCE';
      body = 'Compare this trial with your previous trials. Look for trends rather than one lucky value, then use the results to decide what condition you would test next.';
      icon = Icons.insights_rounded;
      progress = 1.0;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: EVLabGradients.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: EVLabColors.emerald.withValues(alpha: .16), blurRadius: 18, offset: const Offset(0, 7))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .18), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: Colors.white)),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: .4)),
            const SizedBox(height: 3),
            const Text('LAB COACH · WHY THIS STEP MATTERS', style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w700)),
          ])),
        ]),
        const SizedBox(height: 12),
        Text(body, style: const TextStyle(color: Colors.white, height: 1.45, fontSize: 12)),
        const SizedBox(height: 12),
        ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: progress, minHeight: 7, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation<Color>(Colors.white))),
      ]),
    );
  }

  final GlobalKey<PhetLabBenchState> _phetBenchKey = GlobalKey<PhetLabBenchState>();

  Widget _buildPhetStyleBench() {
    return PhetLabBench(
      key: _phetBenchKey,
      enzymeName: widget.enzyme.name,
      model3D: widget.enzyme.model3D,
      modelDescription: widget.enzyme.modelDescription,
      optimumTemperature: _extractNumber(widget.enzyme.optimumTemperature, 37.0),
      optimumPh: _extractNumber(widget.enzyme.optimumPH, 7.0),
      temperature: temperature,
      ph: ph,
      activity: activity,
      substrate: substrate,
      substrateMin: substrateMinimum,
      substrateMax: substrateMaximum,
      inhibitorActive: inhibitorType != InhibitionType.none,
      onTemperatureChanged: (value) {
        if (isRunning) return;
        setState(() {
          temperature = value.clamp(0.0, 100.0).toDouble();
          activity = calculateActivity();
          showAnalysis = false;
        });
      },
      onPhChanged: (value) {
        if (isRunning) return;
        setState(() {
          ph = value.clamp(1.0, 14.0).toDouble();
          activity = calculateActivity();
          showAnalysis = false;
        });
      },
      onSubstrateChanged: (value) {
        if (isRunning) return;
        setState(() {
          substrate = value.clamp(substrateMinimum, substrateMaximum).toDouble();
          activity = calculateActivity();
          showAnalysis = false;
        });
      },
      onAddSubstrate: _addPipetteDrop,
      onStir: _stirSample,
      onAddInhibitor: () {
        if (isRunning) return;
        setState(() {
          inhibitorType = inhibitorType == InhibitionType.none
              ? InhibitionType.competitive
              : InhibitionType.none;
          inhibitorRatio = inhibitorType == InhibitionType.none ? 0.0 : .35;
          inhibitorCollected = true;
          activity = calculateActivity();
          showAnalysis = false;
        });
      },
    );
  }

  // ==========================================================================
  // ADVANCED CONTROLS
  // ==========================================================================
  //
  // The bench is the single experiment interface. Advanced inhibition
  // settings remain available without duplicating the main instruments.
  // ==========================================================================

  Widget _buildDetailedLabModules() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF087F5B).withValues(alpha: .12),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: const Icon(
            Icons.tune,
            color: Color(0xFF087F5B),
          ),
          title: const Text(
            'Advanced experiment settings',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          subtitle: const Text(
            'Choose an inhibition mechanism and its relative strength.',
            style: TextStyle(fontSize: 11),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          children: [
            _buildInhibitor(),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // APP BAR
  // ==========================================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: EVLabGradients.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.biotech,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'EV-LAB',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 14),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF7654C8)
                .withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.bolt,
                size: 18,
                color: Color(0xFF7654C8),
              ),
              const SizedBox(width: 4),
              Text(
                '${ProgressService.instance.xp} XP',
                style: const TextStyle(
                  color: Color(0xFF7654C8),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // HERO
  // ==========================================================================

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF087F5B),
            Color(0xFF075E54),
            Color(0xFF123C55),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF087F5B)
                .withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.science,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'ENZYME VIRTUAL LAB',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            widget.enzyme.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            widget.enzyme.classification,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'CONTROL • OBSERVE • ANALYZE',
            style: TextStyle(
              color: Color(0xFF8EF0D0),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Explore how temperature, pH, substrate concentration, '
                'and inhibition influence enzyme activity.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // STATUS
  // ==========================================================================

  Widget _buildExperimentStatus() {
    final ready = !isRunning;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF0A7B5C)
              .withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: ready
                  ? const Color(0xFF22A06B)
                  : const Color(0xFFFFA62B),
              shape: BoxShape.circle,
              boxShadow: [
                if (!ready)
                  BoxShadow(
                    color: const Color(0xFFFFA62B)
                        .withValues(alpha: 0.5),
                    blurRadius: 8,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isRunning
                  ? 'Experiment in progress'
                  : trials.isEmpty
                  ? 'Laboratory ready'
                  : '${trials.length} experiment${trials.length == 1 ? '' : 's'} completed',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          Icon(
            isRunning
                ? Icons.biotech
                : Icons.verified_outlined,
            size: 18,
            color: const Color(0xFF087F5B),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // MISSION
  // ==========================================================================

  Widget _buildMission() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFFF9F1C)
              .withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9F1C)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flag,
                  color: Color(0xFFFF9F1C),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'LAB MISSION',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                'MISSION $missionNumber',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: EVLabColors.textLight,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            missionMode
                ? missionTitle
                : 'Ready for a challenge?',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            missionMode
                ? missionDescription
                : 'Test your understanding by solving an experimental challenge.',
            style: const TextStyle(
              color: EVLabColors.textMedium,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 14),

          if (missionMode &&
              missionTargetActivity != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9F1C)
                    .withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.track_changes,
                    color: Color(0xFFFF9F1C),
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'TARGET ≥ ${missionTargetActivity!.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Color(0xFFFF9F1C),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: startMission,
                icon: const Icon(Icons.play_arrow),
                label: const Text('START MISSION'),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================================
  // REACTION CHAMBER
  // ==========================================================================

  // Retained as a reusable legacy panel; the single main bench is used now.
  // ignore: unused_element
  Widget _buildReactionChamber() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF081F2C),
            Color(0xFF0B3342),
            Color(0xFF09252E),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF31D0AA)
                      .withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.monitor_heart,
                  color: Color(0xFF72F2D0),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'LIVE REACTION CHAMBER',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (isRunning)
                const _LiveIndicator(),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 245,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _particleController,
                _pulseController,
                _reactionController,
                _moleculeController,
              ]),
              builder: (context, child) {
                return CustomPaint(
                  painter: _ReactionChamberPainter(
                    particleProgress:
                    _particleController.value,
                    pulseProgress:
                    _pulseController.value,
                    reactionProgress:
                    _reactionController.value,
                    moleculeProgress:
                    _moleculeController.value,
                    active: isRunning,
                    activity: activity,
                    inhibitor:
                    inhibitorType !=
                        InhibitionType.none &&
                        inhibitorRatio > 0,
                  ),
                );
              },
            ),
          ),

          Text(
            isRunning
                ? 'Analyzing molecular interactions...'
                : activity > 0
                ? 'Reaction complete • Data collected'
                : 'Configure the laboratory and run an experiment',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // CONDITIONS
  // ==========================================================================

  // Retained as a reusable legacy panel; the single main bench is used now.
  // ignore: unused_element
  Widget _buildConditions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF087F5B)
              .withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.biotech,
                color: Color(0xFF087F5B),
              ),
              SizedBox(width: 10),
              Text(
                'LABORATORY CONTROLS',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          const Text(
            'Use the instruments to manipulate the experimental environment.',
            style: TextStyle(
              fontSize: 11,
              color: EVLabColors.textMedium,
            ),
          ),

          const SizedBox(height: 20),

          _buildTemperatureControl(),

          const SizedBox(height: 18),

          _buildPHControl(),

          const SizedBox(height: 18),

          _buildSubstrateControl(),

          const SizedBox(height: 18),

          _buildExplorePresets(),
        ],
      ),
    );
  }

  Widget _buildExplorePresets() {
    final optimumTemperature = _extractNumber(widget.enzyme.optimumTemperature, 37.0);
    final optimumPh = _extractNumber(widget.enzyme.optimumPH, 7.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFF4FAF8), Color(0xFFFFFFFF)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF087F5B).withValues(alpha: .12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.explore, size: 19, color: Color(0xFF087F5B)),
              SizedBox(width: 7),
              Text('EXPLORE CONDITIONS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: .7)),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'Jump to a condition, then fine-tune it with the instruments and watch the chamber respond.',
            style: TextStyle(fontSize: 11, color: EVLabColors.textMedium, height: 1.35),
          ),
          const SizedBox(height: 11),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _presetChip('COLD', Icons.ac_unit, const Color(0xFF2196F3), () => _applyLabPreset(temperature: optimumTemperature - 15)),
              _presetChip('OPTIMUM', Icons.star, const Color(0xFF00A878), () => _applyLabPreset(temperature: optimumTemperature, ph: optimumPh)),
              _presetChip('HEAT STRESS', Icons.local_fire_department, const Color(0xFFE67E22), () => _applyLabPreset(temperature: optimumTemperature + 15)),
              _presetChip('ACIDIC', Icons.water_drop, const Color(0xFFE64949), () => _applyLabPreset(ph: optimumPh - 2)),
              _presetChip('BASIC', Icons.water_drop, const Color(0xFF5B63D8), () => _applyLabPreset(ph: optimumPh + 2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _presetChip(String label, IconData icon, Color color, VoidCallback onTap) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color)),
      backgroundColor: color.withValues(alpha: .08),
      side: BorderSide(color: color.withValues(alpha: .18)),
      onPressed: isRunning ? null : onTap,
    );
  }

  void _applyLabPreset({double? temperature, double? ph}) {
    if (isRunning) return;
    setState(() {
      if (temperature != null) this.temperature = temperature.clamp(0.0, 100.0).toDouble();
      if (ph != null) this.ph = ph.clamp(1.0, 14.0).toDouble();
      activity = calculateActivity();
      showAnalysis = false;
    });
  }

  // ==========================================================================
  // REALISTIC TEMPERATURE + pH INSTRUMENTS
  // ==========================================================================

  Widget _buildTemperatureControl() {
    final optimum = _extractNumber(widget.enzyme.optimumTemperature, 37.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VirtualThermometer(
          temperature: temperature,
          minimum: 0.0,
          maximum: 100.0,
          optimumTemperature: optimum,
          enabled: !isRunning && thermometerCollected,
          onChanged: (value) {
            setState(() {
              temperature = value.clamp(0.0, 100.0).toDouble();
              activity = calculateActivity();
              showAnalysis = false;
            });
          },
        ),
        const SizedBox(height: 10),
        _interactiveInstrumentSlider(
          label: 'HEAT / COOL BATH',
          value: temperature,
          min: 0.0,
          max: 100.0,
          divisions: 200,
          leftLabel: '0°C',
          rightLabel: '100°C',
          accent: const Color(0xFFE67E22),
          enabled: !isRunning && thermometerCollected,
          valueLabel: '${temperature.toStringAsFixed(1)}°C',
          onChanged: (value) {
            setState(() {
              temperature = value;
              activity = calculateActivity();
              showAnalysis = false;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPHControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RealisticPHControl(
          ph: ph,
          enabled: !isRunning && phMeterCollected,
          onChanged: (value) {
            setState(() {
              ph = value.clamp(1.0, 14.0).toDouble();
              activity = calculateActivity();
              showAnalysis = false;
            });
          },
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: _phColor().withValues(alpha: .08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: _phColor(),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _phDescription(),
                  style: TextStyle(
                    color: _phColor(),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
              Text(
                'pH ${ph.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _interactiveInstrumentSlider(
          label: 'BUFFER / pH ADJUSTER',
          value: ph,
          min: 1.0,
          max: 14.0,
          divisions: 130,
          leftLabel: '1 acidic',
          rightLabel: '14 basic',
          accent: const Color(0xFF287D7D),
          enabled: !isRunning && phMeterCollected,
          valueLabel: 'pH ${ph.toStringAsFixed(2)}',
          onChanged: (value) {
            setState(() {
              ph = value;
              activity = calculateActivity();
              showAnalysis = false;
            });
          },
        ),
      ],
    );
  }

  Widget _interactiveInstrumentSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String leftLabel,
    required String rightLabel,
    required Color accent,
    required bool enabled,
    required String valueLabel,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: .18)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.tune, size: 17, color: accent),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 10, letterSpacing: .8, fontWeight: FontWeight.w900, color: accent),
                ),
              ),
              Text(valueLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: accent,
              thumbColor: accent,
              overlayColor: accent.withValues(alpha: .12),
              inactiveTrackColor: accent.withValues(alpha: .14),
              trackHeight: 5,
            ),
            child: Slider(
              value: value.clamp(min, max).toDouble(),
              min: min,
              max: max,
              divisions: divisions,
              label: valueLabel,
              onChanged: enabled ? onChanged : null,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(leftLabel, style: const TextStyle(fontSize: 9)),
              Text(rightLabel, style: const TextStyle(fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SUBSTRATE
  // ==========================================================================

  Widget _buildSubstrateControl() {
    return _instrumentCard(
      color: const Color(0xFFF59F00),
      icon: Icons.science,
      title: 'SUBSTRATE CONCENTRATION',
      value:
      '${substrate.toStringAsFixed(substrateDecimals)} $substrateUnit',
      description:
      'Control the amount of substrate available for reaction.',
      child: LaboratorySubstrateControl(
        value: substrate,
        min: substrateMinimum,
        max: substrateMaximum,
        unit: substrateUnit,
        enabled: !isRunning && pipetteCollected,
        onChanged: (value) {
          setState(() {
            substrate =
                double.parse(
                  value.toStringAsFixed(
                    substrateDecimals,
                  ),
                );
            activity = calculateActivity();
            showAnalysis = false;
          });
        },
      ),
    );
  }

  Widget _instrumentCard({
    required Color color,
    required IconData icon,
    required String title,
    required String value,
    required String description,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            description,
            style: const TextStyle(
              fontSize: 11,
              color: EVLabColors.textMedium,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  // ==========================================================================
  // INHIBITOR
  // ==========================================================================

  Widget _buildInhibitor() {
    const color = Color(0xFFE64980);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.block,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INHIBITOR CONTROL',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Introduce an inhibitor and observe how it changes enzyme kinetics.',
                      style: TextStyle(
                        fontSize: 11,
                        color: EVLabColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          DropdownButtonFormField<InhibitionType>(
            initialValue: inhibitorType,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Inhibition mechanism',
              prefixIcon: const Icon(
                Icons.science_outlined,
                color: color,
              ),
              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(14),
              ),
            ),
            items: InhibitorData.inhibitors
                .map(
                  (inhibitor) {
                return DropdownMenuItem<
                    InhibitionType>(
                  value: inhibitor.type,
                  child: Text(
                    inhibitionTypeName(
                      inhibitor.type,
                    ),
                  ),
                );
              },
            )
                .toList(),
            onChanged: isRunning || !inhibitorCollected
                ? null
                : (value) {
              if (value == null) return;

              setState(() {
                inhibitorType = value;

                if (value ==
                    InhibitionType.none) {
                  inhibitorRatio = 0.0;
                }
              });
            },
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.055),
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: Text(
              inhibitorDescription,
              style: const TextStyle(
                color: EVLabColors.textMedium,
                height: 1.45,
                fontSize: 12,
              ),
            ),
          ),

          if (inhibitorType !=
              InhibitionType.none) ...[
            const SizedBox(height: 18),

            LaboratoryInhibitorControl(
              value: inhibitorRatio,
              min: 0,
              max: 5,
              inhibitorName: inhibitorName,
              enabled: !isRunning && inhibitorCollected,
              onChanged: (value) {
                setState(() {
                  inhibitorRatio =
                      double.parse(
                        value.toStringAsFixed(2),
                      );
                  activity = calculateActivity();
                  showAnalysis = false;
                });
              },
            ),

            const SizedBox(height: 10),

            const Text(
              'Normalized inhibitor concentration: [I]/Ki',
              style: TextStyle(
                fontSize: 10,
                color: EVLabColors.textLight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================================================
  // RUN BUTTON
  // ==========================================================================

  Widget _buildRunButton() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 62,
            child: ElevatedButton.icon(
              onPressed:
              isRunning || !_readyToRun ? null : runExperiment,
              icon: const Icon(
                Icons.play_arrow_rounded,
                size: 28,
              ),
              label: const Text(
                'RUN EXPERIMENT',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFF087F5B),
                foregroundColor: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 62,
          width: 62,
          child: OutlinedButton(
            onPressed:
            isRunning ? null : resetExperiment,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(18),
              ),
            ),
            child: const Icon(Icons.refresh),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // RESULT REVEAL
  // ==========================================================================

  Widget _buildResultReveal() {
    final color = getActivityColor();

    return AnimatedBuilder(
      animation: _resultController,
      builder: (context, child) {
        final curved = Curves.easeOutBack.transform(
          _resultController.value,
        );

        return Transform.scale(
          scale: 0.88 + (0.12 * curved),
          child: Opacity(
            opacity: _resultController.value.clamp(
              0.0,
              1.0,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(26),
                border: Border.all(
                  color: color.withValues(alpha: 0.20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'EXPERIMENT RESULT',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w900,
                      color: EVLabColors.textMedium,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '${activity.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),

                  Text(
                    getActivityLevel(),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),

                  const SizedBox(height: 18),

                  ClipRRect(
                    borderRadius:
                    BorderRadius.circular(20),
                    child:
                    LinearProgressIndicator(
                      value:
                      (activity / 100)
                          .clamp(0.0, 1.0),
                      minHeight: 13,
                      color: color,
                      backgroundColor:
                      Colors.grey.shade200,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: _resultStat(
                          Icons.thermostat,
                          'Temperature',
                          '${temperature.toStringAsFixed(1)}°C',
                        ),
                      ),
                      Expanded(
                        child: _resultStat(
                          Icons.water_drop,
                          'pH',
                          ph.toStringAsFixed(1),
                        ),
                      ),
                      Expanded(
                        child: _resultStat(
                          Icons.science,
                          'Substrate',
                          substrate.toStringAsFixed(
                            substrateDecimals,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _resultStat(
      IconData icon,
      String label,
      String value,
      ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF087F5B),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 9,
            color: EVLabColors.textLight,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // MOLECULAR MODEL
  // ==========================================================================

  Widget _buildMolecularModel() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF087F5B)
              .withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.view_in_ar,
                color: Color(0xFF087F5B),
              ),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'MOLECULAR VIEW',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                'SIMULATION',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: EVLabColors.textLight,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          const Text(
            'Educational visualization of enzyme-substrate interaction.',
            style: TextStyle(
              fontSize: 11,
              color: EVLabColors.textMedium,
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 270,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _moleculeController,
                _pulseController,
              ]),
              builder: (context, child) {
                return CustomPaint(
                  painter: _MolecularPainter(
                    progress:
                    _moleculeController.value,
                    pulse:
                    _pulseController.value,
                    activity: activity,
                    inhibitor:
                    inhibitorType !=
                        InhibitionType.none &&
                        inhibitorRatio > 0,
                    inhibitorType:
                    inhibitorType,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              _legendDot(
                const Color(0xFF087F5B),
                'Enzyme',
              ),
              _legendDot(
                const Color(0xFFFF9F1C),
                'Substrate',
              ),
              _legendDot(
                const Color(0xFF31B7D6),
                'Product',
              ),
              if (inhibitorType !=
                  InhibitionType.none)
                _legendDot(
                  const Color(0xFFE64980),
                  'Inhibitor',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(
      Color color,
      String label,
      ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // HANDS-ON LAB BENCH
  // ==========================================================================

  // Retained as a reusable legacy panel; the single main bench is used now.
  // ignore: unused_element
  Widget _buildHandsOnBench() {
    final mixPercent = (mixingQuality * 100).round();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF102A43),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science_outlined, color: Colors.white),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'HANDS-ON LAB BENCH',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Text(
                'MIX $mixPercent%',
                style: const TextStyle(
                  color: Color(0xFF8EF0D0),
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            samplePrepared
                ? 'Sample prepared. Keep mixing until the solution is homogeneous.'
                : 'Prepare the sample before running the reaction.',
            style: const TextStyle(
              color: Colors.white70,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _benchButton(
                  icon: Icons.water_drop,
                  label: 'ADD DROP',
                  subtitle: '$pipetteDrops drops',
                  onPressed: isRunning || !pipetteCollected ? null : _addPipetteDrop,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _benchButton(
                  icon: Icons.sync,
                  label: 'STIR',
                  subtitle: 'Mix sample',
                  onPressed: isRunning || !stirrerCollected ? null : _stirSample,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: mixingQuality.clamp(0.0, 1.0),
              minHeight: 9,
              backgroundColor: Colors.white12,
              color: const Color(0xFF55EFC4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _benchButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback? onPressed,
  }) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.10),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white12),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 25),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  void _addPipetteDrop() {
    if (isRunning || pipetteDrops >= 8) return;
    setState(() {
      pipetteDrops++;
      samplePrepared = true;
      substrate = (substrate + (substrateMaximum - substrateMinimum) * 0.025)
          .clamp(substrateMinimum, substrateMaximum)
          .toDouble();
      activity = calculateActivity();
      showAnalysis = false;
    });
  }

  void _stirSample() {
    if (isRunning) return;
    setState(() {
      samplePrepared = true;
      mixingQuality = (mixingQuality + 0.18).clamp(0.0, 1.0).toDouble();
      activity = calculateActivity();
      showAnalysis = false;
    });
  }

  // ==========================================================================
  // REAL 3D ENZYME VIEWER
  // ==========================================================================

  // Retained as a reusable legacy panel; the single main bench is used now.
  // ignore: unused_element
  Widget _build3DEnzymeViewer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF087F5B).withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
              child: Row(
                children: [
                  const Icon(Icons.view_in_ar, color: Color(0xFF087F5B)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '3D ENZYME EXPLORER',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: .8,
                      ),
                    ),
                  ),
                  Text(
                    widget.enzyme.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: EVLabColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                'Drag to rotate • pinch to zoom • inspect the active-site shape',
                style: TextStyle(
                  fontSize: 11,
                  color: EVLabColors.textMedium,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 320,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildMolecularModel(),
                  if (show3DModel && widget.enzyme.has3DModel)
                    ModelViewer(
                      key: ValueKey(widget.enzyme.model3D),
                      src: widget.enzyme.model3D,
                      alt: 'Interactive 3D model of ${widget.enzyme.name}',
                      autoRotate: false,
                      cameraControls: true,
                      ar: false,
                      shadowIntensity: 0.8,
                      exposure: 1.15,
                      backgroundColor: const Color(0xFFF4F8F5),
                    ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: const Color(0xFFF4F8F5),
              child: Text(
                widget.enzyme.modelDescription,
                style: const TextStyle(fontSize: 11, height: 1.35),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // SCIENTIFIC ANALYSIS
  // ==========================================================================

  Widget _buildAnalysis() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEEF9F5),
            Color(0xFFF8FBFA),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF087F5B)
              .withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.psychology,
                color: Color(0xFF087F5B),
              ),
              SizedBox(width: 9),
              Text(
                'WHY DID THIS HAPPEN?',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          const Text(
            'EV-LAB interprets the experimental conditions using the kinetic model.',
            style: TextStyle(
              fontSize: 11,
              color: EVLabColors.textMedium,
            ),
          ),

          const SizedBox(height: 16),

          _analysisFactor(
            icon: Icons.thermostat,
            title: 'Temperature',
            value:
            '${(_temperatureEffect() * 100).toStringAsFixed(0)}%',
            explanation:
            _temperatureExplanation(),
          ),

          const SizedBox(height: 10),

          _analysisFactor(
            icon: Icons.water_drop,
            title: 'pH',
            value:
            '${(_phEffect() * 100).toStringAsFixed(0)}%',
            explanation:
            _phExplanation(),
          ),

          const SizedBox(height: 10),

          _analysisFactor(
            icon: Icons.science,
            title: 'Substrate',
            value:
            '${(_substrateEffect() * 100).toStringAsFixed(0)}%',
            explanation:
            _substrateExplanation(),
          ),

          const SizedBox(height: 10),

          _analysisFactor(
            icon: Icons.block,
            title: 'Inhibition',
            value:
            inhibitorType == InhibitionType.none
                ? 'None'
                : inhibitorRatio
                .toStringAsFixed(2),
            explanation:
            _inhibitorExplanation(),
          ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(16),
            ),
            child: Text(
              _fullScientificExplanation(),
              style: const TextStyle(
                fontSize: 12,
                height: 1.55,
                color: EVLabColors.textMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _analysisFactor({
    required IconData icon,
    required String title,
    required String value,
    required String explanation,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF087F5B)
                  .withValues(alpha: 0.08),
              borderRadius:
              BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 19,
              color: const Color(0xFF087F5B),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight:
                          FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Color(0xFF087F5B),
                        fontWeight:
                        FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  explanation,
                  style: const TextStyle(
                    fontSize: 11,
                    color:
                    EVLabColors.textMedium,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _temperatureExplanation() {
    final optimum = _extractNumber(
      widget.enzyme.optimumTemperature,
      37,
    );

    if (_temperatureEffect() >= 0.9) {
      return 'The selected temperature is close to the validated optimum of '
          '${optimum.toStringAsFixed(1)}°C.';
    }

    return 'The selected temperature is farther from the validated optimum, '
        'reducing the temperature contribution to activity.';
  }

  String _phExplanation() {
    final optimum = _extractNumber(
      widget.enzyme.optimumPH,
      7,
    );

    if (_phEffect() >= 0.9) {
      return 'The pH is close to the enzyme’s validated optimum of '
          '${optimum.toStringAsFixed(1)}.';
    }

    return 'The pH differs from the validated optimum, so the simulation '
        'reduces the pH contribution to activity.';
  }

  String _substrateExplanation() {
    return 'Substrate-dependent velocity follows the Michaelis-Menten '
        'relationship. As substrate increases, velocity approaches Vmax.';
  }

  String _inhibitorExplanation() {
    if (inhibitorType == InhibitionType.none) {
      return 'No inhibitor is present, so inhibitor concentration does not '
          'reduce the simulated kinetic velocity.';
    }

    return '$inhibitorName is active at an [I]/Ki ratio of '
        '${inhibitorRatio.toStringAsFixed(2)}.';
  }

  // ==========================================================================
  // GRAPHS
  // ==========================================================================

  Widget _buildGraphs() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF7654C8)
              .withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.insights,
                color: Color(0xFF7654C8),
              ),
              SizedBox(width: 9),
              Text(
                'EXPERIMENTAL DATA',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          const Text(
            'Visualize how the experimental conditions relate to enzyme activity.',
            style: TextStyle(
              fontSize: 11,
              color: EVLabColors.textMedium,
            ),
          ),

          const SizedBox(height: 16),

          _graphCard(
            title: 'Temperature vs Activity',
            xLabel: 'Temperature (°C)',
            painter: _TemperatureGraphPainter(
              trials: trials,
              optimum:
              _extractNumber(
                widget.enzyme.optimumTemperature,
                37,
              ),
            ),
          ),

          const SizedBox(height: 14),

          _graphCard(
            title: 'pH vs Activity',
            xLabel: 'pH',
            painter: _PHGraphPainter(
              trials: trials,
              optimum:
              _extractNumber(
                widget.enzyme.optimumPH,
                7,
              ),
            ),
          ),

          const SizedBox(height: 14),

          _graphCard(
            title: 'Substrate vs Activity',
            xLabel:
            'Substrate ($substrateUnit)',
            painter: _SubstrateGraphPainter(
              trials: trials,
            ),
          ),
        ],
      ),
    );
  }

  Widget _graphCard({
    required String title,
    required String xLabel,
    required CustomPainter painter,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 190,
            width: double.infinity,
            child: CustomPaint(
              painter: painter,
            ),
          ),

          const SizedBox(height: 4),

          Center(
            child: Text(
              xLabel,
              style: const TextStyle(
                fontSize: 9,
                color: EVLabColors.textLight,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // HISTORY
  // ==========================================================================

  Widget _buildHistory() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.history,
                color: Color(0xFF087F5B),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'EXPERIMENT HISTORY',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${trials.length} trial${trials.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: 11,
                  color: EVLabColors.textLight,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ...List.generate(
            trials.length,
                (index) {
              final trial = trials[index];

              return Container(
                margin:
                const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F7F6),
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor:
                      const Color(0xFF087F5B),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight:
                          FontWeight.w900,
                        ),
                      ),
                    ),

                    const SizedBox(width: 11),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${trial.temperature.toStringAsFixed(1)}°C  •  pH ${trial.ph.toStringAsFixed(1)}',
                            style:
                            const TextStyle(
                              fontWeight:
                              FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            trial.inhibitorType ==
                                InhibitionType.none
                                ? 'No inhibitor'
                                : '${inhibitionTypeName(trial.inhibitorType)} • [I]/Ki ${trial.inhibitorRatio.toStringAsFixed(2)}',
                            style:
                            const TextStyle(
                              fontSize: 10,
                              color:
                              EVLabColors
                                  .textMedium,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            'Substrate: ${trial.substrate.toStringAsFixed(substrateDecimals)} $substrateUnit',
                            style:
                            const TextStyle(
                              fontSize: 10,
                              color:
                              EVLabColors
                                  .textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      '${trial.activity.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color:
                        EVLabColors.emeraldDark,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // RESULTS SCREEN
  // ==========================================================================

  Widget _buildResultsButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          _phetBenchKey.currentState?.hideMolecularView();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ResultScreen(
                trials: trials,
                enzymeName: widget.enzyme.name,
                enzyme: widget.enzyme,
                lastInhibitorType:
                trials.isEmpty ? inhibitorType : trials.last.inhibitorType,
                lastInhibitorRatio:
                trials.isEmpty ? inhibitorRatio : trials.last.inhibitorRatio,
              ),
            ),
          );
        },
        icon: const Icon(
          Icons.analytics_outlined,
        ),
        label: const Text(
          'VIEW DETAILED RESULTS',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildInLabDetailedResultAction() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: EVLabGradients.purple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.fact_check_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DETAILED RESULT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: .5)),
                SizedBox(height: 3),
                Text('Review your conditions, activity, trends, and scientific interpretation.', style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Open detailed results',
            onPressed: () {
              _phetBenchKey.currentState?.hideMolecularView();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ResultScreen(
                    trials: trials,
                    enzymeName: widget.enzyme.name,
                    enzyme: widget.enzyme,
                    lastInhibitorType:
                    trials.isEmpty ? inhibitorType : trials.last.inhibitorType,
                    lastInhibitorRatio:
                    trials.isEmpty ? inhibitorRatio : trials.last.inhibitorRatio,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SCIENTIFIC REFERENCE
  // ==========================================================================

  Widget _buildScientificReference() {
    return ExpansionTile(
      tilePadding:
      const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      childrenPadding:
      const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        18,
      ),
      backgroundColor: Colors.white,
      collapsedBackgroundColor:
      Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(20),
      ),
      collapsedShape:
      RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(20),
      ),
      leading: const Icon(
        Icons.menu_book_outlined,
        color: Color(0xFF087F5B),
      ),
      title: const Text(
        'Scientific Information',
        style: TextStyle(
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: const Text(
        'Reference values used by the simulation',
        style: TextStyle(
          fontSize: 10,
          color: EVLabColors.textMedium,
        ),
      ),
      children: [
        _referenceRow(
          'Substrate',
          widget.enzyme.substrate,
        ),
        _referenceRow(
          'Optimum pH',
          widget.enzyme.optimumPH,
        ),
        _referenceRow(
          'Optimum Temperature',
          widget.enzyme.optimumTemperature,
        ),
        _referenceRow(
          'Vmax',
          '${widget.enzyme.vmax} ${widget.enzyme.vmaxUnit}',
        ),
        _referenceRow(
          'Km',
          widget.enzyme.km.toString(),
        ),
        const SizedBox(height: 10),
        const Divider(),
        const SizedBox(height: 8),
        Text(
          inhibitorType == InhibitionType.none
              ? 'Michaelis-Menten kinetics'
              : '$inhibitorName inhibition kinetics',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: EVLabColors.emeraldDark,
          ),
        ),
      ],
    );
  }

  Widget _referenceRow(
      String title,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color:
                EVLabColors.textMedium,
                fontSize: 12,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // RUNNING OVERLAY
  // ==========================================================================

  Widget _buildRunningOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.60),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(30),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale =
                      0.95 +
                          (_pulseController.value *
                              0.08);

                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      padding:
                      const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                        const Color(0xFF087F5B)
                            .withValues(
                          alpha: 0.10,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox(
                        width: 45,
                        height: 45,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 5,
                          color:
                          Color(0xFF087F5B),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Running Experiment',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Analyzing temperature, pH, substrate, '
                    'and $inhibitorName inhibition...',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: EVLabColors.textMedium,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'Collecting experimental data...',
                style: TextStyle(
                  color: Color(0xFF087F5B),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // PH
  // ==========================================================================

  Color _phColor() {
    if (ph < 4) return Colors.red;
    if (ph < 6) return Colors.orange;
    if (ph < 8) return Colors.green;
    if (ph < 11) return Colors.blue;

    return Colors.purple;
  }

  String _phDescription() {
    if (ph < 4) return 'Strongly acidic';
    if (ph < 6) return 'Acidic';
    if (ph < 7) return 'Slightly acidic';
    if (ph == 7) return 'Neutral';
    if (ph <= 8) return 'Slightly alkaline';
    if (ph < 11) return 'Alkaline';

    return 'Strongly alkaline';
  }
}

// ============================================================================
// LIVE INDICATOR
// ============================================================================

class _LiveIndicator extends StatelessWidget {
  const _LiveIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: Color(0xFF55EFC4),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        const Text(
          'LIVE',
          style: TextStyle(
            color: Color(0xFF55EFC4),
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// THERMOMETER
// ============================================================================

class LaboratoryThermometer
    extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final bool enabled;

  const LaboratoryThermometer({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.enabled = true,
  });

  void _updateFromPosition(
      Offset position,
      double height,
      ) {
    final usableTop = 20.0;
    final usableBottom = height - 35.0;

    final y = position.dy.clamp(
      usableTop,
      usableBottom,
    );

    final fraction =
        1.0 -
            ((y - usableTop) /
                (usableBottom - usableTop));

    final newValue =
        min +
            (max - min) * fraction;

    onChanged(
      newValue.clamp(min, max),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 285,
      child: LayoutBuilder(
        builder: (
            context,
            constraints,
            ) {
          return GestureDetector(
            behavior:
            HitTestBehavior.opaque,
            onVerticalDragStart: enabled
                ? (details) {
              _updateFromPosition(
                details.localPosition,
                constraints.maxHeight,
              );
            }
                : null,
            onVerticalDragUpdate: enabled
                ? (details) {
              _updateFromPosition(
                details.localPosition,
                constraints.maxHeight,
              );
            }
                : null,
            child: CustomPaint(
              painter:
              _ThermometerPainter(
                value: value,
                min: min,
                max: max,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// THERMOMETER PAINTER
// ============================================================================

class _ThermometerPainter
    extends CustomPainter {
  final double value;
  final double min;
  final double max;

  _ThermometerPainter({
    required this.value,
    required this.min,
    required this.max,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final centerX =
        size.width * 0.40;

    const top = 22.0;
    final bottom =
        size.height - 40.0;

    const tubeWidth = 32.0;
    const bulbRadius = 27.0;

    final tubeTop = top;

    final tubeBottom =
        bottom - bulbRadius + 3;

    final tubeHeight =
        tubeBottom - tubeTop;

    final fraction =
    ((value - min) /
        (max - min))
        .clamp(0.0, 1.0);

    final mercuryHeight =
        tubeHeight * fraction;

    final glassFill = Paint()
      ..color = Colors.white
          .withValues(alpha: 0.8);

    final glassBorder = Paint()
      ..color = Colors.blueGrey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final tubeRect =
    RRect.fromRectAndRadius(
      Rect.fromLTWH(
        centerX - tubeWidth / 2,
        tubeTop,
        tubeWidth,
        tubeHeight,
      ),
      const Radius.circular(16),
    );

    canvas.drawRRect(
      tubeRect,
      glassFill,
    );

    canvas.drawRRect(
      tubeRect,
      glassBorder,
    );

    final mercuryPaint = Paint()
      ..color = Colors.red.shade600;

    final mercuryTop =
        tubeBottom -
            mercuryHeight;

    final mercuryRect =
    RRect.fromRectAndRadius(
      Rect.fromLTRB(
        centerX - 8,
        mercuryTop,
        centerX + 8,
        tubeBottom,
      ),
      const Radius.circular(9),
    );

    canvas.drawRRect(
      mercuryRect,
      mercuryPaint,
    );

    canvas.drawCircle(
      Offset(centerX, bottom),
      bulbRadius,
      mercuryPaint,
    );

    final highlightPaint = Paint()
      ..color = Colors.white
          .withValues(alpha: 0.65);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          centerX - 7,
          tubeTop + 8,
          4,
          tubeHeight - 12,
        ),
        const Radius.circular(2),
      ),
      highlightPaint,
    );

    final tickPaint = Paint()
      ..color = Colors.blueGrey.shade600
      ..strokeWidth = 1.5;

    for (int i = 0; i <= 10; i++) {
      final tickFraction = i / 10;

      final y =
          tubeTop +
              tubeHeight *
                  (1 - tickFraction);

      final major = i % 2 == 0;

      canvas.drawLine(
        Offset(
          centerX + 20,
          y,
        ),
        Offset(
          centerX +
              (major ? 38 : 31),
          y,
        ),
        tickPaint,
      );

      if (major) {
        final tickValue =
            min +
                (max - min) *
                    tickFraction;

        final painter = TextPainter(
          text: TextSpan(
            text:
            tickValue.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 10,
              fontWeight:
              FontWeight.w700,
              color:
              Colors.blueGrey.shade700,
            ),
          ),
          textDirection:
          TextDirection.ltr,
        );

        painter.layout();

        painter.paint(
          canvas,
          Offset(
            centerX + 44,
            y -
                painter.height / 2,
          ),
        );
      }
    }

    final display =
    TextPainter(
      text: TextSpan(
        text:
        '${value.toStringAsFixed(1)}°C',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: Colors.red,
        ),
      ),
      textDirection:
      TextDirection.ltr,
    );

    display.layout();

    display.paint(
      canvas,
      Offset(
        10,
        size.height / 2 -
            display.height / 2,
      ),
    );

    final label =
    TextPainter(
      text: const TextSpan(
        text: 'THERMOMETER',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Colors.blueGrey,
        ),
      ),
      textDirection:
      TextDirection.ltr,
    );

    label.layout();

    label.paint(
      canvas,
      Offset(
        centerX -
            label.width / 2,
        size.height - 18,
      ),
    );
  }

  @override
  bool shouldRepaint(
      covariant _ThermometerPainter oldDelegate,
      ) {
    return oldDelegate.value != value ||
        oldDelegate.min != min ||
        oldDelegate.max != max;
  }
}

// ============================================================================
// PH METER
// ============================================================================

class LaboratoryPHMeter
    extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final bool enabled;

  const LaboratoryPHMeter({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 105,
      child: LayoutBuilder(
        builder: (
            context,
            constraints,
            ) {
          return GestureDetector(
            behavior:
            HitTestBehavior.opaque,
            onHorizontalDragUpdate: enabled
                ? (details) {
              final x =
              details.localPosition.dx
                  .clamp(
                0.0,
                constraints.maxWidth,
              );

              final fraction =
                  x /
                      constraints.maxWidth;

              final newPH =
                  fraction * 14;

              onChanged(
                newPH.clamp(
                  0.0,
                  14.0,
                ),
              );
            }
                : null,
            onTapDown: enabled
                ? (details) {
              final fraction =
                  details.localPosition.dx /
                      constraints.maxWidth;

              onChanged(
                (fraction * 14)
                    .clamp(0.0, 14.0),
              );
            }
                : null,
            child: CustomPaint(
              painter:
              _PHMeterPainter(
                value: value,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PHMeterPainter
    extends CustomPainter {
  final double value;

  _PHMeterPainter({
    required this.value,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final left = 20.0;
    final right =
        size.width - 20.0;
    final y = 48.0;
    final width =
        right - left;

    final gradient =
    LinearGradient(
      colors: const [
        Colors.red,
        Colors.orange,
        Colors.yellow,
        Colors.green,
        Colors.cyan,
        Colors.blue,
        Colors.purple,
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(
          left,
          y - 10,
          width,
          20,
        ),
      );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          left,
          y - 10,
          width,
          20,
        ),
        const Radius.circular(10),
      ),
      paint,
    );

    final fraction =
    (value / 14).clamp(0.0, 1.0);

    final markerX =
        left + width * fraction;

    final markerPaint = Paint()
      ..color = Colors.black87;

    canvas.drawCircle(
      Offset(markerX, y),
      9,
      markerPaint,
    );

    canvas.drawCircle(
      Offset(markerX, y),
      4,
      Paint()
        ..color = Colors.white,
    );

    for (int i = 0; i <= 14; i++) {
      final x =
          left +
              width * (i / 14);

      final text =
      TextPainter(
        text: TextSpan(
          text: '$i',
          style: TextStyle(
            fontSize: 9,
            fontWeight:
            FontWeight.w700,
            color:
            Colors.grey.shade700,
          ),
        ),
        textDirection:
        TextDirection.ltr,
      );

      text.layout();

      text.paint(
        canvas,
        Offset(
          x - text.width / 2,
          y + 20,
        ),
      );
    }

    final display =
    TextPainter(
      text: TextSpan(
        text:
        'pH ${value.toStringAsFixed(1)}',
        style: const TextStyle(
          fontSize: 20,
          fontWeight:
          FontWeight.w900,
          color: Colors.black87,
        ),
      ),
      textDirection:
      TextDirection.ltr,
    );

    display.layout();

    display.paint(
      canvas,
      Offset(
        size.width / 2 -
            display.width / 2,
        0,
      ),
    );
  }

  @override
  bool shouldRepaint(
      covariant _PHMeterPainter oldDelegate,
      ) {
    return oldDelegate.value != value;
  }
}

// ============================================================================
// SUBSTRATE CONTROL
// ============================================================================

class LaboratorySubstrateControl
    extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final String unit;
  final bool enabled;
  final ValueChanged<double> onChanged;

  const LaboratorySubstrateControl({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final fraction =
    ((value - min) /
        (max - min))
        .clamp(0.0, 1.0);

    return Column(
      children: [
        SizedBox(
          height: 170,
          child: GestureDetector(
            onVerticalDragUpdate: enabled
                ? (details) {
              final delta =
                  -details.delta.dy /
                      170;

              final next =
                  value +
                      (max - min) *
                          delta;

              onChanged(
                next.clamp(
                  min,
                  max,
                ),
              );
            }
                : null,
            child: CustomPaint(
              painter:
              _SubstratePainter(
                fraction: fraction,
                value: value,
                unit: unit,
              ),
              size: const Size(
                double.infinity,
                170,
              ),
            ),
          ),
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: 100,
          activeColor:
          const Color(0xFFF59F00),
          onChanged:
          enabled ? onChanged : null,
        ),
        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            Text(
              min.toStringAsFixed(
                min < 1 ? 2 : 1,
              ),
              style: const TextStyle(
                fontSize: 9,
              ),
            ),
            const Text(
              'SUBSTRATE LEVEL',
              style: TextStyle(
                fontSize: 9,
                fontWeight:
                FontWeight.w900,
                color:
                EVLabColors.textMedium,
              ),
            ),
            Text(
              max.toStringAsFixed(
                max < 1 ? 2 : 1,
              ),
              style: const TextStyle(
                fontSize: 9,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SubstratePainter
    extends CustomPainter {
  final double fraction;
  final double value;
  final String unit;

  _SubstratePainter({
    required this.fraction,
    required this.value,
    required this.unit,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final centerX =
        size.width / 2;

    final containerWidth =
    min(150.0, size.width * 0.42);

    final containerHeight = 125.0;

    final left =
        centerX -
            containerWidth / 2;

    final top = 22.0;

    final container =
    RRect.fromRectAndRadius(
      Rect.fromLTWH(
        left,
        top,
        containerWidth,
        containerHeight,
      ),
      const Radius.circular(18),
    );

    canvas.drawRRect(
      container,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    canvas.drawRRect(
      container,
      Paint()
        ..color = Colors.blueGrey.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final liquidHeight =
        containerHeight *
            0.72 *
            fraction;

    final liquidTop =
        top +
            containerHeight -
            8 -
            liquidHeight;

    canvas.save();

    canvas.clipRRect(container);

    canvas.drawRect(
      Rect.fromLTWH(
        left,
        liquidTop,
        containerWidth,
        liquidHeight + 10,
      ),
      Paint()
        ..color = const Color(0xFFFFB52E)
            .withValues(alpha: 0.75),
    );

    canvas.restore();

    final label =
    TextPainter(
      text: TextSpan(
        text:
        '${value.toStringAsFixed(2)} $unit',
        style: const TextStyle(
          fontSize: 14,
          fontWeight:
          FontWeight.w900,
          color: Color(0xFFF59F00),
        ),
      ),
      textDirection:
      TextDirection.ltr,
    );

    label.layout();

    label.paint(
      canvas,
      Offset(
        centerX -
            label.width / 2,
        size.height - 15,
      ),
    );
  }

  @override
  bool shouldRepaint(
      covariant _SubstratePainter oldDelegate,
      ) {
    return oldDelegate.value != value;
  }
}

// ============================================================================
// INHIBITOR CONTROL
// ============================================================================

class LaboratoryInhibitorControl
    extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final String inhibitorName;
  final bool enabled;
  final ValueChanged<double> onChanged;

  const LaboratoryInhibitorControl({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.inhibitorName,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
        const Color(0xFFE64980)
            .withValues(alpha: 0.045),
        borderRadius:
        BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.science,
                color: Color(0xFFE64980),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  inhibitorName,
                  style: const TextStyle(
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '[I]/Ki ${value.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFFE64980),
                  fontWeight:
                  FontWeight.w900,
                ),
              ),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: 100,
            activeColor:
            const Color(0xFFE64980),
            onChanged:
            enabled ? onChanged : null,
          ),
          const Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0',
                style: TextStyle(
                  fontSize: 9,
                ),
              ),
              Text(
                'INHIBITOR CONCENTRATION',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),
              Text(
                '5',
                style: TextStyle(
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// REACTION CHAMBER PAINTER
// ============================================================================

class _ReactionChamberPainter
    extends CustomPainter {
  final double particleProgress;
  final double pulseProgress;
  final double reactionProgress;
  final double moleculeProgress;
  final bool active;
  final double activity;
  final bool inhibitor;

  _ReactionChamberPainter({
    required this.particleProgress,
    required this.pulseProgress,
    required this.reactionProgress,
    required this.moleculeProgress,
    required this.active,
    required this.activity,
    required this.inhibitor,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final center =
    Offset(
      size.width / 2,
      size.height / 2,
    );

    final chamberRadius =
    min(
      size.width * 0.38,
      size.height * 0.38,
    );

    final glow =
        0.8 +
            (pulseProgress * 0.25);

    canvas.drawCircle(
      center,
      chamberRadius + 14,
      Paint()
        ..color =
        const Color(0xFF31D0AA)
            .withValues(
          alpha:
          0.04 * glow,
        ),
    );

    canvas.drawCircle(
      center,
      chamberRadius,
      Paint()
        ..color =
        const Color(0xFF102F38)
            .withValues(alpha: 0.85)
        ..style =
            PaintingStyle.fill,
    );

    canvas.drawCircle(
      center,
      chamberRadius,
      Paint()
        ..color =
        const Color(0xFF4DE4C1)
            .withValues(alpha: 0.30)
        ..style =
            PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Enzyme
    final enzymePath =
    Path();

    enzymePath.moveTo(
      center.dx - 52,
      center.dy - 35,
    );

    enzymePath.cubicTo(
      center.dx - 75,
      center.dy - 75,
      center.dx - 25,
      center.dy - 88,
      center.dx + 5,
      center.dy - 63,
    );

    enzymePath.cubicTo(
      center.dx + 52,
      center.dy - 80,
      center.dx + 76,
      center.dy - 35,
      center.dx + 52,
      center.dy + 3,
    );

    enzymePath.cubicTo(
      center.dx + 78,
      center.dy + 35,
      center.dx + 37,
      center.dy + 75,
      center.dx + 2,
      center.dy + 54,
    );

    enzymePath.cubicTo(
      center.dx - 35,
      center.dy + 78,
      center.dx - 78,
      center.dy + 42,
      center.dx - 52,
      center.dy - 35,
    );

    canvas.drawPath(
      enzymePath,
      Paint()
        ..color =
        const Color(0xFF087F5B)
            .withValues(
          alpha:
          0.82 + activity / 500,
        ),
    );

    // Active site
    final sitePaint = Paint()
      ..color = const Color(0xFF061C25);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          center.dx + 30,
          center.dy - 5,
        ),
        width: 35,
        height: 52,
      ),
      sitePaint,
    );

    // Moving substrate particles
    for (int i = 0; i < 8; i++) {
      final phase =
          (particleProgress +
              i / 8) %
              1.0;

      final angle =
          phase * pi * 2;

      final radius =
          chamberRadius *
              (0.55 +
                  0.18 *
                      sin(i * 2.0));

      final particle =
      Offset(
        center.dx +
            cos(angle + i) *
                radius,
        center.dy +
            sin(angle + i) *
                radius *
                0.65,
      );

      canvas.drawCircle(
        particle,
        3.5,
        Paint()
          ..color =
          const Color(0xFFFFB52E)
              .withValues(
            alpha:
            0.45 +
                activity / 180,
          ),
      );
    }

    // Reaction products
    if (active || activity > 0) {
      for (int i = 0; i < 5; i++) {
        final p =
            (moleculeProgress +
                i * 0.19) %
                1.0;

        final product =
        Offset(
          center.dx +
              80 * p,
          center.dy -
              55 +
              i * 27,
        );

        canvas.drawCircle(
          product,
          4,
          Paint()
            ..color =
            const Color(0xFF31B7D6)
                .withValues(
              alpha:
              (1 - p).clamp(
                0.1,
                1.0,
              ),
            ),
        );
      }
    }

    // Inhibitor
    if (inhibitor) {
      for (int i = 0; i < 4; i++) {
        final angle =
            moleculeProgress *
                pi *
                2 +
                i;

        final inhibitorPosition =
        Offset(
          center.dx +
              cos(angle) * 95,
          center.dy +
              sin(angle) * 55,
        );

        canvas.drawCircle(
          inhibitorPosition,
          6,
          Paint()
            ..color =
            const Color(0xFFE64980)
                .withValues(
              alpha: 0.85,
            ),
        );

        canvas.drawCircle(
          inhibitorPosition,
          10,
          Paint()
            ..color =
            const Color(0xFFE64980)
                .withValues(
              alpha: 0.08,
            ),
        );
      }
    }

    final status =
    active
        ? 'REACTION ACTIVE'
        : activity > 0
        ? 'DATA COLLECTED'
        : 'READY';

    final text =
    TextPainter(
      text: TextSpan(
        text: status,
        style: const TextStyle(
          color: Color(0xFF72F2D0),
          fontSize: 10,
          fontWeight:
          FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
      textDirection:
      TextDirection.ltr,
    );

    text.layout();

    text.paint(
      canvas,
      Offset(
        center.dx -
            text.width / 2,
        size.height - 20,
      ),
    );
  }

  @override
  bool shouldRepaint(
      covariant _ReactionChamberPainter oldDelegate,
      ) {
    return true;
  }
}

// ============================================================================
// MOLECULAR PAINTER
// ============================================================================

class _MolecularPainter
    extends CustomPainter {
  final double progress;
  final double pulse;
  final double activity;
  final bool inhibitor;
  final InhibitionType inhibitorType;

  _MolecularPainter({
    required this.progress,
    required this.pulse,
    required this.activity,
    required this.inhibitor,
    required this.inhibitorType,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final center =
    Offset(
      size.width / 2,
      size.height / 2,
    );

    // 3D shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          center.dx,
          center.dy + 60,
        ),
        width: 180,
        height: 35,
      ),
      Paint()
        ..color = Colors.black
            .withValues(alpha: 0.08),
    );

    // Enzyme body
    final path = Path();

    path.moveTo(
      center.dx - 70,
      center.dy - 35,
    );

    path.cubicTo(
      center.dx - 100,
      center.dy - 85,
      center.dx - 30,
      center.dy - 110,
      center.dx + 20,
      center.dy - 70,
    );

    path.cubicTo(
      center.dx + 95,
      center.dy - 85,
      center.dx + 105,
      center.dy - 15,
      center.dx + 60,
      center.dy + 20,
    );

    path.cubicTo(
      center.dx + 100,
      center.dy + 75,
      center.dx + 25,
      center.dy + 100,
      center.dx - 15,
      center.dy + 60,
    );

    path.cubicTo(
      center.dx - 70,
      center.dy + 85,
      center.dx - 110,
      center.dy + 15,
      center.dx - 70,
      center.dy - 35,
    );

    canvas.drawPath(
      path,
      Paint()
        ..shader =
        const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0BAA78),
            Color(0xFF087F5B),
            Color(0xFF075E54),
          ],
        ).createShader(
          Rect.fromCenter(
            center: center,
            width: 220,
            height: 220,
          ),
        ),
    );

    // Dark cavity
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          center.dx + 42,
          center.dy - 3,
        ),
        width: 50,
        height: 70,
      ),
      Paint()
        ..color = const Color(0xFF042C2A),
    );

    // Highlight
    canvas.drawCircle(
      Offset(
        center.dx - 35,
        center.dy - 45,
      ),
      15,
      Paint()
        ..color = Colors.white
            .withValues(alpha: 0.12),
    );

    // Substrate
    final substrateProgress =
        (progress * 2) %
            1.0;

    final substratePosition =
    Offset(
      center.dx -
          150 +
          substrateProgress *
              145,
      center.dy -
          75 +
          sin(
            substrateProgress *
                pi *
                2,
          ) *
              10,
    );

    final substratePaint =
    Paint()
      ..color =
      const Color(0xFFFFA62B);

    canvas.drawCircle(
      substratePosition,
      13,
      substratePaint,
    );

    canvas.drawCircle(
      Offset(
        substratePosition.dx - 4,
        substratePosition.dy - 4,
      ),
      4,
      Paint()
        ..color = Colors.white
            .withValues(alpha: 0.45),
    );

    // Products
    for (int i = 0; i < 2; i++) {
      final p =
          (progress +
              0.5 * i) %
              1.0;

      final product =
      Offset(
        center.dx +
            105 +
            p * 30,
        center.dy -
            15 +
            i * 32,
      );

      canvas.drawCircle(
        product,
        8,
        Paint()
          ..color =
          const Color(0xFF31B7D6)
              .withValues(
            alpha:
            0.3 + 0.7 * p,
          ),
      );
    }

    // Inhibitor
    if (inhibitor) {
      final inhibitorAngle =
          progress * pi * 2;

      final position =
      Offset(
        center.dx +
            cos(inhibitorAngle) *
                95,
        center.dy +
            sin(inhibitorAngle) *
                70,
      );

      canvas.drawCircle(
        position,
        11,
        Paint()
          ..color =
          const Color(0xFFE64980),
      );

      canvas.drawCircle(
        position,
        18,
        Paint()
          ..color =
          const Color(0xFFE64980)
              .withValues(alpha: 0.10),
      );
    }

    final label =
    TextPainter(
      text: TextSpan(
        text:
        inhibitor
            ? inhibitionTypeName(
          inhibitorType,
        )
            : 'ENZYME + SUBSTRATE',
        style: TextStyle(
          fontSize: 11,
          fontWeight:
          FontWeight.w900,
          color: inhibitor
              ? const Color(0xFFE64980)
              : const Color(0xFF087F5B),
        ),
      ),
      textDirection:
      TextDirection.ltr,
    );

    label.layout();

    label.paint(
      canvas,
      Offset(
        center.dx -
            label.width / 2,
        size.height - 25,
      ),
    );
  }

  @override
  bool shouldRepaint(
      covariant _MolecularPainter oldDelegate,
      ) {
    return true;
  }
}

// ============================================================================
// GRAPH BASE
// ============================================================================

abstract class _GraphPainter
    extends CustomPainter {
  void drawAxes(
      Canvas canvas,
      Size size,
      ) {
    const left = 38.0;
    const bottom = 20.0;
    const top = 10.0;
    const right = 12.0;

    final axisPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1.3;

    canvas.drawLine(
      const Offset(left, top),
      Offset(
        left,
        size.height - bottom,
      ),
      axisPaint,
    );

    canvas.drawLine(
      Offset(
        left,
        size.height - bottom,
      ),
      Offset(
        size.width - right,
        size.height - bottom,
      ),
      axisPaint,
    );

    for (int i = 0; i <= 4; i++) {
      final y =
          top +
              (size.height -
                  top -
                  bottom) *
                  (i / 4);

      canvas.drawLine(
        Offset(left, y),
        Offset(
          size.width - right,
          y,
        ),
        Paint()
          ..color =
              Colors.grey.shade200,
      );

      final label =
      TextPainter(
        text: TextSpan(
          text:
          '${100 - i * 25}',
          style: TextStyle(
            fontSize: 8,
            color:
            Colors.grey.shade600,
          ),
        ),
        textDirection:
        TextDirection.ltr,
      );

      label.layout();

      label.paint(
        canvas,
        Offset(
          4,
          y -
              label.height / 2,
        ),
      );
    }
  }

  void drawTrials(
      Canvas canvas,
      Size size,
      List<Offset> points,
      ) {
    if (points.isEmpty) return;

    final linePaint = Paint()
      ..color = const Color(0xFF7654C8)
      ..strokeWidth = 2.5
      ..style =
          PaintingStyle.stroke;

    if (points.length > 1) {
      final path = Path()
        ..moveTo(
          points.first.dx,
          points.first.dy,
        );

      for (final point
      in points.skip(1)) {
        path.lineTo(
          point.dx,
          point.dy,
        );
      }

      canvas.drawPath(
        path,
        linePaint,
      );
    }

    for (final point in points) {
      canvas.drawCircle(
        point,
        4.5,
        Paint()
          ..color =
          const Color(0xFF7654C8),
      );

      canvas.drawCircle(
        point,
        2,
        Paint()
          ..color =
              Colors.white,
      );
    }
  }
}

// ============================================================================
// TEMPERATURE GRAPH
// ============================================================================

class _TemperatureGraphPainter
    extends _GraphPainter {
  final List<ExperimentTrial> trials;
  final double optimum;

  _TemperatureGraphPainter({
    required this.trials,
    required this.optimum,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    drawAxes(canvas, size);

    if (trials.isEmpty) return;

    final minX =
    trials
        .map(
          (e) => e.temperature,
    )
        .reduce(min);

    final maxX =
    trials
        .map(
          (e) => e.temperature,
    )
        .reduce(max);

    final range =
    maxX - minX == 0
        ? 1.0
        : maxX - minX;

    final points =
    trials.map(
          (trial) {
        final x =
            38 +
                ((trial.temperature -
                    minX) /
                    range) *
                    (size.width - 50);

        final y =
            10 +
                (1 -
                    trial.activity /
                        100) *
                    (size.height - 30);

        return Offset(x, y);
      },
    ).toList();

    drawTrials(
      canvas,
      size,
      points,
    );
  }

  @override
  bool shouldRepaint(
      covariant _TemperatureGraphPainter oldDelegate,
      ) =>
      true;
}

// ============================================================================
// PH GRAPH
// ============================================================================

class _PHGraphPainter
    extends _GraphPainter {
  final List<ExperimentTrial> trials;
  final double optimum;

  _PHGraphPainter({
    required this.trials,
    required this.optimum,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    drawAxes(canvas, size);

    if (trials.isEmpty) return;

    final points =
    trials.map(
          (trial) {
        final x =
            38 +
                (trial.ph / 14) *
                    (size.width - 50);

        final y =
            10 +
                (1 -
                    trial.activity /
                        100) *
                    (size.height - 30);

        return Offset(x, y);
      },
    ).toList();

    drawTrials(
      canvas,
      size,
      points,
    );
  }

  @override
  bool shouldRepaint(
      covariant _PHGraphPainter oldDelegate,
      ) =>
      true;
}

// ============================================================================
// SUBSTRATE GRAPH
// ============================================================================

class _SubstrateGraphPainter
    extends _GraphPainter {
  final List<ExperimentTrial> trials;

  _SubstrateGraphPainter({
    required this.trials,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    drawAxes(canvas, size);

    if (trials.isEmpty) return;

    final minX =
    trials
        .map(
          (e) => e.substrate,
    )
        .reduce(min);

    final maxX =
    trials
        .map(
          (e) => e.substrate,
    )
        .reduce(max);

    final range =
    maxX - minX == 0
        ? 1.0
        : maxX - minX;

    final points =
    trials.map(
          (trial) {
        final x =
            38 +
                ((trial.substrate -
                    minX) /
                    range) *
                    (size.width - 50);

        final y =
            10 +
                (1 -
                    trial.activity /
                        100) *
                    (size.height - 30);

        return Offset(x, y);
      },
    ).toList();

    drawTrials(
      canvas,
      size,
      points,
    );
  }

  @override
  bool shouldRepaint(
      covariant _SubstrateGraphPainter oldDelegate,
      ) =>
      true;
}
