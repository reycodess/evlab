import 'package:flutter/material.dart';

class ThreeDTrialGraph extends StatelessWidget {
  final List<double> values;
  final String title;

  const ThreeDTrialGraph({
    super.key,
    required this.values,
    this.title = 'Trial activity landscape',
  });

  @override
  Widget build(BuildContext context) {
    final maxV = values.isEmpty
        ? 1.0
        : values.reduce((a, b) => a > b ? a : b).clamp(1.0, 100.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF102A43),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 190,
            child: CustomPaint(
              painter: _GraphPainter(values, maxV),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Relative activity (%) • each bar is one trial',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _GraphPainter extends CustomPainter {
  final List<double> v;
  final double maxV;

  _GraphPainter(this.v, this.maxV);

  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..color = const Color(0xFF49D3C6);

    final grid = Paint()
      ..color = Colors.white12
      ..strokeWidth = 1;

    // Draw horizontal grid lines.
    for (int i = 1; i < 5; i++) {
      final y = s.height - i * s.height / 5;
      c.drawLine(Offset(0, y), Offset(s.width, y), grid);
    }

    if (v.isEmpty) return;

    final bw = s.width / (v.length * 1.7);

    for (int i = 0; i < v.length; i++) {
      final h = (v[i] / maxV) * (s.height - 25);
      final x = i * (bw * 1.7) + bw * 0.35;

      final r = Rect.fromLTWH(
        x,
        s.height - h,
        bw,
        h,
      );

      // Front face.
      c.drawRect(r, p);

      // 3D side face.
      final side = Path()
        ..moveTo(x + bw, s.height - h)
        ..lineTo(x + bw + 8, s.height - h - 6)
        ..lineTo(x + bw + 8, s.height - 6)
        ..lineTo(x + bw, s.height)
        ..close();

      c.drawPath(
        side,
        Paint()..color = const Color(0xFF258F86),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GraphPainter old) {
    return old.v != v;
  }
}