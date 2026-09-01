// lib/screens/enzyme_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import 'package:evlab/models/enzyme.dart';
import 'package:evlab/theme/app_theme.dart';
import 'package:evlab/screens/virtual_lab_screen.dart';

class EnzymeDetailScreen extends StatefulWidget {
  final Enzyme enzyme;

  const EnzymeDetailScreen({
    super.key,
    required this.enzyme,
  });

  @override
  State<EnzymeDetailScreen> createState() =>
      _EnzymeDetailScreenState();
}

class _EnzymeDetailScreenState
    extends State<EnzymeDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  Enzyme get enzyme => widget.enzyme;

  // ============================================================
  // 3D MODEL CONFIGURATION
  // ============================================================

  String get enzymeModelPath {
    switch (enzyme.name.toLowerCase().trim()) {
      case 'amylase':
        return 'assets/models/amylase.glb';

      case 'catalase':
        return 'assets/models/catalase.glb';

      case 'lipase':
        return 'assets/models/lipase.glb';

      default:
        return '';
    }
  }

  bool get has3DModel => enzymeModelPath.isNotEmpty;

  String get modelDescription {
    switch (enzyme.name.toLowerCase().trim()) {
      case 'amylase':
        return 'Interactive 3D structure of amylase. Rotate and zoom to explore the enzyme structure.';

      case 'catalase':
        return 'Interactive 3D structure of catalase. Rotate and zoom to explore the enzyme structure.';

      case 'lipase':
        return 'Interactive 3D structure of lipase. Rotate and zoom to explore the enzyme structure.';

      default:
        return 'Interactive 3D enzyme structure.';
    }
  }

  // ============================================================
  // INITIALIZATION
  // ============================================================

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // OPEN VIRTUAL LAB
  // ============================================================

  void _openVirtualLab() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VirtualLabScreen(
          enzyme: enzyme,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Enzyme Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          18,
          10,
          18,
          35,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // HERO
            // ==================================================

            _buildHero(),

            const SizedBox(height: 22),

            // ==================================================
            // 3D MOLECULAR STRUCTURE
            // ==================================================

            _build3DStructureSection(),

            const SizedBox(height: 28),

            // ==================================================
            // QUICK FACTS
            // ==================================================

            _buildQuickFacts(),

            const SizedBox(height: 28),

            // ==================================================
            // DESCRIPTION
            // ==================================================

            _sectionTitle(
              'Meet This Enzyme',
              'Get to know its biological role and function.',
            ),

            const SizedBox(height: 12),

            _buildDescriptionCard(),

            const SizedBox(height: 25),

            // ==================================================
            // REACTION
            // ==================================================

            _sectionTitle(
              'How It Works',
              'Understand what this enzyme acts on and produces.',
            ),

            const SizedBox(height: 12),

            _buildReactionCard(),

            const SizedBox(height: 25),

            // ==================================================
            // CONDITIONS
            // ==================================================

            _sectionTitle(
              'Optimal Conditions',
              'Conditions associated with the enzyme\'s highest activity.',
            ),

            const SizedBox(height: 12),

            _buildConditions(),

            const SizedBox(height: 25),

            // ==================================================
            // LOCATION
            // ==================================================

            _sectionTitle(
              'Biological Location',
              'Where this enzyme can be found or functions.',
            ),

            const SizedBox(height: 12),

            _buildLocationCard(),

            const SizedBox(height: 28),

            // ==================================================
            // LEARNING TIP
            // ==================================================

            _buildLearningTip(),

            const SizedBox(height: 25),

            // ==================================================
            // VIRTUAL LAB
            // ==================================================

            _buildSimulationCard(),

            const SizedBox(height: 15),

            // ==================================================
            // BACK
            // ==================================================

            _buildBackButton(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHero() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final animation = Curves.easeOutCubic.transform(
          _animationController.value,
        );

        return Opacity(
          opacity: animation,
          child: Transform.translate(
            offset: Offset(
              0,
              30 * (1 - animation),
            ),
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: EVLabGradients.primary,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: EVLabColors.emerald.withValues(
                alpha: 0.22,
              ),
              blurRadius: 20,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Column(
          children: [
            Hero(
              tag: 'enzyme_${enzyme.name}',
              child: Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.18,
                  ),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: const Icon(
                  Icons.biotech_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              enzyme.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 29,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 7),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.16,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                enzyme.classification,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'ENZYME DISCOVERY',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 3D MOLECULAR STRUCTURE
  // ============================================================

  Widget _build3DStructureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          '3D Molecular Structure',
          'Explore the three-dimensional structure of this enzyme.',
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(23),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.045,
                ),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: Column(
              children: [
                // ==================================================
                // 3D VIEWER
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 330,
                  child: has3DModel
                      ? ModelViewer(
                    src: enzymeModelPath,
                    alt: modelDescription,
                    backgroundColor:
                    const Color(0xFFF3F8F4),

                    // Allow the user to rotate the model.
                    cameraControls: true,

                    // Automatically rotate when not being touched.
                    autoRotate: true,

                    // Allow zooming.
                    disableZoom: false,

                    // Disable augmented reality.
                    ar: false,

                    // Model shadow.
                    shadowIntensity: 0.8,

                    // Softness of the shadow.
                    shadowSoftness: 0.8,
                  )
                      : _buildMissingModel(),
                ),

                // ==================================================
                // MODEL INFORMATION
                // ==================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    16,
                    18,
                    18,
                  ),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color:
                              EVLabColors.emerald.withValues(
                                alpha: 0.11,
                              ),
                              borderRadius:
                              BorderRadius.circular(13),
                            ),
                            child: const Icon(
                              Icons.view_in_ar_rounded,
                              color: EVLabColors.emerald,
                              size: 23,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${enzyme.name} Structure',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                    FontWeight.bold,
                                    color:
                                    EVLabColors.textDark,
                                  ),
                                ),

                                const SizedBox(height: 3),

                                const Text(
                                  'Interactive molecular model',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color:
                                    EVLabColors.textMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: EVLabColors.background,
                          borderRadius:
                          BorderRadius.circular(13),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.touch_app_rounded,
                              size: 19,
                              color: EVLabColors.emerald,
                            ),

                            SizedBox(width: 9),

                            Expanded(
                              child: Text(
                                'Drag to rotate • Pinch to zoom • Explore the molecular shape',
                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                  EVLabColors.textMedium,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MISSING 3D MODEL
  // ============================================================

  Widget _buildMissingModel() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF3F8F4),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: EVLabColors.emerald.withValues(
                    alpha: 0.10,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.biotech_outlined,
                  color: EVLabColors.emerald,
                  size: 36,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                '${enzyme.name} 3D Model',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: EVLabColors.textDark,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'A 3D structure file has not been added '
                    'to the app assets yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: EVLabColors.textMedium,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // QUICK FACTS
  // ============================================================

  Widget _buildQuickFacts() {
    return Row(
      children: [
        Expanded(
          child: _quickFact(
            icon: Icons.category_rounded,
            title: 'CLASS',
            value: enzyme.classification,
            color: EVLabColors.purple,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _quickFact(
            icon: Icons.science_rounded,
            title: 'SUBSTRATE',
            value: enzyme.substrate,
            color: EVLabColors.blue,
          ),
        ),
      ],
    );
  }

  Widget _quickFact({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.035,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.12,
              ),
              borderRadius:
              BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: color,
              size: 23,
            ),
          ),

          const SizedBox(height: 11),

          Text(
            title,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: EVLabColors.textLight,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: EVLabColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
      String title,
      String subtitle,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: EVLabColors.textDark,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: EVLabColors.textMedium,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DESCRIPTION
  // ============================================================

  Widget _buildDescriptionCard() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(
                Icons.info_outline_rounded,
                EVLabColors.emerald,
              ),

              const SizedBox(width: 12),

              const Text(
                'What is it?',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: EVLabColors.textDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            enzyme.description,
            style: const TextStyle(
              color: EVLabColors.textMedium,
              height: 1.6,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REACTION
  // ============================================================

  Widget _buildReactionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: EVLabGradients.blue,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: EVLabColors.blue.withValues(
              alpha: 0.18,
            ),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'ENZYME REACTION',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.3,
            ),
          ),

          const SizedBox(height: 17),

          Row(
            children: [
              Expanded(
                child: _reactionItem(
                  icon: Icons.science_rounded,
                  label: 'SUBSTRATE',
                  value: enzyme.substrate,
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),

              Expanded(
                child: _reactionItem(
                  icon: Icons.auto_awesome_rounded,
                  label: 'PRODUCT',
                  value: enzyme.products,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Text(
            'The enzyme helps the reaction occur more efficiently '
                'without being consumed by the reaction.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reactionItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.13,
        ),
        borderRadius:
        BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 25,
          ),

          const SizedBox(height: 7),

          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONDITIONS
  // ============================================================

  Widget _buildConditions() {
    return _whiteCard(
      child: Column(
        children: [
          _conditionTile(
            icon: Icons.thermostat_rounded,
            title: 'Optimum Temperature',
            value: enzyme.optimumTemperature,
            color: EVLabColors.orange,
          ),

          const Divider(height: 24),

          _conditionTile(
            icon: Icons.water_drop_rounded,
            title: 'Optimum pH',
            value: enzyme.optimumPH,
            color: EVLabColors.blue,
          ),
        ],
      ),
    );
  }

  Widget _conditionTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(
              alpha: 0.12,
            ),
            borderRadius:
            BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color: color,
            size: 25,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: EVLabColors.textMedium,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: EVLabColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LOCATION
  // ============================================================

  Widget _buildLocationCard() {
    return _whiteCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: EVLabColors.pink.withValues(
                alpha: 0.12,
              ),
              borderRadius:
              BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: EVLabColors.pink,
              size: 27,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'WHERE IS IT FOUND?',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: EVLabColors.textLight,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  enzyme.location,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: EVLabColors.textDark,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LEARNING TIP
  // ============================================================

  Widget _buildLearningTip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: EVLabColors.yellow.withValues(
          alpha: 0.13,
        ),
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: EVLabColors.yellow.withValues(
            alpha: 0.35,
          ),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_rounded,
            color: EVLabColors.orange,
            size: 27,
          ),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'RESEARCHER TIP',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: EVLabColors.orange,
                    letterSpacing: 1,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Enzymes work best under particular conditions. '
                      'Changing temperature or pH can affect their '
                      'structure and activity.',
                  style: TextStyle(
                    fontSize: 12,
                    color: EVLabColors.textDark,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SIMULATION
  // ============================================================

  Widget _buildSimulationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: EVLabGradients.orange,
        borderRadius:
        BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: EVLabColors.orange.withValues(
              alpha: 0.20,
            ),
            blurRadius: 17,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.18,
              ),
              borderRadius:
              BorderRadius.circular(19),
            ),
            child: const Icon(
              Icons.science_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),

          const SizedBox(height: 13),

          const Text(
            'READY TO EXPERIMENT?',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Enter the Virtual Laboratory',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Change experimental conditions and observe '
                'how enzyme activity responds.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 17),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _openVirtualLab,
              icon: const Icon(
                Icons.play_arrow_rounded,
              ),
              label: const Text(
                'START SIMULATION',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor:
                EVLabColors.orange,
                elevation: 0,
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BACK BUTTON
  // ============================================================

  Widget _buildBackButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back_rounded,
        ),
        label: const Text(
          'BACK TO ENZYME LIBRARY',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor:
          EVLabColors.emeraldDark,
          side: const BorderSide(
            color: EVLabColors.emerald,
          ),
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // REUSABLE WHITE CARD
  // ============================================================

  Widget _whiteCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(21),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.035,
            ),
            blurRadius: 11,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // ============================================================
  // ICON BOX
  // ============================================================

  Widget _iconBox(
      IconData icon,
      Color color,
      ) {
    return Container(
      width: 43,
      height: 43,
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.12,
        ),
        borderRadius:
        BorderRadius.circular(13),
      ),
      child: Icon(
        icon,
        color: color,
        size: 23,
      ),
    );
  }
}