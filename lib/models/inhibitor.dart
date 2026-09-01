// lib/models/inhibitor.dart

/// Types of enzyme inhibition supported by EV-LAB.
///
/// The mathematical model for each inhibition type is handled
/// by the VirtualLabScreen.
enum InhibitionType {
  none,
  competitive,
  noncompetitive,
  uncompetitive,
  mixed,
}

/// Represents an inhibitor model used by EV-LAB.
///
/// EV-LAB uses the dimensionless ratio [I]/Ki to represent
/// inhibitor strength.
///
/// [I]  = inhibitor concentration
/// [Ki] = inhibition constant
///
/// This allows the simulation to demonstrate the mathematical
/// behavior of different inhibition mechanisms without assuming
/// one universal Ki value for all enzymes.
class Inhibitor {
  final String name;
  final InhibitionType type;
  final String description;

  const Inhibitor({
    required this.name,
    required this.type,
    required this.description,
  });
}

/// Standard inhibition models available in EV-LAB.
///
/// These describe the mechanism being simulated rather than
/// claiming that every enzyme in EV-LAB is inhibited by the
/// same real-world chemical.
class InhibitorData {
  static const List<Inhibitor> inhibitors = [
    Inhibitor(
      name: 'No inhibitor',
      type: InhibitionType.none,
      description:
      'No inhibitor is present. The enzyme interacts normally '
          'with the substrate.',
    ),

    Inhibitor(
      name: 'Competitive inhibitor',
      type: InhibitionType.competitive,
      description:
      'A competitive inhibitor competes with the substrate '
          'for the enzyme active site. In the ideal model, '
          'apparent Km increases while Vmax remains unchanged.',
    ),

    Inhibitor(
      name: 'Pure noncompetitive inhibitor',
      type: InhibitionType.noncompetitive,
      description:
      'A pure noncompetitive inhibitor binds to free enzyme '
          'and the enzyme-substrate complex with equal affinity. '
          'In the ideal model, Vmax decreases while Km remains unchanged.',
    ),

    Inhibitor(
      name: 'Uncompetitive inhibitor',
      type: InhibitionType.uncompetitive,
      description:
      'An uncompetitive inhibitor binds to the enzyme-substrate '
          'complex. In the ideal model, both apparent Km and Vmax '
          'decrease.',
    ),

    Inhibitor(
      name: 'Mixed inhibitor',
      type: InhibitionType.mixed,
      description:
      'A mixed inhibitor can bind to both free enzyme and '
          'the enzyme-substrate complex with different affinities. '
          'Both apparent Km and Vmax can change.',
    ),
  ];

  /// Returns the inhibitor model associated with an inhibition type.
  static Inhibitor getByType(InhibitionType type) {
    return inhibitors.firstWhere(
          (inhibitor) => inhibitor.type == type,
      orElse: () => inhibitors.first,
    );
  }
}

/// Converts an inhibition type into a readable name.
String inhibitionTypeName(InhibitionType type) {
  switch (type) {
    case InhibitionType.none:
      return 'None';

    case InhibitionType.competitive:
      return 'Competitive';

    case InhibitionType.noncompetitive:
      return 'Noncompetitive';

    case InhibitionType.uncompetitive:
      return 'Uncompetitive';

    case InhibitionType.mixed:
      return 'Mixed';
  }
}