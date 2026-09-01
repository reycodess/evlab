import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class RealisticPHControl extends StatefulWidget {
  final double ph;
  final bool enabled;
  final ValueChanged<double> onChanged;

  const RealisticPHControl({
    super.key,
    required this.ph,
    required this.enabled,
    required this.onChanged,
  });

  @override
  State<RealisticPHControl> createState() => _RealisticPHControlState();
}

class _RealisticPHControlState extends State<RealisticPHControl>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _solutionColor() {
    if (widget.ph < 3) {
      return const Color(0xFFD32F2F);
    }

    if (widget.ph < 5) {
      return const Color(0xFFF4511E);
    }

    if (widget.ph < 6.5) {
      return const Color(0xFFFFB300);
    }

    if (widget.ph < 7.5) {
      return const Color(0xFF43A047);
    }

    if (widget.ph < 9) {
      return const Color(0xFF00ACC1);
    }

    if (widget.ph < 11) {
      return const Color(0xFF1E88E5);
    }

    return const Color(0xFF7E57C2);
  }

  String _description() {
    if (widget.ph < 3) {
      return 'Strongly acidic';
    }

    if (widget.ph < 5) {
      return 'Acidic';
    }

    if (widget.ph < 6.5) {
      return 'Weakly acidic';
    }

    if (widget.ph < 7.5) {
      return 'Near neutral';
    }

    if (widget.ph < 9) {
      return 'Weakly alkaline';
    }

    if (widget.ph < 11) {
      return 'Alkaline';
    }

    return 'Strongly alkaline';
  }

  void _changePH(double amount) {
    if (!widget.enabled) return;

    final newValue = (widget.ph + amount).clamp(1.0, 14.0);

    widget.onChanged(
      double.parse(newValue.toStringAsFixed(1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final solutionColor = _solutionColor();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: solutionColor.withValues(alpha: 0.22),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: solutionColor.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // =====================================================
          // HEADER
          // =====================================================

          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blueGrey.shade700,
                      Colors.blueGrey.shade900,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.water_drop,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'pH METER',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Digital laboratory pH measurement',
                      style: TextStyle(
                        fontSize: 12,
                        color: EVLabColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // =====================================================
          // REALISTIC PH METER
          // =====================================================

          SizedBox(
            height: 285,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 5,
                  child: _buildMeter(
                    solutionColor,
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  flex: 4,
                  child: _buildSolutionBeaker(
                    solutionColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // =====================================================
          // DIGITAL READING
          // =====================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF18201D),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.monitor_heart,
                  color: Color(0xFF8DFFB0),
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Text(
                  'pH',
                  style: TextStyle(
                    color: Color(0xFFB8C8BF),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  widget.ph.toStringAsFixed(2),
                  style: const TextStyle(
                    color: Color(0xFF8DFFB0),
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // =====================================================
          // DESCRIPTION
          // =====================================================

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: solutionColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.science,
                  color: solutionColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  _description(),
                  style: TextStyle(
                    color: solutionColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // =====================================================
          // PH CONTROL
          // =====================================================

          Row(
            children: [
              _controlButton(
                Icons.remove,
                    () => _changePH(-0.1),
              ),

              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${widget.ph.toStringAsFixed(1)} pH',
                      style: TextStyle(
                        color: solutionColor,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Current measurement',
                      style: TextStyle(
                        color: EVLabColors.textLight,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              _controlButton(
                Icons.add,
                    () => _changePH(0.1),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // =====================================================
          // SCALE
          // =====================================================

          _buildPHScale(solutionColor),

          const SizedBox(height: 10),

          Text(
            widget.enabled
                ? 'Adjust the pH using the controls or drag the scale.'
                : 'pH control disabled while the experiment is running.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: EVLabColors.textLight,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIGITAL METER
  // ============================================================

  Widget _buildMeter(Color solutionColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(
          constraints.maxWidth,
          175.0,
        );

        return Center(
          child: SizedBox(
            width: width,
            height: 250,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Meter body
                Positioned(
                  top: 20,
                  left: 8,
                  right: 8,
                  child: Container(
                    height: 135,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey.shade300,
                          Colors.grey.shade700,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey.shade800,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                ),

                // Screen
                Positioned(
                  top: 38,
                  left: 25,
                  right: 25,
                  child: Container(
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFF18201D),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.black54,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.ph.toStringAsFixed(2),
                        style: const TextStyle(
                          color: Color(0xFF8DFFB0),
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                // Buttons
                Positioned(
                  top: 105,
                  left: 28,
                  child: _meterButton(Icons.remove),
                ),

                Positioned(
                  top: 105,
                  right: 28,
                  child: _meterButton(Icons.add),
                ),

                // Brand
                const Positioned(
                  top: 101,
                  child: Text(
                    'EV-LAB',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: Colors.white70,
                    ),
                  ),
                ),

                // Cable
                Positioned(
                  top: 143,
                  child: CustomPaint(
                    size: const Size(60, 65),
                    painter: _CablePainter(),
                  ),
                ),

                // Probe
                Positioned(
                  top: 178,
                  child: _buildProbe(solutionColor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _meterButton(IconData icon) {
    return Container(
      width: 25,
      height: 18,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        icon,
        size: 12,
        color: Colors.white,
      ),
    );
  }

  // ============================================================
  // PROBE
  // ============================================================

  Widget _buildProbe(Color solutionColor) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 35,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.grey.shade200,
                Colors.grey.shade500,
                Colors.grey.shade800,
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.shade800,
            ),
          ),
        ),
        Container(
          width: 12,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            border: Border.all(
              color: Colors.grey.shade500,
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(6),
            ),
          ),
        ),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: solutionColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: solutionColor.withValues(alpha: 0.6),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BEAKER
  // ============================================================

  Widget _buildSolutionBeaker(Color solutionColor) {
    return Center(
      child: SizedBox(
        width: 115,
        height: 245,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Beaker glass
            Positioned(
              bottom: 15,
              child: Container(
                width: 105,
                height: 175,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  border: Border.all(
                    color: Colors.blueGrey.shade300,
                    width: 3,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
              ),
            ),

            // Solution
            Positioned(
              bottom: 18,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 99,
                height: 105,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      solutionColor.withValues(alpha: 0.65),
                      solutionColor.withValues(alpha: 0.9),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(17),
                  ),
                ),
              ),
            ),

            // Solution surface
            Positioned(
              bottom: 115,
              child: Container(
                width: 99,
                height: 12,
                decoration: BoxDecoration(
                  color: solutionColor.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),

            // Measurement marks
            Positioned(
              right: 5,
              bottom: 42,
              child: Column(
                children: List.generate(
                  5,
                      (index) => Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    width: 15,
                    height: 1,
                    color: Colors.blueGrey.shade400,
                  ),
                ),
              ),
            ),

            // Bubbles
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Positioned(
                  bottom: 35 +
                      (_animationController.value * 55),
                  left: 28 +
                      math.sin(
                        _animationController.value * math.pi * 2,
                      ) *
                          8,
                  child: Opacity(
                    opacity: 0.55,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Probe going into solution
            Positioned(
              top: 0,
              child: Container(
                width: 11,
                height: 145,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey.shade200,
                      Colors.grey.shade600,
                      Colors.grey.shade300,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ),

            // Probe tip
            Positioned(
              top: 135,
              child: Container(
                width: 14,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),

            // Beaker label
            Positioned(
              bottom: 0,
              child: Text(
                'BUFFER SOLUTION',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: Colors.blueGrey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PH SCALE
  // ============================================================

  Widget _buildPHScale(Color solutionColor) {
    return GestureDetector(
      onHorizontalDragUpdate: widget.enabled
          ? (details) {
        final box = context.findRenderObject() as RenderBox?;

        if (box == null) return;

        final localPosition = box.globalToLocal(
          Offset(
            box.localToGlobal(Offset.zero).dx +
                details.localPosition.dx,
            box.localToGlobal(Offset.zero).dy +
                details.localPosition.dy,
          ),
        );

        final width = box.size.width;

        final normalized = (localPosition.dx / width)
            .clamp(0.0, 1.0);

        final newPH = 1.0 + (normalized * 13.0);

        widget.onChanged(
          double.parse(newPH.toStringAsFixed(1)),
        );
      }
          : null,
      child: Column(
        children: [
          SizedBox(
            height: 25,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 7,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFD32F2F),
                          Color(0xFFF4511E),
                          Color(0xFFFFB300),
                          Color(0xFF43A047),
                          Color(0xFF00ACC1),
                          Color(0xFF1E88E5),
                          Color(0xFF7E57C2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final position =
                        ((widget.ph - 1) / 13) *
                            constraints.maxWidth;

                    return Positioned(
                      left: position.clamp(
                        0.0,
                        constraints.maxWidth - 4,
                      ),
                      top: 1,
                      child: Container(
                        width: 8,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: Colors.grey.shade700,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: 0.2,
                              ),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '4',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '7',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '10',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '14',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUTTON
  // ============================================================

  Widget _controlButton(
      IconData icon,
      VoidCallback callback,
      ) {
    return Material(
      color: EVLabColors.background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: widget.enabled ? callback : null,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 50,
          height: 50,
          child: Icon(
            icon,
            color: widget.enabled
                ? EVLabColors.emeraldDark
                : Colors.grey,
          ),
        ),
      ),
    );
  }
}

// ================================================================
// CABLE PAINTER
// ================================================================

class _CablePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final path = Path();

    path.moveTo(size.width / 2, 0);

    path.cubicTo(
      size.width / 2,
      size.height * 0.25,
      size.width * 0.8,
      size.height * 0.35,
      size.width * 0.55,
      size.height,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(
      covariant _CablePainter oldDelegate,
      ) {
    return false;
  }
}