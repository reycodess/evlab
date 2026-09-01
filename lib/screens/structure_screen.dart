import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../assets/enzyme_data.dart';

class StructureScreen extends StatefulWidget {
  const StructureScreen({super.key});

  @override
  State<StructureScreen> createState() => _StructureScreenState();
}

class _StructureScreenState extends State<StructureScreen> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    final e = enzymes[selected];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text('Enzyme 3D Structure'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Colors.white,
      ),

      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // ============================================================
          // 3D MODEL
          // ============================================================

          Container(
            height: 340,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,

            child: ModelViewer(
              key: ValueKey(e.model3D),
              src: e.model3D,
              alt: 'Interactive 3D model of ${e.name}',
              autoRotate: true,
              cameraControls: true,
              ar: false,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'Rotate • zoom • explore',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 18),

          // ============================================================
          // ENZYME SELECTOR
          // ============================================================

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              enzymes.length,
                  (i) {
                return ChoiceChip(
                  label: Text(enzymes[i].name),
                  selected: selected == i,
                  onSelected: (_) {
                    setState(() {
                      selected = i;
                    });
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 18),

          // ============================================================
          // ENZYME INFORMATION
          // ============================================================

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.name,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    e.classification,
                    style: const TextStyle(
                      color: Color(0xFF287D7D),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    e.modelDescription,
                    style: const TextStyle(
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    e.description,
                    style: const TextStyle(
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE8FAF5), Color(0xFFF2F7FF)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF12B8A6).withValues(alpha: .16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF12B8A6).withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.center_focus_strong_rounded,
                    color: Color(0xFF078A7C),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ACTIVE SITE FOCUS',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          color: Color(0xFF078A7C),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Explore the pocket where the substrate binds and the reaction is facilitated. The marker is an educational guide, not a residue-level structural measurement.',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ============================================================
          // SCIENTIFIC EXPLANATION
          // ============================================================

          const Text(
            'Enzyme structure matters',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'An enzyme’s three-dimensional structure helps form '
                'its active site and influences substrate binding '
                'and catalysis.',
            style: TextStyle(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}