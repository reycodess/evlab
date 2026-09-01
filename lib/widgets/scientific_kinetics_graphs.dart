import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/enzyme.dart';
import '../models/inhibitor.dart';
import '../services/enzyme_simulation.dart';

/// Scientific plots used by EV-LAB's results page.
///
/// These are model curves, not experimental measurements. Temperature and pH
/// use the enzyme's supplied reference activity curves; substrate uses the
/// Michaelis-Menten equation; inhibitor curves use the standard idealized
/// inhibition equations.
class ScientificKineticsGraphs extends StatelessWidget {
  final Enzyme enzyme;
  final InhibitionType inhibitorType;
  final double inhibitorRatio;

  const ScientificKineticsGraphs({
    super.key,
    required this.enzyme,
    this.inhibitorType = InhibitionType.none,
    this.inhibitorRatio = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionCard(
          title: 'Michaelis-Menten kinetics',
          subtitle: 'Reaction velocity versus substrate concentration',
          child: _KineticsChart(
            spotsA: _substrateCurve(InhibitionType.none),
            spotsB: inhibitorType == InhibitionType.none
                ? null
                : _substrateCurve(inhibitorType),
            labelA: 'No inhibitor',
            labelB: inhibitorType == InhibitionType.none
                ? null
                : '${inhibitionTypeName(inhibitorType)} inhibitor',
            xLabel: 'Substrate concentration',
            yLabel: 'Velocity',
            xSuffix: '',
            ySuffix: '',
          ),
        ),
        const SizedBox(height: 14),
        _sectionCard(
          title: 'Temperature response',
          subtitle: 'Relative activity from the enzyme reference curve',
          child: _KineticsChart(
            spotsA: _temperatureCurve(),
            labelA: 'Reference activity',
            xLabel: 'Temperature (°C)',
            yLabel: 'Relative activity',
            xSuffix: '°',
            ySuffix: '%',
            yIsFraction: true,
          ),
        ),
        const SizedBox(height: 14),
        _sectionCard(
          title: 'pH response',
          subtitle: 'Relative activity from the enzyme reference curve',
          child: _KineticsChart(
            spotsA: _phCurve(),
            labelA: 'Reference activity',
            xLabel: 'pH',
            yLabel: 'Relative activity',
            xSuffix: '',
            ySuffix: '%',
            yIsFraction: true,
          ),
        ),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Scientific note: these curves are calculated model/reference curves. They are not direct measurements from a physical laboratory.',
            style: TextStyle(fontSize: 11, color: Colors.black54, height: 1.35),
          ),
        ),
      ],
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E8E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 3),
          Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 11)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  List<FlSpot> _substrateCurve(InhibitionType type) {
    final km = enzyme.km > 0 ? enzyme.km : 1.0;
    final vmax = enzyme.vmax > 0 ? enzyme.vmax : 1.0;
    final maxSubstrate = math.max(km * 6, 10.0);
    final spots = <FlSpot>[];

    double alpha = 1;
    double alphaPrime = 1;
    final r = inhibitorRatio.clamp(0.0, 10.0).toDouble();
    switch (type) {
      case InhibitionType.none:
        break;
      case InhibitionType.competitive:
        alpha = 1 + r;
        break;
      case InhibitionType.noncompetitive:
        alpha = 1 + r;
        alphaPrime = 1 + r;
        break;
      case InhibitionType.uncompetitive:
        alphaPrime = 1 + r;
        break;
      case InhibitionType.mixed:
        alpha = 1 + r;
        alphaPrime = 1 + r * 0.5;
        break;
    }

    for (var i = 0; i <= 80; i++) {
      final substrate = maxSubstrate * i / 80;
      final velocity = substrate <= 0
          ? 0.0
          : vmax * substrate / (alpha * km + alphaPrime * substrate);
      spots.add(FlSpot(substrate, velocity));
    }
    return spots;
  }

  List<FlSpot> _temperatureCurve() {
    final data = enzyme.temperatureActivity;
    if (data.isEmpty) {
      final optimum = _number(enzyme.optimumTemperature, 37);
      return List.generate(81, (i) {
        final x = i * 100 / 80;
        final d = x - optimum;
        return FlSpot(x, math.exp(-(d * d) / (2 * 15 * 15)));
      });
    }
    final points = data.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final minX = points.first.key;
    final maxX = points.last.key;
    return List.generate(81, (i) {
      final x = minX + (maxX - minX) * i / 80;
      return FlSpot(x, EnzymeSimulation.temperatureFactorForCurve(enzyme, x));
    });
  }

  List<FlSpot> _phCurve() {
    final data = enzyme.phActivity;
    if (data.isEmpty) {
      final optimum = _number(enzyme.optimumPH, 7);
      return List.generate(81, (i) {
        final x = i * 14 / 80;
        final d = x - optimum;
        return FlSpot(x, math.exp(-(d * d) / (2 * 2 * 2)));
      });
    }
    final points = data.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final minX = points.first.key;
    final maxX = points.last.key;
    return List.generate(81, (i) {
      final x = minX + (maxX - minX) * i / 80;
      return FlSpot(x, EnzymeSimulation.phFactorForCurve(enzyme, x));
    });
  }

  double _number(String text, double fallback) {
    final m = RegExp(r'[-+]?\d*\.?\d+').firstMatch(text);
    return double.tryParse(m?.group(0) ?? '') ?? fallback;
  }
}

class _KineticsChart extends StatelessWidget {
  final List<FlSpot> spotsA;
  final List<FlSpot>? spotsB;
  final String labelA;
  final String? labelB;
  final String xLabel;
  final String yLabel;
  final String xSuffix;
  final String ySuffix;
  final bool yIsFraction;

  const _KineticsChart({
    required this.spotsA,
    this.spotsB,
    required this.labelA,
    this.labelB,
    required this.xLabel,
    required this.yLabel,
    required this.xSuffix,
    required this.ySuffix,
    this.yIsFraction = false,
  });

  @override
  Widget build(BuildContext context) {
    final all = [...spotsA, ...?spotsB];
    final maxX = all.map((e) => e.x).reduce(math.max);
    final maxY = all.map((e) => e.y).reduce(math.max);
    final chartMaxY = yIsFraction ? 1.0 : maxY * 1.12;

    return Column(
      children: [
        SizedBox(
          height: 205,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: maxX <= 0 ? 1 : maxX,
              minY: 0,
              maxY: chartMaxY <= 0 ? 1 : chartMaxY,
              gridData: FlGridData(
                show: true,
                horizontalInterval: yIsFraction ? 0.25 : null,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: Colors.black.withValues(alpha: .08),
                  strokeWidth: 1,
                ),
                getDrawingVerticalLine: (_) => FlLine(
                  color: Colors.black.withValues(alpha: .05),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (items) => items.map((spot) {
                    final y = yIsFraction ? spot.y * 100 : spot.y;
                    return LineTooltipItem(
                      '${spot.x.toStringAsFixed(2)}\n${y.toStringAsFixed(1)}${yIsFraction ? '%' : ''}',
                      const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700),
                    );
                  }).toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spotsA,
                  isCurved: true,
                  barWidth: 3,
                  color: const Color(0xFF168B78),
                  dotData: const FlDotData(show: false),
                ),
                if (spotsB != null)
                  LineChartBarData(
                    spots: spotsB!,
                    isCurved: true,
                    barWidth: 3,
                    color: const Color(0xFFE57A22),
                    dashArray: [7, 5],
                    dotData: const FlDotData(show: false),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legend(const Color(0xFF168B78), labelA),
            if (labelB != null) ...[
              const SizedBox(width: 16),
              _legend(const Color(0xFFE57A22), labelB!),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Text('$xLabel  •  $yLabel${ySuffix.isEmpty ? '' : ' ($ySuffix)'}', style: const TextStyle(fontSize: 10, color: Colors.black45)),
      ],
    );
  }

  Widget _legend(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 18, height: 3, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
