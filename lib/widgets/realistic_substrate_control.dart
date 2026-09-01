import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class RealisticSubstrateControl extends StatefulWidget {
  final double substrate;
  final double minimum;
  final double maximum;
  final double step;
  final String unit;
  final bool enabled;
  final ValueChanged<double> onChanged;

  const RealisticSubstrateControl({
    super.key,
    required this.substrate,
    required this.minimum,
    required this.maximum,
    required this.step,
    required this.unit,
    required this.enabled,
    required this.onChanged,
  });

  @override
  State<RealisticSubstrateControl> createState() =>
      _RealisticSubstrateControlState();
}

class _RealisticSubstrateControlState
    extends State<RealisticSubstrateControl>
    with SingleTickerProviderStateMixin {
  late AnimationController _pourController;

  bool _isPouring = false;
  double _pourProgress = 0.0;

  double get _range => widget.maximum - widget.minimum;

  double _normalizedValue() {
    if (_range <= 0) return 0.0;

    return ((widget.substrate - widget.minimum) / _range)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  @override
  void initState() {
    super.initState();

    _pourController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _pourController.addListener(() {
      if (!mounted) return;

      setState(() {
        _pourProgress = _pourController.value;
      });
    });
  }

  @override
  void dispose() {
    _pourController.dispose();
    super.dispose();
  }

  void _addSubstrate() {
    if (!widget.enabled) return;
    if (widget.substrate >= widget.maximum) return;

    final newValue = math.min(
      widget.maximum,
      widget.substrate + widget.step,
    );

    _startPourAnimation();

    widget.onChanged(
      double.parse(newValue.toStringAsFixed(2)),
    );
  }

  void _removeSubstrate() {
    if (!widget.enabled) return;
    if (widget.substrate <= widget.minimum) return;

    final newValue = math.max(
      widget.minimum,
      widget.substrate - widget.step,
    );

    widget.onChanged(
      double.parse(newValue.toStringAsFixed(2)),
    );
  }

  void _startPourAnimation() {
    if (_isPouring) return;

    setState(() {
      _isPouring = true;
    });

    _pourController.forward(from: 0).then((_) {
      if (!mounted) return;

      setState(() {
        _isPouring = false;
      });
    });
  }

  void _handleVerticalDrag(double delta) {
    if (!widget.enabled) return;

    if (delta < -3) {
      _addSubstrate();
    } else if (delta > 3) {
      _removeSubstrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final normalized = _normalizedValue();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFF1565C0).withValues(alpha: 0.18),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),

          const SizedBox(height: 20),

          SizedBox(
            height: 320,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: _buildCylinder(normalized),
                ),
                const SizedBox(width: 15),
                Expanded(
                  flex: 4,
                  child: _buildReactionVessel(normalized),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          _buildDigitalReading(),

          const SizedBox(height: 15),

          _buildAmountDescription(),

          const SizedBox(height: 18),

          Row(
            children: [
              _controlButton(
                Icons.remove,
                _removeSubstrate,
              ),

              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${widget.substrate.toStringAsFixed(2)} ${widget.unit}',
                      style: const TextStyle(
                        color: Color(0xFF1565C0),
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Substrate concentration',
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
                _addSubstrate,
              ),
            ],
          ),

          const SizedBox(height: 18),

          _buildAmountScale(),

          const SizedBox(height: 10),

          Text(
            widget.enabled
                ? 'Drag up to add substrate or drag down to remove it.'
                : 'Substrate control disabled while the experiment is running.',
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

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF42A5F5),
                Color(0xFF1565C0),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.science,
            color: Colors.white,
            size: 29,
          ),
        ),
        const SizedBox(width: 13),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SUBSTRATE CYLINDER',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Graduated laboratory measurement',
                style: TextStyle(
                  fontSize: 12,
                  color: EVLabColors.textMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCylinder(double normalized) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: widget.enabled
          ? (details) {
        _handleVerticalDrag(details.delta.dy);
      }
          : null,
      child: Center(
        child: SizedBox(
          width: 150,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Cylinder shadow
              Positioned(
                bottom: 5,
                child: Container(
                  width: 92,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),

              // Cylinder body
              Positioned(
                top: 18,
                bottom: 22,
                child: Container(
                  width: 82,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    border: Border.all(
                      color: Colors.blueGrey.shade400,
                      width: 3,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(14),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 10,
                        offset: const Offset(3, 5),
                      ),
                    ],
                  ),
                ),
              ),

              // Substrate
              Positioned(
                bottom: 25,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 76,
                  height: 238 * normalized,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF64B5F6),
                        Color(0xFF1976D2),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(11),
                    ),
                  ),
                ),
              ),

              // Surface
              Positioned(
                bottom: 25 + (238 * normalized) - 5,
                child: Container(
                  width: 76,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF90CAF9),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),

              // Cylinder lip
              Positioned(
                top: 12,
                child: Container(
                  width: 92,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.65),
                    border: Border.all(
                      color: Colors.blueGrey.shade500,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),

              // Measurement marks
              Positioned(
                left: 27,
                top: 43,
                bottom: 35,
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    9,
                        (index) {
                      return Row(
                        children: [
                          Container(
                            width: index % 2 == 0 ? 20 : 12,
                            height: 1,
                            color: Colors.blueGrey.shade500,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // Measurement numbers
              Positioned(
                right: 12,
                top: 43,
                bottom: 35,
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    _measurementText(
                      widget.maximum,
                    ),
                    _measurementText(
                      widget.minimum +
                          (_range * 0.75),
                    ),
                    _measurementText(
                      widget.minimum +
                          (_range * 0.50),
                    ),
                    _measurementText(
                      widget.minimum +
                          (_range * 0.25),
                    ),
                    _measurementText(
                      widget.minimum,
                    ),
                  ],
                ),
              ),

              // Pouring animation
              if (_isPouring)
                Positioned(
                  top: 28,
                  right: 20,
                  child: Transform.rotate(
                    angle: -0.35,
                    child: _buildPourStream(),
                  ),
                ),

              // Touch indicator
              Positioned(
                bottom: 0,
                child: Row(
                  children: [
                    Icon(
                      Icons.swap_vert,
                      size: 16,
                      color: Colors.blueGrey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'DRAG',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: Colors.blueGrey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _measurementText(double value) {
    return Text(
      value.toStringAsFixed(1),
      style: const TextStyle(
        fontSize: 8,
        fontWeight: FontWeight.bold,
        color: EVLabColors.textLight,
      ),
    );
  }

  Widget _buildPourStream() {
    return AnimatedBuilder(
      animation: _pourController,
      builder: (context, child) {
        return Opacity(
          opacity: (1.0 - _pourProgress).clamp(
            0.0,
            1.0,
          ),
          child: Container(
            width: 8,
            height: 55 + (_pourProgress * 20),
            decoration: BoxDecoration(
              color: const Color(0xFF42A5F5),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.25),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReactionVessel(double normalized) {
    final reactionLevel =
        70 + (normalized * 90);

    return Center(
      child: SizedBox(
        width: 125,
        height: 245,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Vessel
            Positioned(
              bottom: 20,
              child: Container(
                width: 105,
                height: 165,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
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

            // Reaction solution
            Positioned(
              bottom: 23,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                width: 99,
                height: reactionLevel,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF90CAF9),
                      Color(0xFF1976D2),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(17),
                  ),
                ),
              ),
            ),

            // Bubbles
            ...List.generate(
              4,
                  (index) {
                final offset =
                    math.sin(
                      (_pourProgress * math.pi * 2) +
                          index,
                    ) *
                        5;

                return Positioned(
                  bottom:
                  45 +
                      ((index + 1) * 25) +
                      offset,
                  left: 25 + (index * 16),
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(
                          alpha: 0.75,
                        ),
                        width: 1,
                      ),
                    ),
                  ),
                );
              },
            ),

            Positioned(
              bottom: 0,
              child: Text(
                'REACTION VESSEL',
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

  Widget _buildDigitalReading() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF18201D),
        borderRadius: BorderRadius.circular(16),
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
            Icons.water_drop,
            color: Color(0xFF8DFFB0),
            size: 20,
          ),
          const SizedBox(width: 10),
          const Text(
            'SUBSTRATE',
            style: TextStyle(
              color: Color(0xFFB8C8BF),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            '${widget.substrate.toStringAsFixed(2)} ${widget.unit}',
            style: const TextStyle(
              color: Color(0xFF8DFFB0),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountDescription() {
    final normalized = _normalizedValue();

    String description;

    if (normalized <= 0.05) {
      description = 'Very low substrate';
    } else if (normalized < 0.30) {
      description = 'Low substrate concentration';
    } else if (normalized < 0.70) {
      description = 'Moderate substrate concentration';
    } else if (normalized < 0.90) {
      description = 'High substrate concentration';
    } else {
      description = 'Maximum substrate concentration';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1976D2)
            .withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.science,
            color: Color(0xFF1976D2),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF1565C0),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountScale() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final normalized = _normalizedValue();

        final markerPosition =
        ((normalized * constraints.maxWidth) - 5)
            .clamp(
          0.0,
          constraints.maxWidth - 10,
        )
            .toDouble();

        return Column(
          children: [
            SizedBox(
              height: 24,
              child: Stack(
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
                            Color(0xFFE3F2FD),
                            Color(0xFF90CAF9),
                            Color(0xFF1976D2),
                          ],
                        ),
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Positioned(
                    left: markerPosition,
                    top: 1,
                    child: Container(
                      width: 10,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(5),
                        border: Border.all(
                          color: const Color(0xFF1565C0),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.18,
                            ),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.minimum.toStringAsFixed(1)} ${widget.unit}',
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.maximum.toStringAsFixed(1)} ${widget.unit}',
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

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