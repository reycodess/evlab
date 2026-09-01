import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/three_d_trial_graph.dart';
import '../widgets/scientific_kinetics_graphs.dart';
import '../widgets/enzyme_mechanism_illustration.dart';
import '../models/enzyme.dart';
import '../models/inhibitor.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

import 'virtual_lab_screen.dart';

class ResultScreen extends StatefulWidget {
  final List<ExperimentTrial> trials;
  final String enzymeName;
  final Enzyme? enzyme;
  final InhibitionType? lastInhibitorType;
  final double lastInhibitorRatio;

  const ResultScreen({
    super.key,
    required this.trials,
    required this.enzymeName,
    this.enzyme,
    this.lastInhibitorType,
    this.lastInhibitorRatio = 0,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _moleculeController;
  late AnimationController _pulseController;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController schoolController = TextEditingController();

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color deeperGreen = Color(0xFF0D3B12);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color paleGreen = Color(0xFFF4FAF5);
  static const Color backgroundColor = Color(0xFFF3F7F4);

  // ============================================================
  // CALCULATIONS
  // ============================================================

  double get averageActivity {
    if (widget.trials.isEmpty) return 0;

    return widget.trials
        .map((trial) => trial.activity)
        .reduce((a, b) => a + b) /
        widget.trials.length;
  }

  double get highestActivity {
    if (widget.trials.isEmpty) return 0;

    return widget.trials
        .map((trial) => trial.activity)
        .reduce((a, b) => a > b ? a : b);
  }

  double get lowestActivity {
    if (widget.trials.isEmpty) return 0;

    return widget.trials
        .map((trial) => trial.activity)
        .reduce((a, b) => a < b ? a : b);
  }

  int get bestTrialIndex {
    if (widget.trials.isEmpty) return -1;

    int index = 0;

    for (int i = 1; i < widget.trials.length; i++) {
      if (widget.trials[i].activity >
          widget.trials[index].activity) {
        index = i;
      }
    }

    return index;
  }

  ExperimentTrial? get bestTrial {
    if (bestTrialIndex == -1) return null;
    return widget.trials[bestTrialIndex];
  }

  double get activityRange {
    return highestActivity - lowestActivity;
  }

  double get consistencyScore {
    if (widget.trials.length < 2) return 100;

    final average = averageActivity;

    if (average == 0) return 0;

    final deviations = widget.trials.map(
          (trial) => (trial.activity - average).abs(),
    );

    final meanDeviation =
        deviations.reduce((a, b) => a + b) /
            deviations.length;

    final score = 100 - ((meanDeviation / average) * 100);

    return score.clamp(0, 100);
  }

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();

    _moleculeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (EVLabSettings.animationsEnabled.value) {
      _moleculeController.repeat();
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _moleculeController.dispose();
    _pulseController.dispose();

    nameController.dispose();
    schoolController.dispose();

    super.dispose();
  }

  // ============================================================
  // PDF
  // ============================================================

  Future<void> printResults() async {
    final userName = nameController.text.trim().isEmpty
        ? 'Not provided'
        : nameController.text.trim();

    final schoolName = schoolController.text.trim().isEmpty
        ? 'Not provided'
        : schoolController.text.trim();

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) {
          return [
            pw.Text(
              'EV-LAB',
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              'Virtual Enzyme Laboratory',
              style: const pw.TextStyle(fontSize: 15),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Laboratory Experiment Results',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 15),
            pw.Text('Student/Researcher: $userName'),
            pw.Text('School: $schoolName'),
            pw.Text('Enzyme: ${widget.enzymeName}'),
            pw.SizedBox(height: 20),

            pw.Text(
              'Experiment Summary',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),

            pw.Text(
              'Average Activity: '
                  '${averageActivity.toStringAsFixed(2)}%',
            ),
            pw.Text(
              'Highest Activity: '
                  '${highestActivity.toStringAsFixed(2)}%',
            ),
            pw.Text(
              'Lowest Activity: '
                  '${lowestActivity.toStringAsFixed(2)}%',
            ),
            pw.Text(
              'Number of Trials: ${widget.trials.length}',
            ),

            pw.SizedBox(height: 20),

            pw.Text(
              'Experimental Data',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),

            pw.TableHelper.fromTextArray(
              headers: [
                'Trial',
                'Temperature',
                'pH',
                'Substrate',
                'Inhibitor',
                'Activity',
              ],
              data: List.generate(
                widget.trials.length,
                    (index) {
                  final trial = widget.trials[index];

                  return [
                    '${index + 1}',
                    '${trial.temperature.toStringAsFixed(1)} °C',
                    trial.ph.toStringAsFixed(2),
                    trial.substrate.toStringAsFixed(2),
                    trial.inhibitor ? 'Present' : 'Absent',
                    '${trial.activity.toStringAsFixed(2)}%',
                  ];
                },
              ),
            ),

            pw.SizedBox(height: 25),

            pw.Text(
              'Best Experimental Condition',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            if (bestTrial != null) ...[
              pw.SizedBox(height: 8),
              pw.Text(
                'Temperature: '
                    '${bestTrial!.temperature.toStringAsFixed(1)} °C',
              ),
              pw.Text(
                'pH: ${bestTrial!.ph.toStringAsFixed(2)}',
              ),
              pw.Text(
                'Substrate: '
                    '${bestTrial!.substrate.toStringAsFixed(2)}',
              ),
              pw.Text(
                'Inhibitor: '
                    '${bestTrial!.inhibitor ? "Present" : "Absent"}',
              ),
              pw.Text(
                'Activity: '
                    '${bestTrial!.activity.toStringAsFixed(2)}%',
              ),
            ],

            pw.SizedBox(height: 25),

            pw.Text(
              'Interpretation',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 8),

            pw.Text(_interpretationText()),

            pw.SizedBox(height: 20),

            pw.Text(
              'Scientific Note',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 8),

            pw.Text(
              'The activity values shown in this report represent '
                  'calculated relative enzyme activity generated by '
                  'the EV-LAB virtual simulation. They are not direct '
                  'measurements from a physical laboratory experiment.',
            ),

            pw.SizedBox(height: 30),

            pw.Text(
              'Generated by EV-LAB',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  Widget _detailedResultSummary() {
    final best = bestTrial;
    if (best == null) return const SizedBox.shrink();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: EVLabGradients.purple,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.biotech_rounded, color: Colors.white),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Detailed Result', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                      Text('Why your best trial produced this activity', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _detailRow('Temperature', '${best.temperature.toStringAsFixed(1)} °C'),
            _detailRow('pH', best.ph.toStringAsFixed(2)),
            _detailRow('Substrate', '$best.substrate.toStringAsFixed(2)'),
            _detailRow('Inhibitor', best.inhibitor ? best.inhibitorType.name : 'None'),
            _detailRow('Activity', '${best.activity.toStringAsFixed(1)}%'),
            const SizedBox(height: 10),
            Text(
              _interpretationText(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
          Text(value, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  // ============================================================
  // INTERPRETATION
  // ============================================================

  String _interpretationText() {
    if (averageActivity >= 75) {
      return 'The trials produced relatively high enzyme activity '
          'under the tested conditions. The experimental conditions '
          'were generally favorable for enzyme activity.';
    }

    if (averageActivity >= 40) {
      return 'The trials produced moderate relative enzyme activity '
          'under the tested conditions. Some conditions may have '
          'been closer to the enzyme optimum than others.';
    }

    return 'The trials produced relatively low enzyme activity '
        'under the tested conditions. Temperature, pH, substrate '
        'concentration, or inhibitor conditions may have reduced '
        'the calculated enzyme activity.';
  }

  String _activityLevel() {
    if (averageActivity >= 75) return 'HIGH ACTIVITY';
    if (averageActivity >= 40) return 'MODERATE ACTIVITY';
    return 'LOW ACTIVITY';
  }

  Color _activityColor() {
    if (averageActivity >= 75) {
      return primaryGreen;
    }

    if (averageActivity >= 40) {
      return Colors.orange;
    }

    return Colors.redAccent;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
        title: const Text(
          'Experiment Results',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (widget.trials.isNotEmpty)
            IconButton(
              tooltip: 'Print / Save Results',
              onPressed: printResults,
              icon: const Icon(
                Icons.picture_as_pdf_outlined,
              ),
            ),
        ],
      ),
      body: widget.trials.isEmpty
          ? _emptyResults()
          : FadeTransition(
        opacity: CurvedAnimation(
          parent: _entranceController,
          curve: Curves.easeOut,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            40,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              _heroHeader(),

              const SizedBox(height: 18),

              _userInformation(),

              const SizedBox(height: 22),

              _experimentIdentity(),

              const SizedBox(height: 22),

              _summaryCards(),

              const SizedBox(height: 25),

              _sectionTitle(
                'Activity Analysis',
                'Observe how enzyme activity changed across your trials.',
                Icons.analytics_outlined,
              ),

              const SizedBox(height: 12),

              _activityGraph(),

              const SizedBox(height: 14),

              _expandableResultSection(
                title: '3D Trial Activity',
                subtitle: 'Optional visual overview of activity across your trials.',
                icon: Icons.view_in_ar_outlined,
                child: ThreeDTrialGraph(
                  values: widget.trials.map((t) => t.activity).toList(),
                  title: 'Trial Activity Overview',
                ),
              ),

              if (widget.enzyme != null) ...[
                const SizedBox(height: 10),
                _expandableResultSection(
                  title: 'Scientific Kinetics',
                  subtitle: 'Explore model curves for substrate, temperature, pH, and inhibition.',
                  icon: Icons.show_chart_outlined,
                  child: ScientificKineticsGraphs(
                    enzyme: widget.enzyme!,
                    inhibitorType: widget.lastInhibitorType ?? InhibitionType.none,
                    inhibitorRatio: widget.lastInhibitorRatio,
                  ),
                ),
                const SizedBox(height: 10),
                _expandableResultSection(
                  title: 'Reaction Mechanism',
                  subtitle: 'See the simplified catalytic sequence used by the simulation.',
                  icon: Icons.biotech_outlined,
                  child: EnzymeMechanismIllustration(
                    enzymeName: widget.enzyme!.name,
                    substrateName: widget.enzyme!.substrate,
                    productName: widget.enzyme!.products,
                    inhibitorActive: (widget.lastInhibitorType ?? InhibitionType.none) != InhibitionType.none,
                  ),
                ),
              ],

              const SizedBox(height: 25),

              _detailedResultSummary(),

              const SizedBox(height: 25),

              _sectionTitle(
                'Molecular Activity',
                'A simplified visual representation of enzyme-substrate interaction.',
                Icons.biotech_outlined,
              ),

              const SizedBox(height: 12),

              _molecularVisualization(),

              const SizedBox(height: 25),

              _sectionTitle(
                'What Happened?',
                'Scientific interpretation of the experimental conditions.',
                Icons.psychology_outlined,
              ),

              const SizedBox(height: 12),

              _scientificExplanation(),

              const SizedBox(height: 25),

              _sectionTitle(
                'Best Experimental Condition',
                'The trial that produced the highest calculated activity.',
                Icons.emoji_events_outlined,
              ),

              const SizedBox(height: 12),

              _bestConditions(),

              const SizedBox(height: 25),

              _sectionTitle(
                'Trial-by-Trial Analysis',
                'Inspect each experimental run and its calculated activity.',
                Icons.science_outlined,
              ),

              const SizedBox(height: 12),

              _trialCards(),

              const SizedBox(height: 25),

              _sectionTitle(
                'Experimental Data',
                'Complete numerical record of your experiment.',
                Icons.table_chart_outlined,
              ),

              const SizedBox(height: 12),

              _resultsTable(),

              const SizedBox(height: 25),

              _interpretation(),

              const SizedBox(height: 25),

              _actionButtons(),

              const SizedBox(height: 16),

              _scientificDisclaimer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _expandableResultSection({required String title, required String subtitle, required IconData icon, required Widget child}) {
    return _LazyResultSection(
      title: title,
      subtitle: subtitle,
      icon: icon,
      child: child,
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _heroHeader() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale =
            1 + (_pulseController.value * 0.015);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  deeperGreen,
                  darkGreen,
                  primaryGreen,
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color:
                  primaryGreen.withValues(alpha: 0.20),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.14,
                  ),
                  borderRadius:
                  BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.science_outlined,
                  color: Colors.white,
                  size: 31,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius:
                  BorderRadius.circular(30),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 15,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'COMPLETE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Text(
            'Experiment Complete',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            '${widget.trials.length} experimental '
                '${widget.trials.length == 1 ? "trial" : "trials"} '
                'have been analyzed.',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Icon(
                Icons.arrow_downward_rounded,
                color: Colors.white.withValues(
                  alpha: 0.75,
                ),
                size: 18,
              ),
              const SizedBox(width: 7),
              const Text(
                'Scroll to explore your findings',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // USER INFORMATION
  // ============================================================

  Widget _userInformation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.person_outline,
                color: primaryGreen,
              ),
              SizedBox(width: 9),
              Text(
                'Researcher Information',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          TextField(
            controller: nameController,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              label: 'Name',
              hint: 'Enter your name',
              icon: Icons.person_outline,
            ),
          ),

          const SizedBox(height: 11),

          TextField(
            controller: schoolController,
            decoration: _inputDecoration(
              label: 'School',
              hint: 'Enter your school',
              icon: Icons.school_outlined,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF7FAF8),
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.withValues(alpha: 0.16),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primaryGreen,
          width: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // EXPERIMENT IDENTITY
  // ============================================================

  Widget _experimentIdentity() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            paleGreen,
          ],
        ),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: primaryGreen.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.biotech_outlined,
              color: primaryGreen,
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'ACTIVE ENZYME',
                  style: TextStyle(
                    color: primaryGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.enzymeName,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Virtual enzyme activity simulation',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
      String title,
      String subtitle,
      IconData icon,
      ) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: lightGreen,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: primaryGreen,
            size: 22,
          ),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY CARDS
  // ============================================================

  Widget _summaryCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _animatedStatCard(
                title: 'Average Activity',
                value:
                '${averageActivity.toStringAsFixed(1)}%',
                icon: Icons.speed_outlined,
                accent: _activityColor(),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: _animatedStatCard(
                title: 'Peak Activity',
                value:
                '${highestActivity.toStringAsFixed(1)}%',
                icon: Icons.trending_up,
                accent: Colors.blue,
              ),
            ),
          ],
        ),

        const SizedBox(height: 11),

        Row(
          children: [
            Expanded(
              child: _animatedStatCard(
                title: 'Total Trials',
                value:
                '${widget.trials.length}',
                icon: Icons.science_outlined,
                accent: Colors.orange,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: _animatedStatCard(
                title: 'Best Trial',
                value:
                bestTrialIndex == -1
                    ? '-'
                    : '#${bestTrialIndex + 1}',
                icon: Icons.emoji_events_outlined,
                accent: Colors.purple,
              ),
            ),
          ],
        ),

        const SizedBox(height: 11),

        _activityStatusCard(),
      ],
    );
  }

  Widget _animatedStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accent,
  }) {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        final animationValue =
        Curves.easeOut.transform(
          _entranceController.value,
        );

        return Transform.translate(
          offset: Offset(
            0,
            20 * (1 - animationValue),
          ),
          child: Opacity(
            opacity: animationValue,
            child: child,
          ),
        );
      },
      child: Container(
        constraints:
        const BoxConstraints(minHeight: 128),
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                accent.withValues(alpha: 0.10),
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: accent,
                size: 21,
              ),
            ),

            const Spacer(),

            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 3),

            Text(
              value,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activityStatusCard() {
    final color = _activityColor();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              averageActivity >= 75
                  ? Icons.bolt_rounded
                  : averageActivity >= 40
                  ? Icons.speed_rounded
                  : Icons.warning_amber_rounded,
              color: color,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  _activityLevel(),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _activityStatusDescription(),
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _activityStatusDescription() {
    if (averageActivity >= 75) {
      return 'Your tested conditions generally supported strong enzyme activity.';
    }

    if (averageActivity >= 40) {
      return 'Your tested conditions produced moderate enzyme activity.';
    }

    return 'The tested conditions generally resulted in lower enzyme activity.';
  }

  // ============================================================
  // GRAPH
  // ============================================================

  Widget _activityGraph() {
    final spots = List.generate(
      widget.trials.length,
          (index) => FlSpot(
        (index + 1).toDouble(),
        widget.trials[index]
            .activity
            .clamp(0.0, 100.0),
      ),
    );

    return Container(
      width: double.infinity,
      height: 380,
      padding: const EdgeInsets.fromLTRB(
        8,
        18,
        18,
        15,
      ),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'Relative Enzyme Activity',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

          const SizedBox(height: 4),

          Padding(
            padding:
            const EdgeInsets.only(left: 10),
            child: Text(
              'Activity response across experimental trials',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ),

          const SizedBox(height: 15),

          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                minX: 1,
                maxX: widget.trials.length < 2
                    ? 2
                    : widget.trials.length
                    .toDouble(),

                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 20,
                  verticalInterval: 1,
                  getDrawingHorizontalLine:
                      (value) {
                    return FlLine(
                      color: Colors.grey
                          .withValues(alpha: 0.14),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine:
                      (value) {
                    return FlLine(
                      color: Colors.grey
                          .withValues(alpha: 0.08),
                      strokeWidth: 1,
                    );
                  },
                ),

                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.grey
                        .withValues(alpha: 0.22),
                  ),
                ),

                titlesData: FlTitlesData(
                  topTitles:
                  const AxisTitles(
                    sideTitles:
                    SideTitles(
                      showTitles: false,
                    ),
                  ),
                  rightTitles:
                  const AxisTitles(
                    sideTitles:
                    SideTitles(
                      showTitles: false,
                    ),
                  ),

                  leftTitles: AxisTitles(
                    axisNameWidget:
                    const Text(
                      'Activity (%)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                    sideTitles:
                    SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      interval: 20,
                      getTitlesWidget:
                          (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style:
                          const TextStyle(
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),

                  bottomTitles:
                  AxisTitles(
                    axisNameWidget:
                    const Text(
                      'Trial Number',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                    sideTitles:
                    SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget:
                          (value, meta) {
                        return Text(
                          value.toInt()
                              .toString(),
                          style:
                          const TextStyle(
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                lineTouchData:
                LineTouchData(
                  enabled: true,
                  touchTooltipData:
                  LineTouchTooltipData(
                    getTooltipItems:
                        (spots) {
                      return spots.map(
                            (spot) {
                          return LineTooltipItem(
                            'Trial ${spot.x.toInt()}\n'
                                '${spot.y.toStringAsFixed(1)}%',
                            const TextStyle(
                              color:
                              Colors.white,
                              fontWeight:
                              FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        },
                      ).toList();
                    },
                  ),
                ),

                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.18,
                    color: primaryGreen,
                    barWidth: 3.5,
                    isStrokeCapRound: true,

                    dotData: FlDotData(
                      show: true,
                      getDotPainter:
                          (
                          spot,
                          percent,
                          barData,
                          index,
                          ) {
                        final isBest =
                            index ==
                                bestTrialIndex;

                        return FlDotCirclePainter(
                          radius:
                          isBest ? 7 : 5,
                          color:
                          isBest
                              ? Colors.orange
                              : primaryGreen,
                          strokeWidth: 2,
                          strokeColor:
                          Colors.white,
                        );
                      },
                    ),

                    belowBarData:
                    BarAreaData(
                      show: true,
                      color: primaryGreen
                          .withValues(alpha: 0.07),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOLECULAR VISUALIZATION
  // ============================================================

  Widget _molecularVisualization() {
    return Container(
      width: double.infinity,
      height: 310,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF09250D),
            Color(0xFF123F1A),
            Color(0xFF0A2810),
          ],
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _moleculeController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _MoleculePainter(
                    progress:
                    _moleculeController.value,
                    activity:
                    averageActivity,
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withValues(alpha: 0.10),
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'MOLECULAR VIEW',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight:
                          FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 9),

                const Text(
                  'Enzyme–Substrate Interaction',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'Simplified visualization of molecular interaction during the simulated reaction.',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),

                const Spacer(),

                Row(
                  children: [
                    _moleculeLegend(
                      Colors.greenAccent,
                      'Enzyme',
                    ),
                    const SizedBox(width: 15),
                    _moleculeLegend(
                      Colors.orangeAccent,
                      'Substrate',
                    ),
                    const SizedBox(width: 15),
                    _moleculeLegend(
                      Colors.lightBlueAccent,
                      'Product',
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

  Widget _moleculeLegend(
      Color color,
      String label,
      ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SCIENTIFIC EXPLANATION
  // ============================================================

  Widget _scientificExplanation() {
    final trial = bestTrial;

    if (trial == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        _explanationCard(
          icon: Icons.thermostat_outlined,
          title: 'Temperature',
          color: Colors.deepOrange,
          explanation:
          'Temperature affects molecular motion and enzyme structure. '
              'A suitable temperature can increase effective enzyme–substrate '
              'collisions, while excessive heat can reduce activity by '
              'disrupting the enzyme structure.',
          value:
          '${trial.temperature.toStringAsFixed(1)} °C',
        ),

        const SizedBox(height: 10),

        _explanationCard(
          icon: Icons.water_drop_outlined,
          title: 'pH',
          color: Colors.blue,
          explanation:
          'pH can affect the electrical charges and structure of an enzyme. '
              'When pH moves away from a suitable range, interactions at the '
              'active site may become less favorable and activity can decrease.',
          value:
          'pH ${trial.ph.toStringAsFixed(2)}',
        ),

        const SizedBox(height: 10),

        _explanationCard(
          icon: Icons.grain,
          title: 'Substrate Concentration',
          color: Colors.orange,
          explanation:
          'Increasing substrate concentration can increase reaction rate '
              'when many active sites are still available. As active sites '
              'become increasingly occupied, the rate approaches a maximum.',
          value:
          trial.substrate.toStringAsFixed(2),
        ),

        const SizedBox(height: 10),

        _explanationCard(
          icon: Icons.block,
          title: 'Inhibitor',
          color: Colors.purple,
          explanation:
          trial.inhibitor
              ? 'An inhibitor was present in this trial. Inhibition can '
              'reduce effective enzyme activity by interfering with '
              'enzyme–substrate interactions or enzyme function.'
              : 'No inhibitor was present in this trial, so the simulation '
              'did not apply an inhibitor-related reduction to this condition.',
          value:
          trial.inhibitor
              ? 'Present'
              : 'Absent',
        ),
      ],
    );
  }

  Widget _explanationCard({
    required IconData icon,
    required String title,
    required Color color,
    required String explanation,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius:
              BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(width: 12),

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
                          FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Container(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color
                            .withValues(alpha: 0.08),
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: Text(
                        value,
                        style: TextStyle(
                          color: color,
                          fontWeight:
                          FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                Text(
                  explanation,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BEST CONDITIONS
  // ============================================================

  Widget _bestConditions() {
    final trial = bestTrial;

    if (trial == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8F5E9),
            Color(0xFFF9FCF9),
          ],
        ),
        borderRadius:
        BorderRadius.circular(22),
        border: Border.all(
          color:
          primaryGreen.withValues(alpha: 0.13),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withValues(alpha: 0.04),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Colors.orange,
                  size: 19,
                ),
                SizedBox(width: 7),
                Text(
                  'HIGHEST ACTIVITY TRIAL',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.7,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color:
                primaryGreen.withValues(
                  alpha: 0.15,
                ),
                width: 4,
              ),
            ),
            child: Center(
              child: Text(
                '${trial.activity.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: primaryGreen,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          _conditionRow(
            Icons.thermostat_outlined,
            'Temperature',
            '${trial.temperature.toStringAsFixed(1)} °C',
          ),

          _conditionRow(
            Icons.water_drop_outlined,
            'pH',
            trial.ph.toStringAsFixed(2),
          ),

          _conditionRow(
            Icons.grain,
            'Substrate',
            trial.substrate.toStringAsFixed(2),
          ),

          _conditionRow(
            Icons.block,
            'Inhibitor',
            trial.inhibitor
                ? 'Present'
                : 'Absent',
          ),

          const Padding(
            padding:
            EdgeInsets.symmetric(vertical: 8),
            child: Divider(),
          ),

          _conditionRow(
            Icons.analytics_outlined,
            'Activity',
            '${trial.activity.toStringAsFixed(1)}%',
            highlight: true,
          ),
        ],
      ),
    );
  }

  Widget _conditionRow(
      IconData icon,
      String title,
      String value, {
        bool highlight = false,
      }) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(
            icon,
            color: primaryGreen,
            size: 21,
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: highlight
                    ? FontWeight.bold
                    : FontWeight.w600,
              ),
            ),
          ),

          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize:
              highlight ? 18 : 14,
              color: highlight
                  ? primaryGreen
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TRIAL CARDS
  // ============================================================

  Widget _trialCards() {
    return Column(
      children: List.generate(
        widget.trials.length,
            (index) {
          return Padding(
            padding:
            const EdgeInsets.only(bottom: 10),
            child: _trialCard(
              widget.trials[index],
              index,
            ),
          );
        },
      ),
    );
  }

  Widget _trialCard(
      ExperimentTrial trial,
      int index,
      ) {
    final isBest = index == bestTrialIndex;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(19),
        border: Border.all(
          color: isBest
              ? Colors.orange.withValues(
            alpha: 0.30,
          )
              : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 3,
        ),
        childrenPadding:
        const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16,
        ),
        leading: Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: isBest
                ? Colors.orange
                .withValues(alpha: 0.10)
                : lightGreen,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isBest
                    ? Colors.orange
                    : primaryGreen,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            const Text(
              'Trial ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${index + 1}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isBest) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.star,
                color: Colors.orange,
                size: 16,
              ),
              const SizedBox(width: 4),
              const Text(
                'BEST',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          'Activity: ${trial.activity.toStringAsFixed(1)}%',
          style: TextStyle(
            color: isBest
                ? primaryGreen
                : Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          _trialParameterGrid(trial),
        ],
      ),
    );
  }

  Widget _trialParameterGrid(
      ExperimentTrial trial,
      ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _parameterBox(
                'Temperature',
                '${trial.temperature.toStringAsFixed(1)} °C',
                Icons.thermostat_outlined,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _parameterBox(
                'pH',
                trial.ph.toStringAsFixed(2),
                Icons.water_drop_outlined,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _parameterBox(
                'Substrate',
                trial.substrate.toStringAsFixed(2),
                Icons.grain,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _parameterBox(
                'Inhibitor',
                trial.inhibitor
                    ? 'Present'
                    : 'Absent',
                Icons.block,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _parameterBox(
      String label,
      String value,
      IconData icon,
      ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF8),
        borderRadius:
        BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: primaryGreen,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RESULTS TABLE
  // ============================================================

  Widget _resultsTable() {
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      child: ClipRRect(
        borderRadius:
        BorderRadius.circular(19),
        child: SingleChildScrollView(
          scrollDirection:
          Axis.horizontal,
          child: DataTable(
            headingRowColor:
            const WidgetStatePropertyAll(
              lightGreen,
            ),
            columnSpacing: 25,
            horizontalMargin: 18,
            columns: const [
              DataColumn(
                label: Text('Trial'),
              ),
              DataColumn(
                label: Text('Temp.'),
              ),
              DataColumn(
                label: Text('pH'),
              ),
              DataColumn(
                label: Text('Substrate'),
              ),
              DataColumn(
                label: Text('Inhibitor'),
              ),
              DataColumn(
                label: Text('Activity'),
              ),
            ],
            rows: List.generate(
              widget.trials.length,
                  (index) {
                final trial =
                widget.trials[index];

                final isBest =
                    index == bestTrialIndex;

                return DataRow(
                  color:
                  WidgetStateProperty.resolveWith(
                        (states) {
                      if (isBest) {
                        return lightGreen
                            .withValues(
                          alpha: 0.55,
                        );
                      }

                      return null;
                    },
                  ),
                  cells: [
                    DataCell(
                      Row(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: [
                          Text(
                            '${index + 1}',
                            style:
                            const TextStyle(
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                          if (isBest) ...[
                            const SizedBox(
                              width: 6,
                            ),
                            const Icon(
                              Icons.star,
                              size: 15,
                              color:
                              Colors.orange,
                            ),
                          ],
                        ],
                      ),
                    ),
                    DataCell(
                      Text(
                        '${trial.temperature.toStringAsFixed(1)} °C',
                      ),
                    ),
                    DataCell(
                      Text(
                        trial.ph
                            .toStringAsFixed(2),
                      ),
                    ),
                    DataCell(
                      Text(
                        trial.substrate
                            .toStringAsFixed(2),
                      ),
                    ),
                    DataCell(
                      Text(
                        trial.inhibitor
                            ? 'Present'
                            : 'Absent',
                      ),
                    ),
                    DataCell(
                      Text(
                        '${trial.activity.toStringAsFixed(1)}%',
                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.bold,
                          color:
                          primaryGreen,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INTERPRETATION
  // ============================================================

  Widget _interpretation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(21),
        border: Border.all(
          color:
          primaryGreen.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: primaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Overall Interpretation',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF7),
              borderRadius:
              BorderRadius.circular(15),
            ),
            child: Text(
              _interpretationText(),
              style: const TextStyle(
                height: 1.55,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _miniInsight(
                  title: 'Activity Range',
                  value:
                  '${activityRange.toStringAsFixed(1)}%',
                  icon: Icons.swap_vert,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _miniInsight(
                  title: 'Consistency',
                  value:
                  '${consistencyScore.toStringAsFixed(0)}%',
                  icon: Icons.sync,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniInsight({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey
              .withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: primaryGreen,
            size: 19,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION BUTTONS
  // ============================================================

  Widget _actionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: printResults,
            icon: const Icon(
              Icons.picture_as_pdf_outlined,
            ),
            label: const Text(
              'PRINT / SAVE RESULTS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
            style:
            ElevatedButton.styleFrom(
              backgroundColor:
              primaryGreen,
              foregroundColor:
              Colors.white,
              elevation: 0,
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(16),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.science_outlined,
            ),
            label: const Text(
              'BACK TO LABORATORY',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            style:
            OutlinedButton.styleFrom(
              foregroundColor:
              primaryGreen,
              side: const BorderSide(
                color: primaryGreen,
              ),
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DISCLAIMER
  // ============================================================

  Widget _scientificDisclaimer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey
            .withValues(alpha: 0.07),
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'EV-LAB activity values are calculated '
                  'relative activity values generated by '
                  'the virtual simulation. They are not direct '
                  'measurements from a physical laboratory experiment.',
              style: TextStyle(
                fontSize: 11,
                height: 1.45,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY RESULTS
  // ============================================================

  Widget _emptyResults() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 105,
              height: 105,
              decoration:
              const BoxDecoration(
                color: lightGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.analytics_outlined,
                size: 52,
                color: primaryGreen,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'No Results Yet',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Run an experiment in the Virtual Laboratory '
                  'first to generate results.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.science_outlined,
              ),
              label: const Text(
                'BACK TO LABORATORY',
              ),
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                primaryGreen,
                foregroundColor:
                Colors.white,
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CARD DECORATION
  // ============================================================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius:
      BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color:
          Colors.black.withValues(
            alpha: 0.035,
          ),
          blurRadius: 13,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}


/// Lightweight, web-safe detailed results view used directly from the lab.
/// It intentionally avoids the heavier optional visualizations so the research
/// result page remains responsive and does not depend on WebGL/interactive
/// widgets.
class DetailedExperimentResultScreen extends StatelessWidget {
  final List<ExperimentTrial> trials;
  final String enzymeName;

  const DetailedExperimentResultScreen({
    super.key,
    required this.trials,
    required this.enzymeName,
  });

  ExperimentTrial? get bestTrial {
    if (trials.isEmpty) return null;
    return trials.reduce((a, b) => a.activity >= b.activity ? a : b);
  }

  double get average => trials.isEmpty
      ? 0
      : trials.map((e) => e.activity).reduce((a, b) => a + b) / trials.length;

  @override
  Widget build(BuildContext context) {
    final best = bestTrial;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detailed Experiment Results'),
        backgroundColor: const Color(0xFF0A6B78),
        foregroundColor: Colors.white,
      ),
      body: trials.isEmpty
          ? const Center(child: Text('Run at least one experiment to generate detailed results.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _summaryHeader(enzymeName, best!),
                const SizedBox(height: 14),
                _trendCard(),
                const SizedBox(height: 14),
                _molecularStageCard(enzymeName, best),
                const SizedBox(height: 14),
                _interpretationCard(best),
                const SizedBox(height: 14),
                _trialTable(),
              ],
            ),
    );
  }


  Widget _summaryHeader(String name, ExperimentTrial best) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF087F8C), Color(0xFF12B8A6), Color(0xFF4C8DFF)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('EXPERIMENT COMPLETE', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 6),
          const Text('Your evidence at a glance', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('${trials.length} trial${trials.length == 1 ? '' : 's'} recorded • average activity ${average.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _metric('BEST', '${best.activity.toStringAsFixed(1)}%'),
              _metric('TEMP', '${best.temperature.toStringAsFixed(1)}°C'),
              _metric('pH', best.ph.toStringAsFixed(1)),
              _metric('SUBSTRATE', best.substrate.toStringAsFixed(2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .13), borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 8, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ]),
    );
  }

  Widget _trendCard() {
    final spots = List.generate(trials.length, (i) => FlSpot((i + 1).toDouble(), trials[i].activity.clamp(0, 100)));
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Activity trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('The line connects your trials so you can see how the calculated activity changed.', style: TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 14),
          SizedBox(
            height: 260,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                minX: 1,
                maxX: trials.length < 2 ? 2 : trials.length.toDouble(),
                gridData: const FlGridData(show: true),
                borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12)),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 34, interval: 20)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1, reservedSize: 28, getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 9)))),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xFF12B8A6),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: const Color(0xFF12B8A6).withValues(alpha: .08)),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _molecularStageCard(String enzymeName, ExperimentTrial best) {
    return Card(
      color: const Color(0xFF092A38),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Reaction story', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text('$enzymeName • a simplified model of what the experiment represents', style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 10),
          SizedBox(height: 230, child: CustomPaint(painter: _DetailedReactionPainter(activity: best.activity, inhibitor: best.inhibitor))),
          const SizedBox(height: 8),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StageChip('1', 'SUBSTRATE APPROACHES', Color(0xFFFFC857)),
              _StageChip('2', 'ACTIVE SITE BINDS', Color(0xFF7CE7D5)),
              _StageChip('3', 'CATALYSIS', Color(0xFF7AB8FF)),
              _StageChip('4', 'PRODUCT RELEASE', Color(0xFFFF8FB3)),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _interpretationCard(ExperimentTrial best) {
    final tempText = best.temperature > 50 ? 'The temperature is high enough to introduce thermal stress in the model.' : 'The temperature is within a moderate range for the selected trial.';
    final phText = best.ph < 6 || best.ph > 9 ? 'The pH is far from neutral, which can alter charge interactions around an active site.' : 'The pH is in a comparatively moderate range.';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('What happened?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          _explain('Temperature', tempText),
          _explain('pH', phText),
          _explain('Substrate', 'Higher substrate can increase collisions with available active sites until the modeled enzyme becomes increasingly occupied.'),
          _explain('Inhibition', best.inhibitor ? 'An inhibitor was present, so the simulation reduced effective activity according to the selected inhibition model.' : 'No inhibitor was present in this trial.'),
        ]),
      ),
    );
  }

  Widget _explain(String title, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 6), decoration: const BoxDecoration(color: Color(0xFF12B8A6), shape: BoxShape.circle)),
          const SizedBox(width: 9),
          Expanded(child: RichText(text: TextSpan(style: const TextStyle(color: Color(0xFF596579), fontSize: 12, height: 1.45), children: [TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF172033))), TextSpan(text: text)]))),
        ]),
      );

  Widget _trialTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Recorded trials', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          ...List.generate(trials.length, (i) {
            final t = trials[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF4F8FA), borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                CircleAvatar(radius: 16, backgroundColor: const Color(0xFF12B8A6), child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900))),
                const SizedBox(width: 10),
                Expanded(child: Text('${t.temperature.toStringAsFixed(1)}°C • pH ${t.ph.toStringAsFixed(1)} • [S] ${t.substrate.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                Text('${t.activity.toStringAsFixed(1)}%', style: const TextStyle(color: Color(0xFF078A7C), fontWeight: FontWeight.w900)),
              ]),
            );
          }),
        ]),
      ),
    );
  }
}

class _StageChip extends StatelessWidget {
  final String number;
  final String label;
  final Color color;
  const _StageChip(this.number, this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: .35))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          CircleAvatar(radius: 9, backgroundColor: color, child: Text(number, style: const TextStyle(fontSize: 9, color: Colors.black87, fontWeight: FontWeight.w900))),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900)),
        ]),
      );
}

class _DetailedReactionPainter extends CustomPainter {
  final double activity;
  final bool inhibitor;
  _DetailedReactionPainter({required this.activity, required this.inhibitor});

  @override
  void paint(Canvas c, Size s) {
    final center = Offset(s.width * .5, s.height * .53);
    final body = Paint()..color = const Color(0xFF16A085);
    final pocket = Paint()..color = const Color(0xFF082F36);
    c.drawCircle(center, s.height * .25, body);
    c.drawOval(Rect.fromCenter(center: center + Offset(18, -2), width: s.width * .20, height: s.height * .13), pocket);

    final glow = Paint()..color = const Color(0xFF7CE7D5).withValues(alpha: .18 + activity.clamp(0, 100) / 500);
    c.drawCircle(center + Offset(18, -2), s.height * .17, glow);

    for (int i = 0; i < 10; i++) {
      final a = i * .63;
      final x = center.dx + math.cos(a) * s.width * .34;
      final y = center.dy + math.sin(a) * s.height * .30;
      c.drawCircle(Offset(x, y), 4, Paint()..color = const Color(0xFFFFC857));
    }

    // One substrate is shown approaching the active site, while product
    // particles leave the opposite side. This is intentionally conceptual.
    final substrate = Offset(center.dx - s.width * .28, center.dy - s.height * .12);
    c.drawCircle(substrate, 8, Paint()..color = const Color(0xFFFFC857));
    c.drawLine(substrate + const Offset(10, 0), center + Offset(-s.width * .11, -8), Paint()..color = Colors.white38..strokeWidth = 2);

    for (int i = 0; i < 3; i++) {
      final p = Offset(center.dx + s.width * (.24 + i * .08), center.dy - s.height * (.08 + i * .10));
      c.drawCircle(p, 6, Paint()..color = const Color(0xFF7AB8FF));
    }

    if (inhibitor) {
      final x = center.dx + s.width * .14;
      final y = center.dy + s.height * .20;
      final p = Paint()..color = const Color(0xFFFF5A87)..strokeWidth = 4;
      c.drawLine(Offset(x - 8, y - 8), Offset(x + 8, y + 8), p);
      c.drawLine(Offset(x + 8, y - 8), Offset(x - 8, y + 8), p);
    }

    final tp = TextPainter(text: TextSpan(text: inhibitor ? 'ACTIVE SITE • INHIBITOR PRESENT' : 'ACTIVE SITE • CATALYSIS', style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: .5)), textDirection: TextDirection.ltr)..layout(maxWidth: s.width);
    tp.paint(c, Offset((s.width - tp.width) / 2, 8));
  }

  @override
  bool shouldRepaint(covariant _DetailedReactionPainter oldDelegate) => oldDelegate.activity != activity || oldDelegate.inhibitor != inhibitor;
}

class _LazyResultSection extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _LazyResultSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  State<_LazyResultSection> createState() => _LazyResultSectionState();
}

class _LazyResultSectionState extends State<_LazyResultSection> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (value) => setState(() => expanded = value),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: EVLabGradients.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(widget.icon, color: Colors.white, size: 20),
          ),
          title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w900)),
          subtitle: Text(widget.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
          children: expanded ? [widget.child] : const <Widget>[],
        ),
      ),
    );
  }
}

// ================================================================
// MOLECULAR ANIMATION PAINTER
// ================================================================

class _MoleculePainter extends CustomPainter {
  final double progress;
  final double activity;

  _MoleculePainter({
    required this.progress,
    required this.activity,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final center =
    Offset(size.width / 2, size.height / 2 + 25);

    final radius =
        math.min(size.width, size.height) * 0.25;

    final paint = Paint()
      ..style = PaintingStyle.fill;

    // ----------------------------------------------------------
    // Background particles
    // ----------------------------------------------------------

    for (int i = 0; i < 35; i++) {
      final angle =
          (i * 1.7) + progress * math.pi * 2;

      final distance =
          radius * (1.4 + (i % 5) * 0.22);

      final x =
          center.dx +
              math.cos(angle) * distance;

      final y =
          center.dy +
              math.sin(angle) * distance;

      paint.color = Colors.white
          .withValues(alpha: 0.07);

      canvas.drawCircle(
        Offset(x, y),
        1.5 + (i % 3),
        paint,
      );
    }

    // ----------------------------------------------------------
    // Enzyme body
    // ----------------------------------------------------------

    paint.color = Colors.greenAccent
        .withValues(alpha: 0.15);

    canvas.drawCircle(
      center,
      radius * 0.92,
      paint,
    );

    paint.color = Colors.greenAccent
        .withValues(alpha: 0.08);

    canvas.drawCircle(
      center,
      radius * 1.12,
      paint,
    );

    // ----------------------------------------------------------
    // Enzyme active site
    // ----------------------------------------------------------

    final activeSite =
    Offset(
      center.dx + radius * 0.56,
      center.dy - radius * 0.05,
    );

    paint.color = Colors.black
        .withValues(alpha: 0.35);

    canvas.drawCircle(
      activeSite,
      radius * 0.24,
      paint,
    );

    paint.color = Colors.greenAccent;

    canvas.drawCircle(
      center,
      radius * 0.76,
      paint,
    );

    paint.color = const Color(0xFF08300D);

    canvas.drawCircle(
      activeSite,
      radius * 0.19,
      paint,
    );

    // ----------------------------------------------------------
    // Orbiting substrates
    // ----------------------------------------------------------

    for (int i = 0; i < 3; i++) {
      final orbitProgress =
          progress * math.pi * 2 +
              i * (math.pi * 2 / 3);

      final orbitRadius =
          radius * 1.55;

      final position = Offset(
        center.dx +
            math.cos(orbitProgress) *
                orbitRadius,
        center.dy +
            math.sin(orbitProgress) *
                orbitRadius *
                0.65,
      );

      paint.color = Colors.orangeAccent;

      canvas.drawCircle(
        position,
        8,
        paint,
      );

      paint.color = Colors.white
          .withValues(alpha: 0.30);

      canvas.drawCircle(
        position,
        11,
        paint..style = PaintingStyle.stroke,
      );

      paint.style = PaintingStyle.fill;
    }

    // ----------------------------------------------------------
    // Product particles
    // ----------------------------------------------------------

    final productCount =
    activity > 70 ? 6 : activity > 40 ? 4 : 2;

    for (int i = 0;
    i < productCount;
    i++) {
      final angle =
          progress * math.pi * 2 +
              i * 1.1;

      final distance =
          radius * (1.4 + i * 0.20);

      final position = Offset(
        center.dx +
            math.cos(angle) * distance,
        center.dy +
            math.sin(angle) * distance,
      );

      paint.color =
          Colors.lightBlueAccent;

      canvas.drawCircle(
        position,
        4.5,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
      covariant _MoleculePainter oldDelegate,
      ) {
    return oldDelegate.progress != progress ||
        oldDelegate.activity != activity;
  }
}