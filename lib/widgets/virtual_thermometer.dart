import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class VirtualThermometer extends StatefulWidget {
  final double temperature;
  final double minimum;
  final double maximum;
  final double? optimumTemperature;
  final bool enabled;
  final ValueChanged<double> onChanged;

  const VirtualThermometer({
    super.key,
    required this.temperature,
    this.minimum = 0.0,
    this.maximum = 100.0,
    this.optimumTemperature,
    required this.enabled,
    required this.onChanged,
  });

  @override
  State<VirtualThermometer> createState() => _VirtualThermometerState();
}

class _VirtualThermometerState extends State<VirtualThermometer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  double get _range => widget.maximum - widget.minimum;

  double _normalizedTemperature(double temperature) {
    if (_range <= 0) return 0.0;

    return ((temperature - widget.minimum) / _range)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  double _temperatureFromPosition(
      double localY,
      double height,
      ) {
    if (height <= 0 || _range <= 0) {
      return widget.temperature;
    }

    final normalized =
    (1.0 - (localY / height)).clamp(0.0, 1.0).toDouble();

    final value =
        widget.minimum + (normalized * _range);

    return value.clamp(
      widget.minimum,
      widget.maximum,
    ).toDouble();
  }

  void _updateFromPosition(
      Offset localPosition,
      double height,
      ) {
    if (!widget.enabled) return;

    final value = _temperatureFromPosition(
      localPosition.dy,
      height,
    );

    widget.onChanged(
      double.parse(value.toStringAsFixed(1)),
    );
  }

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

  Color _temperatureColor() {
    final normalized = _normalizedTemperature(
      widget.temperature,
    );

    if (normalized < 0.25) {
      return const Color(0xFF2196F3);
    }

    if (normalized < 0.50) {
      return const Color(0xFF00ACC1);
    }

    if (normalized < 0.70) {
      return const Color(0xFFFFB300);
    }

    if (normalized < 0.85) {
      return const Color(0xFFFF7043);
    }

    return const Color(0xFFD32F2F);
  }

  String _temperatureDescription() {
    final normalized = _normalizedTemperature(
      widget.temperature,
    );

    if (normalized < 0.20) {
      return 'Very cold';
    }

    if (normalized < 0.40) {
      return 'Cool';
    }

    if (normalized < 0.60) {
      return 'Moderate';
    }

    if (normalized < 0.80) {
      return 'Warm';
    }

    return 'Very hot';
  }

  void _changeTemperature(double amount) {
    if (!widget.enabled) return;

    final newTemperature = (widget.temperature + amount)
        .clamp(
      widget.minimum,
      widget.maximum,
    )
        .toDouble();

    widget.onChanged(
      double.parse(
        newTemperature.toStringAsFixed(1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final temperatureColor = _temperatureColor();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: temperatureColor.withValues(alpha: 0.22),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: temperatureColor.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(temperatureColor),

          const SizedBox(height: 20),

          SizedBox(
            height: 330,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: _buildThermometer(
                    temperatureColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 4,
                  child: _buildTemperatureEnvironment(
                    temperatureColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _buildDigitalDisplay(temperatureColor),

          const SizedBox(height: 14),

          _buildDescription(temperatureColor),

          const SizedBox(height: 18),

          Row(
            children: [
              _controlButton(
                Icons.remove,
                    () => _changeTemperature(-1.0),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${widget.temperature.toStringAsFixed(1)} °C',
                      style: TextStyle(
                        color: temperatureColor,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Current temperature',
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
                    () => _changeTemperature(1.0),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _buildTemperatureScale(temperatureColor),

          const SizedBox(height: 10),

          Text(
            widget.enabled
                ? 'Drag the thermometer level to change temperature.'
                : 'Temperature control disabled while the experiment is running.',
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

  Widget _buildHeader(Color temperatureColor) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                temperatureColor.withValues(alpha: 0.8),
                temperatureColor,
              ],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.thermostat,
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
                'THERMOMETER',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Laboratory temperature control',
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

  Widget _buildThermometer(Color temperatureColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final normalized =
        _normalizedTemperature(widget.temperature);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: widget.enabled
              ? (details) {
            _updateFromPosition(
              details.localPosition,
              height,
            );
          }
              : null,
          onTapDown: widget.enabled
              ? (details) {
            _updateFromPosition(
              details.localPosition,
              height,
            );
          }
              : null,
          child: Center(
            child: SizedBox(
              width: 145,
              height: 310,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 12,
                    bottom: 40,
                    left: 45,
                    child: Container(
                      width: 45,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.grey.shade200,
                            Colors.grey.shade500,
                            Colors.grey.shade200,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.grey.shade700,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.18,
                            ),
                            blurRadius: 10,
                            offset: const Offset(2, 5),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    top: 28,
                    bottom: 56,
                    left: 59,
                    child: Container(
                      width: 17,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 20,
                    child: Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            temperatureColor,
                            temperatureColor.withValues(
                              alpha: 0.85,
                            ),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.grey.shade700,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: temperatureColor.withValues(
                              alpha: 0.35,
                            ),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 59,
                    left: 59,
                    child: AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 250,
                      ),
                      width: 17,
                      height: 200 * normalized,
                      decoration: BoxDecoration(
                        color: temperatureColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: temperatureColor.withValues(
                              alpha: 0.4,
                            ),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    left: 10,
                    top: 22,
                    bottom: 54,
                    child: _buildScaleMarks(),
                  ),

                  if (widget.optimumTemperature != null)
                    _buildOptimumMarker(
                      widget.optimumTemperature!,
                    ),

                  Positioned(
                    bottom: 0,
                    child: Text(
                      '°C',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: temperatureColor,
                      ),
                    ),
                  ),

                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      final glow =
                          0.15 +
                              (_animationController.value * 0.15);

                      return Positioned(
                        bottom: 85,
                        child: Container(
                          width: 27,
                          height: 27,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(
                              alpha: glow,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScaleMarks() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        6,
            (index) {
          final value = widget.maximum -
              ((_range / 5) * index);

          return Row(
            children: [
              Text(
                value.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 9,
                  color: EVLabColors.textLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 13,
                height: 1,
                color: Colors.grey,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOptimumMarker(double optimum) {
    final normalized = _normalizedTemperature(optimum);

    return Positioned(
      left: 91,
      bottom: 59 + (200 * normalized) - 7,
      child: Row(
        children: [
          Container(
            width: 15,
            height: 2,
            color: Colors.green.shade700,
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.green.shade700,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              'OPT ${optimum.toStringAsFixed(0)}°',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 7,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureEnvironment(Color color) {
    return Center(
      child: SizedBox(
        height: 245,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.science,
              size: 42,
              color: color,
            ),
            const SizedBox(height: 15),
            Text(
              '${widget.temperature.toStringAsFixed(1)}°C',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _temperatureDescription(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 22,
                    color: EVLabColors.textMedium,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'TOUCH & DRAG',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: EVLabColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitalDisplay(Color color) {
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
            Icons.device_thermostat,
            color: Color(0xFF8DFFB0),
            size: 21,
          ),
          const SizedBox(width: 10),
          const Text(
            'TEMP',
            style: TextStyle(
              color: Color(0xFFB8C8BF),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            '${widget.temperature.toStringAsFixed(1)} °C',
            style: const TextStyle(
              color: Color(0xFF8DFFB0),
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.thermostat_auto,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            _temperatureDescription(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureScale(Color color) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final normalized =
            _normalizedTemperature(widget.temperature);

            return SizedBox(
              height: 24,
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
                            Color(0xFF2196F3),
                            Color(0xFF00ACC1),
                            Color(0xFF43A047),
                            Color(0xFFFFB300),
                            Color(0xFFFF7043),
                            Color(0xFFD32F2F),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Positioned(
                    left: ((normalized *
                        constraints.maxWidth) -
                        5)
                        .clamp(
                      0.0,
                      constraints.maxWidth - 10,
                    )
                        .toDouble(),
                    top: 1,
                    child: Container(
                      width: 10,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: color,
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
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${widget.minimum.toStringAsFixed(0)}°',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${widget.maximum.toStringAsFixed(0)}°',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
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