import 'package:flutter/material.dart';
import 'package:evlab/assets/enzyme_data.dart';
import 'package:evlab/theme/app_theme.dart';

import 'virtual_lab_screen.dart';

class EnzymeSelectionScreen extends StatelessWidget {
  const EnzymeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: EVLabColors.textDark,
        centerTitle: true,
        title: const Text(
          'Choose an Enzyme',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            18,
            10,
            18,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 24),

              const Text(
                'Available Enzymes',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: EVLabColors.textDark,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Select an enzyme to begin your virtual experiment.',
                style: TextStyle(
                  color: EVLabColors.textMedium,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 18),

              if (enzymes.isEmpty)
                _buildEmptyState()
              else
                ...List.generate(
                  enzymes.length,
                      (index) {
                    final enzyme = enzymes[index];

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 14,
                      ),
                      child: _buildEnzymeCard(
                        context,
                        enzyme,
                        index,
                      ),
                    );
                  },
                ),

              const SizedBox(height: 12),

              _buildScientificNote(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: EVLabGradients.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: EVLabColors.emerald.withValues(
              alpha: 0.20,
            ),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.biotech_rounded,
                color: Colors.white,
                size: 38,
              ),

              SizedBox(width: 12),

              Expanded(
                child: Text(
                  'Virtual Laboratory',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 14),

          Text(
            'Choose an enzyme and investigate how '
                'different conditions affect its activity.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ENZYME CARD
  // ============================================================

  Widget _buildEnzymeCard(
      BuildContext context,
      dynamic enzyme,
      int index,
      ) {
    final Color accentColor = _getAccentColor(index);
    final IconData enzymeIcon = _getEnzymeIcon(index);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VirtualLabScreen(
                enzyme: enzyme,
              ),
            ),
          );
        },
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: accentColor.withValues(
                alpha: 0.12,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.04,
                ),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: accentColor.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  enzymeIcon,
                  color: accentColor,
                  size: 32,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      enzyme.name,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: EVLabColors.textDark,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      enzyme.classification,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      enzyme.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: EVLabColors.textMedium,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        _infoChip(
                          Icons.water_drop_outlined,
                          'pH ${enzyme.optimumPH}',
                          accentColor,
                        ),
                        _infoChip(
                          Icons.thermostat_outlined,
                          enzyme.optimumTemperature,
                          accentColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withValues(
                    alpha: 0.10,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: accentColor,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INFO CHIP
  // ============================================================

  Widget _infoChip(
      IconData icon,
      String text,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),

          const SizedBox(width: 4),

          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ENZYME ICON
  // ============================================================

  IconData _getEnzymeIcon(int index) {
    switch (index) {
      case 0:
        return Icons.grain_rounded;

      case 1:
        return Icons.air_rounded;

      case 2:
        return Icons.water_drop_rounded;

      default:
        return Icons.biotech_rounded;
    }
  }

  // ============================================================
  // ACCENT COLOR
  // ============================================================

  Color _getAccentColor(int index) {
    switch (index) {
      case 0:
        return EVLabColors.emerald;

      case 1:
        return EVLabColors.blue;

      case 2:
        return EVLabColors.orange;

      default:
        return EVLabColors.purple;
    }
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.biotech_outlined,
            size: 65,
            color: EVLabColors.emerald,
          ),

          SizedBox(height: 15),

          Text(
            'No Enzymes Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: EVLabColors.textDark,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'There are currently no enzymes available '
                'for the virtual laboratory.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: EVLabColors.textMedium,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SCIENTIFIC NOTE
  // ============================================================

  Widget _buildScientificNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EVLabColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: EVLabColors.emerald.withValues(
            alpha: 0.15,
          ),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: EVLabColors.emeraldDark,
            size: 21,
          ),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'Select an enzyme to explore its activity '
                  'under different temperature, pH, substrate, '
                  'and inhibitor conditions.',
              style: TextStyle(
                color: EVLabColors.textMedium,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}