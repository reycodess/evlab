import 'package:flutter/material.dart';

import 'package:evlab/assets/enzyme_data.dart';
import 'package:evlab/screens/enzyme_detail_screen.dart';
import 'package:evlab/theme/app_theme.dart';

class EnzymeLibraryScreen extends StatefulWidget {
  const EnzymeLibraryScreen({super.key});

  @override
  State<EnzymeLibraryScreen> createState() =>
      _EnzymeLibraryScreenState();
}

class _EnzymeLibraryScreenState
    extends State<EnzymeLibraryScreen>
    with SingleTickerProviderStateMixin {
  String search = '';
  String selectedCategory = 'All';

  late AnimationController _animationController;

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
  // FILTERING
  // ============================================================

  List<dynamic> get filteredEnzymes {
    final query = search.trim().toLowerCase();

    return enzymes.where((enzyme) {
      final matchesSearch =
          query.isEmpty ||
              enzyme.name.toLowerCase().contains(query) ||
              enzyme.classification.toLowerCase().contains(query) ||
              enzyme.substrate.toLowerCase().contains(query);

      final matchesCategory =
          selectedCategory == 'All' ||
              _getCategory(enzyme.classification) ==
                  selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  String _getCategory(String classification) {
    final value = classification.toLowerCase();

    if (value.contains('hydrolase')) {
      return 'Hydrolase';
    }

    if (value.contains('oxidoreductase')) {
      return 'Oxidoreductase';
    }

    if (value.contains('transferase')) {
      return 'Transferase';
    }

    if (value.contains('lyase')) {
      return 'Lyase';
    }

    if (value.contains('isomerase')) {
      return 'Isomerase';
    }

    if (value.contains('ligase')) {
      return 'Ligase';
    }

    return 'Other';
  }

  List<String> get categories {
    final values = <String>{'All'};

    for (final enzyme in enzymes) {
      values.add(
        _getCategory(enzyme.classification),
      );
    }

    return values.toList();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final results = filteredEnzymes;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text(
          'Enzyme Library',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: FadeTransition(
        opacity: CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOut,
        ),
        child: Column(
          children: [
            _buildHeader(),

            _buildSearchBar(),

            _buildCategoryFilters(),

            Expanded(
              child: results.isEmpty
                  ? _buildEmptyState()
                  : _buildEnzymeList(results),
            ),
          ],
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
      margin: const EdgeInsets.fromLTRB(
        16,
        10,
        16,
        8,
      ),
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: EVLabGradients.primary,
        borderRadius: BorderRadius.circular(25),
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
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.18,
              ),
              borderRadius:
              BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.biotech_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),

          const SizedBox(width: 15),

          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'ENZYME DATABASE',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Explore Enzymes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Discover what enzymes do and where they work.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.3,
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
  // SEARCH
  // ============================================================

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        5,
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            search = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search enzyme, class, or substrate...',
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: EVLabColors.emerald,
          ),

          suffixIcon: search.isNotEmpty
              ? IconButton(
            icon: const Icon(
              Icons.clear_rounded,
            ),
            onPressed: () {
              setState(() {
                search = '';
              });
            },
          )
              : null,

          filled: true,
          fillColor: Colors.white,

          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(17),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(17),
            borderSide: BorderSide.none,
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(17),
            borderSide: const BorderSide(
              color: EVLabColors.emerald,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY FILTER
  // ============================================================

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 55,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) =>
        const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected =
              category == selectedCategory;

          return ChoiceChip(
            label: Text(category),
            selected: selected,
            onSelected: (_) {
              setState(() {
                selectedCategory = category;
              });
            },
            selectedColor:
            EVLabColors.emerald,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: selected
                  ? Colors.white
                  : EVLabColors.textMedium,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            side: BorderSide(
              color: selected
                  ? EVLabColors.emerald
                  : const Color(0xFFE1E7EF),
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // ENZYME LIST
  // ============================================================

  Widget _buildEnzymeList(List<dynamic> results) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            18,
            3,
            18,
            8,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.science_outlined,
                size: 18,
                color: EVLabColors.emeraldDark,
              ),

              const SizedBox(width: 7),

              Text(
                '${results.length} enzyme${results.length == 1 ? '' : 's'} found',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: EVLabColors.textMedium,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            physics:
            const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              16,
              2,
              16,
              25,
            ),
            itemCount: results.length,
            itemBuilder: (context, index) {
              return _buildAnimatedCard(
                results[index],
                index,
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ANIMATED ENZYME CARD
  // ============================================================

  Widget _buildAnimatedCard(
      dynamic enzyme,
      int index,
      ) {
    final category =
    _getCategory(enzyme.classification);

    final color = _categoryColor(category);

    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: 0,
        end: 1,
      ),
      duration: Duration(
        milliseconds: 350 + (index * 70),
      ),
      curve: Curves.easeOutCubic,
      builder: (
          context,
          animation,
          child,
          ) {
        return Transform.translate(
          offset: Offset(
            0,
            20 * (1 - animation),
          ),
          child: Opacity(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: _buildEnzymeCard(
        enzyme,
        category,
        color,
      ),
    );
  }

  // ============================================================
  // ENZYME CARD
  // ============================================================

  Widget _buildEnzymeCard(
      dynamic enzyme,
      String category,
      Color color,
      ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(21),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.045,
            ),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius:
        BorderRadius.circular(21),
        child: InkWell(
          borderRadius:
          BorderRadius.circular(21),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    EnzymeDetailScreen(
                      enzyme: enzyme,
                    ),
              ),
            );
          },
          child: Padding(
            padding:
            const EdgeInsets.all(16),
            child: Row(
              children: [
                // ------------------------------------------------
                // ICON
                // ------------------------------------------------

                Hero(
                  tag:
                  'enzyme_${enzyme.name}',
                  child: Container(
                    width: 65,
                    height: 65,
                    decoration:
                    BoxDecoration(
                      gradient:
                      LinearGradient(
                        begin:
                        Alignment.topLeft,
                        end:
                        Alignment.bottomRight,
                        colors: [
                          color.withValues(
                            alpha: 0.18,
                          ),
                          color.withValues(
                            alpha: 0.07,
                          ),
                        ],
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        18,
                      ),
                    ),
                    child: Icon(
                      Icons.biotech_rounded,
                      color: color,
                      size: 32,
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // ------------------------------------------------
                // INFORMATION
                // ------------------------------------------------

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration:
                        BoxDecoration(
                          color:
                          color.withValues(
                            alpha: 0.10,
                          ),
                          borderRadius:
                          BorderRadius
                              .circular(
                            8,
                          ),
                        ),
                        child: Text(
                          category
                              .toUpperCase(),
                          style: TextStyle(
                            color: color,
                            fontSize: 9,
                            fontWeight:
                            FontWeight.bold,
                            letterSpacing:
                            0.7,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        enzyme.name,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold,
                          color:
                          EVLabColors.textDark,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        enzyme.classification,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color:
                          EVLabColors.textMedium,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Row(
                        children: [
                          const Icon(
                            Icons
                                .grain_rounded,
                            size: 14,
                            color:
                            EVLabColors.textLight,
                          ),

                          const SizedBox(
                            width: 4,
                          ),

                          Expanded(
                            child: Text(
                              enzyme.substrate,
                              maxLines: 1,
                              overflow:
                              TextOverflow
                                  .ellipsis,
                              style:
                              const TextStyle(
                                fontSize: 11,
                                color:
                                EVLabColors
                                    .textLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // ------------------------------------------------
                // ARROW
                // ------------------------------------------------

                Container(
                  width: 38,
                  height: 38,
                  decoration:
                  BoxDecoration(
                    color:
                    color.withValues(
                      alpha: 0.09,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons
                        .arrow_forward_rounded,
                    color: color,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY COLORS
  // ============================================================

  Color _categoryColor(String category) {
    switch (category) {
      case 'Hydrolase':
        return EVLabColors.blue;

      case 'Oxidoreductase':
        return EVLabColors.orange;

      case 'Transferase':
        return EVLabColors.purple;

      case 'Lyase':
        return EVLabColors.pink;

      case 'Isomerase':
        return EVLabColors.cyan;

      case 'Ligase':
        return EVLabColors.emeraldDark;

      default:
        return EVLabColors.emerald;
    }
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color:
                EVLabColors.emerald.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: EVLabColors.emerald,
                size: 45,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No Enzymes Found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: EVLabColors.textDark,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Try another enzyme name, classification, '
                  'or substrate.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: EVLabColors.textMedium,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 18),

            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  search = '';
                  selectedCategory = 'All';
                });
              },
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'CLEAR FILTERS',
              ),
            ),
          ],
        ),
      ),
    );
  }
}