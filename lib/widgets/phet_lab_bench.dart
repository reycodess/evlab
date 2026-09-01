import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

/// A single compact laboratory workstation.
///
/// The bench intentionally keeps the experiment in one place: the physical
/// instruments, reaction vessel, live controls, and optional molecular view
/// all belong to the same workstation instead of appearing as separate lab
/// sections elsewhere on the page.
class PhetLabBench extends StatefulWidget {
  final String enzymeName;
  final String? model3D;
  final String? modelDescription;
  final double temperature;
  final double ph;
  final double activity;
  final double substrate;
  final double substrateMin;
  final double substrateMax;
  final double optimumTemperature;
  final double optimumPh;
  final ValueChanged<double> onTemperatureChanged;
  final ValueChanged<double> onPhChanged;
  final ValueChanged<double> onSubstrateChanged;
  final VoidCallback onAddSubstrate;
  final VoidCallback onStir;
  final VoidCallback onAddInhibitor;
  final bool inhibitorActive;

  const PhetLabBench({
    super.key,
    required this.enzymeName,
    this.model3D,
    this.modelDescription,
    required this.temperature,
    required this.ph,
    required this.activity,
    required this.substrate,
    required this.substrateMin,
    required this.substrateMax,
    required this.optimumTemperature,
    required this.optimumPh,
    required this.onTemperatureChanged,
    required this.onPhChanged,
    required this.onSubstrateChanged,
    required this.onAddSubstrate,
    required this.onStir,
    required this.onAddInhibitor,
    required this.inhibitorActive,
  });

  @override
  State<PhetLabBench> createState() => PhetLabBenchState();
}

class PhetLabBenchState extends State<PhetLabBench>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;
  bool stirring = false;
  bool showMolecularView = false;

  void hideMolecularView() {
    if (mounted && showMolecularView) {
      setState(() => showMolecularView = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  void _stir() {
    setState(() => stirring = true);
    widget.onStir();
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => stirring = false);
    });
  }

  Color get _activityColor {
    if (widget.activity >= 75) return const Color(0xFF55EFC4);
    if (widget.activity >= 40) return const Color(0xFFFFD166);
    return const Color(0xFFFF7A90);
  }

  Color get _phColor {
    if (widget.ph < 5) return const Color(0xFFE85D75);
    if (widget.ph < 6.5) return const Color(0xFFF39C5A);
    if (widget.ph <= 7.5) return const Color(0xFF55C878);
    if (widget.ph < 9) return const Color(0xFF36B5D8);
    return const Color(0xFF6575D9);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF084F70),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF6DB8D4), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _header(),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
            child: Column(
              children: [
                _benchSurface(),
                const SizedBox(height: 10),
                _controlDeck(),
                const SizedBox(height: 10),
                _scienceConsole(),
                if (showMolecularView && (widget.model3D?.trim().isNotEmpty ?? false)) ...[
                  const SizedBox(height: 10),
                  _molecularView(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 11),
      color: const Color(0xFF063F5D),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.science, color: Colors.white, size: 19),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.enzymeName.toUpperCase()} LAB BENCH',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Adjust conditions and observe the reaction live',
                  style: TextStyle(color: Colors.white60, fontSize: 9.5),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: _activityColor.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _activityColor.withValues(alpha: .45)),
            ),
            child: Text(
              '${widget.activity.toStringAsFixed(0)}%',
              style: TextStyle(
                color: _activityColor,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _benchSurface() {
    return Container(
      height: 360,
      decoration: BoxDecoration(
        color: const Color(0xFF075B7E),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white24),
      ),
      child: Stack(
        children: [
          // Pegboard-style background.
          Positioned.fill(
            child: CustomPaint(painter: _BenchBackgroundPainter()),
          ),

          // Bench edge.
          Positioned(
            left: 0,
            right: 0,
            bottom: 48,
            child: Container(height: 7, color: const Color(0xFFB7D6E1)),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(height: 48, color: const Color(0xFF739CAC)),
          ),

          Positioned(left: 12, top: 13, child: _tag('REAGENTS')),
          Positioned(
            left: 12,
            top: 45,
            child: Row(
              children: [
                _reagent('S', 'SUBSTRATE', const Color(0xFF704214), widget.onAddSubstrate),
                const SizedBox(width: 7),
                _reagent('BUF', 'BUFFER', const Color(0xFF3E7899), () {}),
                const SizedBox(width: 7),
                _reagent('INH', 'INHIBITOR', const Color(0xFFB93F6C), widget.onAddInhibitor),
              ],
            ),
          ),

          Positioned(right: 12, top: 13, child: _tag('INSTRUMENTS')),
          Positioned(
            right: 12,
            top: 45,
            child: Column(
              children: [
                _thermometer(),
                const SizedBox(height: 8),
                _phMeter(),
              ],
            ),
          ),

          Positioned(
            left: 95,
            right: 95,
            top: 104,
            bottom: 58,
            child: _reactionChamber(),
          ),

          Positioned(
            left: 12,
            bottom: 7,
            child: Row(
              children: [
                _benchTube('P200', const Color(0xFFB5E48C)),
                const SizedBox(width: 5),
                _benchTube('P1000', const Color(0xFF70C8E8)),
                const SizedBox(width: 5),
                _benchTube('STIR', const Color(0xFFD8BA58)),
              ],
            ),
          ),
          Positioned(right: 12, bottom: 7, child: _trash()),
        ],
      ),
    );
  }

  Widget _reactionChamber() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _ReactionPainter(
            phase: _animation.value,
            activity: widget.activity,
            substrate: widget.substrate,
            inhibitor: widget.inhibitorActive,
            stirring: stirring,
            temperature: widget.temperature,
            ph: widget.ph,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }

  Widget _thermometer() {
    final ratio = (widget.temperature / 100).clamp(0.0, 1.0);
    final color = Color.lerp(
      const Color(0xFF2F9DEB),
      const Color(0xFFE9573F),
      ratio,
    )!;

    return Container(
      width: 108,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 31,
            height: 92,
            child: CustomPaint(
              painter: _ThermometerPainter(ratio: ratio, liquidColor: color),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('THERMOMETER', style: TextStyle(color: Colors.white60, fontSize: 7, fontWeight: FontWeight.w800)),
                const SizedBox(height: 5),
                Text('${widget.temperature.toStringAsFixed(1)}°C', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12)),
                const SizedBox(height: 3),
                Text(_temperatureLabel(widget.temperature), style: const TextStyle(color: Colors.white70, fontSize: 7.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _phMeter() {
    return Container(
      width: 108,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop, size: 13, color: _phColor),
              const SizedBox(width: 4),
              const Text('pH METER', style: TextStyle(color: Colors.white60, fontSize: 7, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(color: _phColor.withValues(alpha: .15), borderRadius: BorderRadius.circular(6)),
            child: Text(
              widget.ph.toStringAsFixed(1),
              textAlign: TextAlign.center,
              style: TextStyle(color: _phColor, fontWeight: FontWeight.w900, fontSize: 14),
            ),
          ),
          const SizedBox(height: 3),
          Text(_phDescription(widget.ph), style: const TextStyle(color: Colors.white70, fontSize: 7.5)),
        ],
      ),
    );
  }

  String _temperatureLabel(double value) {
    if (value < 15) return 'Cold';
    if (value < 30) return 'Cool';
    if (value <= 45) return 'Warm';
    if (value <= 70) return 'Heat stress';
    return 'Very hot';
  }

  String _phDescription(double value) {
    if (value < 4) return 'Strongly acidic';
    if (value < 6) return 'Acidic';
    if (value < 7) return 'Slightly acidic';
    if (value == 7) return 'Neutral';
    if (value <= 8) return 'Slightly alkaline';
    if (value < 11) return 'Alkaline';
    return 'Strongly alkaline';
  }

  Widget _controlDeck() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF063F5D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _slider(
                  'TEMPERATURE',
                  widget.temperature,
                  0,
                  100,
                  '°C',
                  const Color(0xFFE67E22),
                  widget.onTemperatureChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _slider(
                  'pH',
                  widget.ph,
                  0,
                  14,
                  '',
                  const Color(0xFF29B7C8),
                  widget.onPhChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _slider(
            'SUBSTRATE CONCENTRATION',
            widget.substrate,
            widget.substrateMin,
            widget.substrateMax,
            '',
            const Color(0xFF7AC943),
            widget.onSubstrateChanged,
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(child: _actionButton(Icons.water_drop, 'ADD DROP', widget.onAddSubstrate)),
              const SizedBox(width: 7),
              Expanded(child: _actionButton(stirring ? Icons.rotate_right : Icons.sync, stirring ? 'MIXING' : 'STIR', _stir)),
              const SizedBox(width: 7),
              Expanded(
                child: _actionButton(
                  Icons.science,
                  widget.inhibitorActive ? 'INHIBITOR ON' : 'ADD INHIBITOR',
                  widget.onAddInhibitor,
                  active: widget.inhibitorActive,
                ),
              ),
            ],
          ),
          if (widget.model3D?.trim().isNotEmpty ?? false) ...[
            const SizedBox(height: 7),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => setState(() => showMolecularView = !showMolecularView),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      showMolecularView ? Icons.keyboard_arrow_up : Icons.view_in_ar,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      showMolecularView ? 'HIDE MOLECULAR VIEW' : 'VIEW 3D ENZYME',
                      style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: .5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    String suffix,
    Color color,
    ValueChanged<double> onChanged,
  ) {
    final safe = value.clamp(min, max).toDouble();
    final decimals = label == 'SUBSTRATE CONCENTRATION' && max <= 2 ? 2 : 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white60, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: .4))),
            Text('${safe.toStringAsFixed(decimals)}$suffix', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            inactiveTrackColor: Colors.white24,
            overlayColor: color.withValues(alpha: .14),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          ),
          child: Slider(
            value: safe,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  /// Figma-inspired scientific console. It turns the visual lab into a
  /// guided investigation by highlighting the next defensible lab action.
  Widget _scienceConsole() {
    final temperatureReady =
        (widget.temperature - widget.optimumTemperature).abs() <= 2;
    final phReady = (widget.ph - widget.optimumPh).abs() <= .3;
    final substrateThreshold =
        widget.substrateMin + (widget.substrateMax - widget.substrateMin) * .35;

    String guidance;
    if (!temperatureReady) {
      guidance =
          'Set the water bath near ${widget.optimumTemperature.toStringAsFixed(0)}°C, then keep pH and substrate constant.';
    } else if (!phReady) {
      guidance =
          'Set the buffer near pH ${widget.optimumPh.toStringAsFixed(1)}. Change only one variable in the next trial.';
    } else if (widget.substrate < substrateThreshold) {
      guidance =
          'Substrate may be limiting. Add a measured drop before comparing reaction rates.';
    } else if (widget.inhibitorActive) {
      guidance =
          'Record a matched control without inhibitor before interpreting inhibition.';
    } else {
      guidance =
          'Conditions are ready. Mix the sample, run a replicate, and record the result.';
    }

    return Semantics(
      label: 'Laboratory guidance. $guidance',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF052E47),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFF28D7F4).withValues(alpha: .32),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.smart_toy_outlined,
                    color: Color(0xFF28D7F4), size: 18),
                SizedBox(width: 7),
                Text('LAB ASSISTANT',
                    style: TextStyle(
                        color: Color(0xFF28D7F4),
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: .7)),
                Spacer(),
                Text('MODEL MODE',
                    style: TextStyle(
                        color: Colors.white54,
                        fontSize: 8,
                        fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 7),
            Text(guidance,
                style: const TextStyle(
                    color: Colors.white, fontSize: 11, height: 1.35)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _statusChip('T ${widget.temperature.toStringAsFixed(1)}°C',
                    temperatureReady),
                _statusChip('pH ${widget.ph.toStringAsFixed(1)}', phReady),
                _statusChip(
                    '[S] ${widget.substrate.toStringAsFixed(widget.substrateMax <= 2 ? 2 : 1)}',
                    widget.substrate > 0),
                _statusChip(widget.inhibitorActive ? 'Inhibitor present' : 'Control',
                    !widget.inhibitorActive),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Activity is a relative model prediction. Record repeat trials before drawing a conclusion.',
              style: TextStyle(color: Colors.white60, fontSize: 8.5, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String label, bool favorable) {
    final color = favorable ? const Color(0xFF54E5B7) : const Color(0xFFFFC857);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: .30)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 8.5, fontWeight: FontWeight.w800)),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onPressed, {bool active = false}) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 15),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: FilledButton.styleFrom(
        backgroundColor: active ? const Color(0xFF9E3C64) : const Color(0xFF0D759B),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 7),
        textStyle: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
    );
  }

  Widget _reagent(String symbol, String name, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 38,
            height: 70,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6), bottom: Radius.circular(8)),
              border: Border.all(color: Colors.white70),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(1, 2))],
            ),
            child: Center(child: Text(symbol, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 9))),
          ),
          const SizedBox(height: 3),
          Text(name, style: const TextStyle(color: Colors.white70, fontSize: 6.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _benchTube(String text, Color color) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(7), bottom: Radius.circular(5)),
            border: Border.all(color: Colors.white70),
          ),
          child: Center(child: Text(text, style: const TextStyle(fontSize: 6.5, fontWeight: FontWeight.w900))),
        ),
        Container(width: 35, height: 5, color: Colors.white54),
      ],
    );
  }

  Widget _trash() {
    return Container(
      width: 42,
      height: 32,
      decoration: BoxDecoration(color: const Color(0xFF1976D2), borderRadius: BorderRadius.circular(7), border: Border.all(color: Colors.white54)),
      child: const Icon(Icons.delete_outline, color: Colors.white, size: 19),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .14), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: .5)),
    );
  }

  Widget _molecularView() {
    return Container(
      height: 270,
      decoration: BoxDecoration(color: const Color(0xFFF6FAF9), borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 9, 7, 6),
            child: Row(
              children: [
                const Icon(Icons.view_in_ar, size: 17, color: Color(0xFF087F5B)),
                const SizedBox(width: 6),
                const Expanded(child: Text('3D ENZYME VIEW', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
                Text(widget.enzymeName.toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.grey)),
              ],
            ),
          ),
          Expanded(
            child: ModelViewer(
              key: ValueKey(widget.model3D),
              src: widget.model3D!,
              alt: 'Interactive 3D model of ${widget.enzymeName}',
              autoRotate: true,
              cameraControls: true,
              ar: false,
              shadowIntensity: 0.8,
              exposure: 1.1,
              backgroundColor: const Color(0xFFF6FAF9),
            ),
          ),
          if (widget.modelDescription != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
              child: Text(widget.modelDescription!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8, color: Colors.black54)),
            ),
        ],
      ),
    );
  }
}

class _BenchBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: .045);
    for (double y = 18; y < size.height - 55; y += 22) {
      for (double x = 10; x < size.width; x += 22) {
        canvas.drawCircle(Offset(x, y), 1.1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BenchBackgroundPainter oldDelegate) => false;
}

class _ThermometerPainter extends CustomPainter {
  final double ratio;
  final Color liquidColor;

  _ThermometerPainter({required this.ratio, required this.liquidColor});

  @override
  void paint(Canvas canvas, Size size) {
    final tube = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * .30, 5, size.width * .34, size.height - 18),
      const Radius.circular(9),
    );
    canvas.drawRRect(tube, Paint()..color = Colors.white.withValues(alpha: .35));
    canvas.drawRRect(tube, Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = Colors.white70);

    final bottom = size.height - 17;
    final liquidTop = bottom - ratio * (size.height - 27);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(size.width * .39, liquidTop, size.width * .55, bottom),
        const Radius.circular(7),
      ),
      Paint()..color = liquidColor,
    );
    canvas.drawCircle(Offset(size.width * .47, bottom + 1), 8, Paint()..color = liquidColor);

    final tickPaint = Paint()..color = Colors.white54..strokeWidth = 1;
    for (int i = 0; i <= 5; i++) {
      final y = 8 + i * (size.height - 25) / 5;
      canvas.drawLine(Offset(0, y), Offset(7, y), tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ThermometerPainter oldDelegate) => oldDelegate.ratio != ratio || oldDelegate.liquidColor != liquidColor;
}

class _ReactionPainter extends CustomPainter {
  final double phase;
  final double activity;
  final double substrate;
  final bool inhibitor;
  final bool stirring;
  final double temperature;
  final double ph;

  _ReactionPainter({
    required this.phase,
    required this.activity,
    required this.substrate,
    required this.inhibitor,
    required this.stirring,
    required this.temperature,
    required this.ph,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final beaker = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * .12, size.height * .08, size.width * .76, size.height * .82),
      const Radius.circular(20),
    );
    canvas.drawRRect(beaker, Paint()..color = Colors.white.withValues(alpha: .09));
    canvas.drawRRect(beaker, Paint()..style = PaintingStyle.stroke..strokeWidth = 3..color = Colors.white70);

    final stress = ((temperature - 37).abs() / 45).clamp(0.0, 1.0);
    final phStress = ((ph - 7).abs() / 7).clamp(0.0, 1.0);
    final solution = Color.lerp(
      const Color(0xFF46B5D1),
      const Color(0xFF5CCB82),
      (activity / 100).clamp(0.0, 1.0),
    )!;
    final finalColor = Color.lerp(solution, const Color(0xFFE98A68), (stress * .45 + phStress * .25).clamp(0.0, .7))!;

    final liquid = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * .16, size.height * .42, size.width * .68, size.height * .42),
      const Radius.circular(15),
    );
    canvas.drawRRect(liquid, Paint()..color = finalColor.withValues(alpha: .48));

    // Enzyme with a visible active-site pocket. The pocket is intentionally
    // simplified so learners can see the concept without implying residue-
    // level structural precision.
    final cx = size.width * .50;
    final cy = size.height * .60;
    final enzymeGlow = Paint()
      ..color = const Color(0xFF8D70D6).withValues(alpha: .16 + (activity / 100).clamp(0.0, 1.0) * .16);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: size.width * .36, height: size.height * .36),
      enzymeGlow,
    );
    final enzyme = Paint()..color = const Color(0xFF8D70D6);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: size.width * .30, height: size.height * .30),
      enzyme,
    );
    final site = Path()
      ..moveTo(cx - 22, cy - 5)
      ..quadraticBezierTo(cx - 2, cy - 25, cx + 22, cy - 5)
      ..quadraticBezierTo(cx + 7, cy + 10, cx - 12, cy + 7)
      ..close();
    canvas.drawPath(site, Paint()..color = const Color(0xFF26305F));

    // Active-site glow and docking guide.
    final siteGlow = Paint()..color = const Color(0xFF7CE7D5).withValues(alpha: .18 + .10 * math.sin(phase * math.pi * 2).abs());
    canvas.drawCircle(Offset(cx + 1, cy - 4), 27, siteGlow);
    final guide = Paint()..color = Colors.white38..strokeWidth = 1.5;
    final guideStart = Offset(cx - size.width * .30, cy - size.height * .15);
    canvas.drawLine(guideStart, Offset(cx - 26, cy - 5), guide);

    // Measured substrate particles orbit the chamber; one particle follows
    // the guide toward the active site.
    final count = (7 + substrate * .8).clamp(7.0, 18.0).round();
    for (var i = 0; i < count; i++) {
      final base = phase * math.pi * 2 + i * 1.71;
      final radius = size.width * (.22 + (i % 3) * .035);
      final swirl = stirring ? phase * math.pi * 2 : 0;
      final x = cx + math.cos(base + swirl) * radius;
      final y = cy + math.sin(base + swirl) * radius * .55;
      canvas.drawCircle(Offset(x, y), 3.4, Paint()..color = const Color(0xFFFFD166));
    }

    if (activity > 25) {
      final productCount = (activity / 18).clamp(1.0, 6.0).round();
      for (var i = 0; i < productCount; i++) {
        final a = phase * math.pi * 2 + i * 1.9;
        final x = cx + math.cos(a) * size.width * .34;
        final y = cy - ((phase + i * .13) % 1) * size.height * .26;
        final p = Path()
          ..moveTo(x, y - 4)
          ..lineTo(x + 4, y)
          ..lineTo(x, y + 4)
          ..lineTo(x - 4, y)
          ..close();
        canvas.drawPath(p, Paint()..color = const Color(0xFF69D7E8));
      }
    }

    if (inhibitor) {
      for (var i = 0; i < 4; i++) {
        final a = -phase * math.pi * 2 + i * 1.35;
        final x = cx + math.cos(a) * size.width * .29;
        final y = cy + math.sin(a) * size.height * .25;
        final p = Paint()..color = const Color(0xFFE64980)..strokeWidth = 2.4..style = PaintingStyle.stroke;
        canvas.drawLine(Offset(x - 5, y - 5), Offset(x + 5, y + 5), p);
        canvas.drawLine(Offset(x + 5, y - 5), Offset(x - 5, y + 5), p);
      }
    }

    final bubbleCount = stirring ? 9 : 4;
    for (var i = 0; i < bubbleCount; i++) {
      final x = size.width * (.24 + (i % 5) * .13);
      final y = size.height * (.78 - ((phase + i * .11) % 1) * .30);
      canvas.drawCircle(Offset(x, y), 2.7, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = Colors.white60);
    }

    // Docking substrate animation. The path changes continuously so the
    // molecular scene does not look like a static illustration after every run.
    final docking = (phase * 1.25) % 1.0;
    final dockX = guideStart.dx + (cx - 26 - guideStart.dx) * docking;
    final dockY = guideStart.dy + (cy - 5 - guideStart.dy) * docking;
    canvas.drawCircle(Offset(dockX, dockY), 6.2, Paint()..color = const Color(0xFFFFC857));
    canvas.drawCircle(Offset(dockX, dockY), 10.5, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = const Color(0xFFFFC857).withValues(alpha: .45));

    // Small energy flashes appear around the active site when activity is high.
    if (activity > 55) {
      for (var i = 0; i < 4; i++) {
        final a = phase * math.pi * 2 + i * math.pi / 2;
        final ex = cx + math.cos(a) * 34;
        final ey = cy - 5 + math.sin(a) * 25;
        final ep = Paint()..color = const Color(0xFFFFE27A)..strokeWidth = 2;
        canvas.drawLine(Offset(ex - 4, ey), Offset(ex + 4, ey), ep);
        canvas.drawLine(Offset(ex, ey - 4), Offset(ex, ey + 4), ep);
      }
    }

    final status = stirring ? 'MIXING' : activity > 70 ? 'CATALYSIS ACTIVE' : activity > 0 ? 'SUBSTRATE BINDING' : 'READY TO RUN';
    final tp = TextPainter(
      text: TextSpan(text: status, style: const TextStyle(color: Color(0xFF8EF0D0), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: .7)),
      textDirection: TextDirection.ltr,
    )..layout();
    final activeLabel = TextPainter(
      text: const TextSpan(text: 'ACTIVE SITE', style: TextStyle(color: Colors.white70, fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: .8)),
      textDirection: TextDirection.ltr,
    )..layout();
    activeLabel.paint(canvas, Offset(cx - activeLabel.width / 2, cy + 48));

    tp.paint(canvas, Offset(cx - tp.width / 2, size.height - 14));
  }

  @override
  bool shouldRepaint(covariant _ReactionPainter oldDelegate) => true;
}
