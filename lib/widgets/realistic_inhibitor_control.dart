import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/inhibitor.dart';
import '../../theme/app_theme.dart';

class RealisticInhibitorControl extends StatefulWidget {
  final InhibitionType selectedType;
  final double concentration;
  final double minimum;
  final double maximum;
  final double step;
  final String unit;
  final bool enabled;

  final ValueChanged<InhibitionType> onTypeChanged;
  final ValueChanged<double> onConcentrationChanged;

  const RealisticInhibitorControl({
    super.key,
    required this.selectedType,
    required this.concentration,
    required this.minimum,
    required this.maximum,
    required this.step,
    required this.unit,
    required this.enabled,
    required this.onTypeChanged,
    required this.onConcentrationChanged,
  });

  @override
  State<RealisticInhibitorControl> createState() =>
      _RealisticInhibitorControlState();
}

class _RealisticInhibitorControlState
    extends State<RealisticInhibitorControl>
    with TickerProviderStateMixin {
  late AnimationController _dropController;
  late AnimationController _bubbleController;

  bool _isDispensing = false;
  int _dropCount = 0;

  @override
  void initState() {
    super.initState();

    _dropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _dropController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  String _typeName() {
    switch (widget.selectedType) {
      case InhibitionType.competitive:
        return 'Competitive';

      case InhibitionType.noncompetitive:
        return 'Noncompetitive';

      case InhibitionType.uncompetitive:
        return 'Uncompetitive';

      case InhibitionType.mixed:
        return 'Mixed';

      case InhibitionType.none:
        return 'None';
    }
  }

  String _typeDescription() {
    switch (widget.selectedType) {
      case InhibitionType.competitive:
        return 'Competes with substrate for the enzyme active site.';

      case InhibitionType.noncompetitive:
        return 'Reduces effective Vmax while ideal Km remains unchanged.';

      case InhibitionType.uncompetitive:
        return 'Binds to the enzyme-substrate complex and lowers apparent Km and Vmax.';

      case InhibitionType.mixed:
        return 'Binds with different affinities to free enzyme and enzyme-substrate complex.';

      case InhibitionType.none:
        return 'No inhibitor is added to the reaction.';
    }
  }

  Color _typeColor() {
    switch (widget.selectedType) {
      case InhibitionType.competitive:
        return const Color(0xFFE65100);

      case InhibitionType.noncompetitive:
        return const Color(0xFF8E24AA);

      case InhibitionType.uncompetitive:
        return const Color(0xFF00838F);

      case InhibitionType.mixed:
        return const Color(0xFF3949AB);

      case InhibitionType.none:
        return EVLabColors.emeraldDark;
    }
  }

  void _dispense() {
    if (!widget.enabled) return;

    if (widget.selectedType == InhibitionType.none) {
      return;
    }

    if (widget.concentration >= widget.maximum) {
      return;
    }

    final newValue = math.min(
      widget.maximum,
      widget.concentration + widget.step,
    );

    setState(() {
      _isDispensing = true;
      _dropCount++;
    });

    widget.onConcentrationChanged(
      double.parse(newValue.toStringAsFixed(3)),
    );

    _dropController.forward(from: 0).then((_) {
      if (!mounted) return;

      setState(() {
        _isDispensing = false;
      });
    });
  }

  void _removeDose() {
    if (!widget.enabled) return;

    if (widget.concentration <= widget.minimum) {
      return;
    }

    final newValue = math.max(
      widget.minimum,
      widget.concentration - widget.step,
    );

    widget.onConcentrationChanged(
      double.parse(newValue.toStringAsFixed(3)),
    );

    if (_dropCount > 0) {
      setState(() {
        _dropCount--;
      });
    }
  }

  void _reset() {
    if (!widget.enabled) return;

    widget.onConcentrationChanged(widget.minimum);

    setState(() {
      _dropCount = 0;
      _isDispensing = false;
    });

    _dropController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: typeColor.withValues(alpha: 0.20),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: typeColor.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(typeColor),

          const SizedBox(height: 20),

          _buildInhibitorSelector(typeColor),

          const SizedBox(height: 20),

          SizedBox(
            height: 350,
            child: _buildLaboratoryScene(typeColor),
          ),

          const SizedBox(height: 15),

          _buildDigitalReading(typeColor),

          const SizedBox(height: 14),

          _buildDescription(typeColor),

          const SizedBox(height: 18),

          _buildDoseControls(typeColor),

          const SizedBox(height: 14),

          _buildInstruction(typeColor),
        ],
      ),
    );
  }

  Widget _buildHeader(Color typeColor) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                typeColor.withValues(alpha: 0.75),
                typeColor,
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: typeColor.withValues(alpha: 0.25),
                blurRadius: 9,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.colorize,
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
                'INHIBITOR STATION',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Micropipette dispensing system',
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

  Widget _buildInhibitorSelector(Color typeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SELECT INHIBITION MECHANISM',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: EVLabColors.textMedium,
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 10),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _typeButton(
                InhibitionType.competitive,
                'Competitive',
                Icons.compare_arrows,
              ),
              const SizedBox(width: 8),
              _typeButton(
                InhibitionType.noncompetitive,
                'Noncompetitive',
                Icons.block,
              ),
              const SizedBox(width: 8),
              _typeButton(
                InhibitionType.uncompetitive,
                'Uncompetitive',
                Icons.link,
              ),
              const SizedBox(width: 8),
              _typeButton(
                InhibitionType.mixed,
                'Mixed',
                Icons.merge_type,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _typeButton(
      InhibitionType type,
      String label,
      IconData icon,
      ) {
    final selected = widget.selectedType == type;

    Color color;

    switch (type) {
      case InhibitionType.competitive:
        color = const Color(0xFFE65100);
        break;

      case InhibitionType.noncompetitive:
        color = const Color(0xFF8E24AA);
        break;

      case InhibitionType.uncompetitive:
        color = const Color(0xFF00838F);
        break;

      case InhibitionType.mixed:
        color = const Color(0xFF3949AB);
        break;

      case InhibitionType.none:
        color = Colors.grey;
        break;
    }

    return GestureDetector(
      onTap: widget.enabled
          ? () {
        widget.onTypeChanged(type);

        if (type == InhibitionType.none) {
          widget.onConcentrationChanged(
            widget.minimum,
          );
        }
      }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.12)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? color
                : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 17,
              color: selected
                  ? color
                  : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: selected
                    ? color
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLaboratoryScene(Color typeColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: 12,
              left: 20,
              right: 20,
              child: Container(
                height: 15,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),

            Positioned(
              bottom: 25,
              left: 30,
              child: _buildReactionTube(typeColor),
            ),

            Positioned(
              top: 5,
              right: 35,
              child: GestureDetector(
                onTap: widget.enabled
                    ? _dispense
                    : null,
                child: _buildDropper(typeColor),
              ),
            ),

            if (_isDispensing)
              Positioned(
                top: 130,
                right: 68,
                child: _buildAnimatedDrop(typeColor),
              ),

            Positioned(
              top: 145,
              left: 32,
              child: _buildMechanismCard(typeColor),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropper(Color typeColor) {
    return Transform.rotate(
      angle: -0.20,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 58,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey.shade200,
                  Colors.grey.shade600,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade800,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 8,
                  offset: const Offset(3, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'EV',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ),

          Container(
            width: 30,
            height: 95,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.18),
              border: Border.all(
                color: typeColor,
                width: 2,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(15),
              ),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: 0.75,
                child: Container(
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.65),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Container(
            width: 12,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.shade300,
                  Colors.grey.shade700,
                ],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
          ),

          Container(
            width: 8,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(5),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'TAP TO DISPENSE',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: typeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDrop(Color typeColor) {
    return AnimatedBuilder(
      animation: _dropController,
      builder: (context, child) {
        final progress = _dropController.value;

        return Transform.translate(
          offset: Offset(
            0,
            progress * 105,
          ),
          child: Opacity(
            opacity: progress < 0.85 ? 1 : 0,
            child: Container(
              width: 13,
              height: 18,
              decoration: BoxDecoration(
                color: typeColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                  bottom: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: typeColor.withValues(alpha: 0.35),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReactionTube(Color typeColor) {
    final concentrationRange =
        widget.maximum - widget.minimum;

    final normalized = concentrationRange <= 0
        ? 0.0
        : ((widget.concentration -
        widget.minimum) /
        concentrationRange)
        .clamp(0.0, 1.0)
        .toDouble();

    final liquidHeight =
        90 + (normalized * 65);

    return SizedBox(
      width: 150,
      height: 210,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 15,
            child: Container(
              width: 118,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),

          Positioned(
            bottom: 27,
            child: Container(
              width: 78,
              height: 165,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                border: Border.all(
                  color: Colors.blueGrey.shade400,
                  width: 3,
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(30),
                  top: Radius.circular(12),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 30,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 72,
              height: liquidHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    typeColor.withValues(alpha: 0.45),
                    typeColor.withValues(alpha: 0.85),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(27),
                ),
              ),
            ),
          ),

          AnimatedBuilder(
            animation: _bubbleController,
            builder: (context, child) {
              return Stack(
                children: List.generate(
                  4,
                      (index) {
                    final movement =
                        math.sin(
                          _bubbleController.value *
                              math.pi *
                              2 +
                              index,
                        ) *
                            5;

                    return Positioned(
                      bottom:
                      48 +
                          (index * 25) +
                          movement,
                      left: 32 + (index * 9),
                      child: Container(
                        width: 6,
                        height: 6,
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
              );
            },
          ),

          Positioned(
            bottom: 0,
            child: Text(
              'REACTION VESSEL',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: Colors.blueGrey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMechanismCard(Color typeColor) {
    return Container(
      width: 175,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: typeColor.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: typeColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _typeDescription(),
              style: const TextStyle(
                fontSize: 10,
                height: 1.35,
                color: EVLabColors.textMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitalReading(Color typeColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 15,
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
          Icon(
            Icons.science,
            color: Color.lerp(
              Colors.white,
              typeColor,
              0.65,
            ),
            size: 20,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                _typeName(),
                style: const TextStyle(
                  color: Color(0xFFB8C8BF),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'INHIBITOR',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '${widget.concentration.toStringAsFixed(3)} ${widget.unit}',
            style: TextStyle(
              color: Color.lerp(
                Colors.white,
                typeColor,
                0.75,
              ),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(Color typeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            Icons.biotech,
            color: typeColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            widget.selectedType == InhibitionType.none
                ? 'No inhibitor selected'
                : '$_typeName() inhibition active',
            style: TextStyle(
              color: typeColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoseControls(Color typeColor) {
    return Row(
      children: [
        _controlButton(
          Icons.remove,
          _removeDose,
          typeColor,
        ),

        Expanded(
          child: Column(
            children: [
              Text(
                '$_dropCount DOSE${_dropCount == 1 ? '' : 'S'}',
                style: TextStyle(
                  color: typeColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Added to reaction',
                style: TextStyle(
                  color: EVLabColors.textLight,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),

        _controlButton(
          Icons.refresh,
          _reset,
          typeColor,
        ),
      ],
    );
  }

  Widget _controlButton(
      IconData icon,
      VoidCallback callback,
      Color color,
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
                ? color
                : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildInstruction(Color typeColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.touch_app,
          size: 15,
          color: typeColor,
        ),
        const SizedBox(width: 5),
        Text(
          widget.selectedType == InhibitionType.none
              ? 'Select an inhibition mechanism first.'
              : 'Tap the micropipette to dispense inhibitor.',
          style: const TextStyle(
            fontSize: 11,
            color: EVLabColors.textLight,
          ),
        ),
      ],
    );
  }
}