import 'package:flutter/material.dart';

/// Educational schematic of the enzyme catalytic cycle.
/// It is intentionally not drawn to molecular scale; the labels describe the
/// biological sequence rather than claiming a molecular-dynamics rendering.
class EnzymeMechanismIllustration extends StatelessWidget {
  final String enzymeName;
  final String substrateName;
  final String productName;
  final bool inhibitorActive;

  const EnzymeMechanismIllustration({
    super.key,
    required this.enzymeName,
    required this.substrateName,
    required this.productName,
    this.inhibitorActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final stages = [
      _Stage('E', enzymeName, const Color(0xFF168B78)),
      _Stage('E + S', 'Substrate binds', const Color(0xFF3E8ED0)),
      _Stage('ES', 'Enzyme–substrate complex', const Color(0xFF7B61A8)),
      _Stage('E + P', 'Products released', const Color(0xFFE08A25)),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E8E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Enzyme reaction mechanism', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 3),
          Text('$substrateName → $productName', style: const TextStyle(color: Colors.black54, fontSize: 11)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < stages.length; i++) ...[
                  _stageCard(stages[i]),
                  if (i != stages.length - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(Icons.arrow_forward, size: 18, color: Colors.black38),
                    ),
                ],
              ],
            ),
          ),
          if (inhibitorActive) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.block_outlined, color: Color(0xFFD94B4B), size: 18),
                  SizedBox(width: 7),
                  Expanded(child: Text('Inhibitor present: the selected kinetic model reduces the reaction rate.', style: TextStyle(fontSize: 10.5, height: 1.3))),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          const Text('Schematic only — not to scale and not a molecular-dynamics trajectory.', style: TextStyle(fontSize: 10, color: Colors.black45)),
        ],
      ),
    );
  }

  Widget _stageCard(_Stage stage) {
    return SizedBox(
      width: 104,
      child: Column(
        children: [
          Container(
            height: 58,
            decoration: BoxDecoration(
              color: stage.color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: stage.color.withValues(alpha: .45)),
            ),
            child: Center(
              child: Text(stage.symbol, style: TextStyle(color: stage.color, fontWeight: FontWeight.w900, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 5),
          Text(stage.label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Stage {
  final String symbol;
  final String label;
  final Color color;

  const _Stage(this.symbol, this.label, this.color);
}
