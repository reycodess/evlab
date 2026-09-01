// lib/models/enzyme.dart

import 'inhibitor.dart';

/// Represents an enzyme used by the EV-LAB virtual laboratory.
///
/// The model contains:
/// - biological information about the enzyme
/// - Michaelis-Menten kinetic parameters
/// - temperature activity data
/// - pH activity data
/// - supported inhibition mechanisms
/// - optional interactive 3D molecular structure
class Enzyme {
  final String name;
  final String classification;

  /// Main substrate used by the simulation.
  final String substrate;

  /// Main products formed by the enzyme reaction.
  final String products;

  /// Biological location where the enzyme is commonly found.
  final String location;

  /// Optimum pH represented as text because some enzymes
  /// may have an optimum range.
  final String optimumPH;

  /// Optimum temperature represented as text because some
  /// enzymes may have an optimum range.
  final String optimumTemperature;

  final String description;

  /// Optional image path or asset name.
  final String image;

  /// Path to the interactive 3D molecular model.
  ///
  /// Example:
  /// assets/models/amylase.glb
  ///
  /// Leave this empty if no 3D model is available.
  final String model3D;

  /// Short description displayed alongside the 3D model.
  final String modelDescription;

  /// Michaelis constant (Km).
  ///
  /// The unit must correspond to the substrate concentration
  /// used by the simulation.
  final double km;

  /// Maximum reaction velocity.
  final double vmax;

  /// Unit displayed with Vmax.
  final String vmaxUnit;

  /// Relative activity values as a function of temperature.
  ///
  /// Values should normally be between 0.0 and 1.0.
  final Map<double, double> temperatureActivity;

  /// Relative activity values as a function of pH.
  ///
  /// Values should normally be between 0.0 and 1.0.
  final Map<double, double> phActivity;

  /// Inhibition mechanisms supported by this enzyme.
  ///
  /// These describe the mechanisms available in the simulation.
  final List<Inhibitor> inhibitors;

  const Enzyme({
    required this.name,
    required this.classification,
    required this.substrate,
    required this.products,
    required this.location,
    required this.optimumPH,
    required this.optimumTemperature,
    required this.description,
    required this.image,
    required this.model3D,
    required this.modelDescription,
    required this.km,
    required this.vmax,
    required this.vmaxUnit,
    required this.temperatureActivity,
    required this.phActivity,
    this.inhibitors = const [],
  });

  /// Returns true when a 3D molecular model is configured.
  bool get has3DModel => model3D.trim().isNotEmpty;

  /// Creates a copy of this enzyme with selected fields changed.
  Enzyme copyWith({
    String? name,
    String? classification,
    String? substrate,
    String? products,
    String? location,
    String? optimumPH,
    String? optimumTemperature,
    String? description,
    String? image,
    String? model3D,
    String? modelDescription,
    double? km,
    double? vmax,
    String? vmaxUnit,
    Map<double, double>? temperatureActivity,
    Map<double, double>? phActivity,
    List<Inhibitor>? inhibitors,
  }) {
    return Enzyme(
      name: name ?? this.name,
      classification: classification ?? this.classification,
      substrate: substrate ?? this.substrate,
      products: products ?? this.products,
      location: location ?? this.location,
      optimumPH: optimumPH ?? this.optimumPH,
      optimumTemperature:
      optimumTemperature ?? this.optimumTemperature,
      description: description ?? this.description,
      image: image ?? this.image,
      model3D: model3D ?? this.model3D,
      modelDescription:
      modelDescription ?? this.modelDescription,
      km: km ?? this.km,
      vmax: vmax ?? this.vmax,
      vmaxUnit: vmaxUnit ?? this.vmaxUnit,
      temperatureActivity:
      temperatureActivity ?? this.temperatureActivity,
      phActivity: phActivity ?? this.phActivity,
      inhibitors: inhibitors ?? this.inhibitors,
    );
  }

  /// Gets the configured inhibitor for a particular mechanism.
  Inhibitor? getInhibitor(InhibitionType type) {
    for (final inhibitor in inhibitors) {
      if (inhibitor.type == type) {
        return inhibitor;
      }
    }

    return null;
  }

  /// Checks whether this enzyme supports a particular
  /// inhibition mechanism.
  bool hasInhibitor(InhibitionType type) {
    return getInhibitor(type) != null;
  }

  @override
  String toString() {
    return 'Enzyme('
        'name: $name, '
        'classification: $classification, '
        'substrate: $substrate, '
        'km: $km, '
        'vmax: $vmax $vmaxUnit, '
        'model3D: $model3D'
        ')';
  }
}