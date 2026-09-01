// lib/data/enzyme_data.dart

import 'package:evlab/models/enzyme.dart';
import 'package:evlab/models/inhibitor.dart';

/// ===============================================================
/// EV-LAB ENZYME DATABASE
/// ===============================================================
///
/// Contains the enzyme information and simulation reference data
/// used by the EV-LAB Virtual Enzyme Laboratory.
///
/// Enzymes:
/// 1. Amylase
/// 2. Catalase
/// 3. Lipase
///
/// Activity values are relative simulation/reference values.
/// They are NOT direct measurements from a physical laboratory.
/// ===============================================================

final List<Enzyme> enzymes = [

  // =============================================================
  // AMYLASE
  // =============================================================

  Enzyme(
    name: 'Amylase',

    classification: 'Hydrolase',

    substrate: 'Soluble starch',

    products:
    'Maltose, maltotriose, and smaller oligosaccharides',

    location:
    'Salivary glands and pancreas',

    optimumPH: '7.0',

    optimumTemperature: '37°C',

    description:
    'Amylase is a hydrolase enzyme that catalyzes the '
        'hydrolysis of internal alpha-1,4 glycosidic bonds in '
        'starch, producing smaller carbohydrates such as maltose, '
        'maltotriose, and oligosaccharides.',

    image: '',

    // -------------------------------------------------------------
    // INTERACTIVE 3D MODEL
    // -------------------------------------------------------------

    model3D: 'assets/models/amylase.glb',

    modelDescription:
    'Interactive three-dimensional representation of an '
        'amylase protein. Rotate and zoom the model to explore '
        'the molecular structure of the enzyme responsible for '
        'starch hydrolysis.',

    // -------------------------------------------------------------
    // MICHAELIS-MENTEN PARAMETERS
    // -------------------------------------------------------------

    km: 5.1,

    vmax: 116.28,

    vmaxUnit: 'µM/min/mL',

    // -------------------------------------------------------------
    // TEMPERATURE ACTIVITY
    // -------------------------------------------------------------
    //
    // Values represent relative activity.
    //
    // 1.00 = maximum reference activity
    // Values below 1.00 = reduced relative activity
    // -------------------------------------------------------------

    temperatureActivity: {
      20.0: 0.45,
      25.0: 0.65,
      30.0: 0.82,
      35.0: 0.94,
      37.0: 1.00,
      40.0: 0.98,
      45.0: 0.90,
      50.0: 0.75,
      55.0: 0.55,
      60.0: 0.35,
      70.0: 0.12,
    },

    // -------------------------------------------------------------
    // pH ACTIVITY
    // -------------------------------------------------------------

    phActivity: {
      5.0: 0.30,
      6.0: 0.65,
      6.5: 0.85,
      7.0: 1.00,
      7.5: 0.97,
      8.0: 0.91,
      8.5: 0.82,
      9.0: 0.70,
      10.0: 0.45,
    },

    // -------------------------------------------------------------
    // INHIBITORS
    // -------------------------------------------------------------

    inhibitors: InhibitorData.inhibitors,
  ),

  // =============================================================
  // CATALASE
  // =============================================================

  Enzyme(
    name: 'Catalase',

    classification: 'Oxidoreductase',

    substrate: 'Hydrogen peroxide (H₂O₂)',

    products:
    'Water (H₂O) and oxygen (O₂)',

    location:
    'Most aerobic living cells, especially peroxisomes',

    optimumPH: '7.0',

    optimumTemperature: '25°C',

    description:
    'Catalase is an oxidoreductase enzyme that rapidly '
        'catalyzes the decomposition of hydrogen peroxide into '
        'water and molecular oxygen, helping protect cells from '
        'oxidative damage.',

    image: '',

    // -------------------------------------------------------------
    // INTERACTIVE 3D MODEL
    // -------------------------------------------------------------

    model3D: 'assets/models/catalase_color.glb',

    modelDescription:
    'Interactive three-dimensional representation of a '
        'catalase protein. Rotate and zoom the model to examine '
        'the three-dimensional organization of the enzyme.',

    // -------------------------------------------------------------
    // MICHAELIS-MENTEN PARAMETERS
    // -------------------------------------------------------------

    km: 25.0,

    vmax: 100.0,

    vmaxUnit: 'relative units/min',

    // -------------------------------------------------------------
    // TEMPERATURE ACTIVITY
    // -------------------------------------------------------------

    temperatureActivity: {
      5.0: 0.35,
      10.0: 0.55,
      15.0: 0.72,
      20.0: 0.90,
      25.0: 1.00,
      30.0: 0.95,
      35.0: 0.86,
      40.0: 0.70,
      45.0: 0.50,
      50.0: 0.28,
      55.0: 0.12,
    },

    // -------------------------------------------------------------
    // pH ACTIVITY
    // -------------------------------------------------------------

    phActivity: {
      4.0: 0.18,
      5.0: 0.35,
      6.0: 0.65,
      6.5: 0.85,
      7.0: 1.00,
      7.5: 0.98,
      8.0: 0.95,
      8.5: 0.86,
      9.0: 0.75,
      10.0: 0.45,
      11.0: 0.20,
    },

    // -------------------------------------------------------------
    // INHIBITORS
    // -------------------------------------------------------------

    inhibitors: InhibitorData.inhibitors,
  ),

  // =============================================================
  // LIPASE
  // =============================================================

  Enzyme(
    name: 'Lipase',

    classification: 'Hydrolase',

    substrate: 'p-Nitrophenyl palmitate (pNPP)',

    products:
    'p-Nitrophenol and fatty-acid products',

    location:
    'Pancreas and other biological tissues',

    optimumPH: '8.0',

    optimumTemperature: '37°C',

    description:
    'Lipase is a hydrolase enzyme that catalyzes the '
        'hydrolysis of ester bonds in lipid substrates. In this '
        'virtual experiment, p-nitrophenyl palmitate is used as '
        'the model substrate.',

    image: '',

    // -------------------------------------------------------------
    // INTERACTIVE 3D MODEL
    // -------------------------------------------------------------

    model3D: 'assets/models/lipase_color.glb',

    modelDescription:
    'Interactive three-dimensional representation of a '
        'lipase protein. Rotate and zoom the molecular structure '
        'to explore the enzyme responsible for lipid hydrolysis.',

    // -------------------------------------------------------------
    // MICHAELIS-MENTEN PARAMETERS
    // -------------------------------------------------------------

    km: 0.104,

    vmax: 3.58,

    vmaxUnit: 'U/mg',

    // -------------------------------------------------------------
    // TEMPERATURE ACTIVITY
    // -------------------------------------------------------------

    temperatureActivity: {
      15.0: 0.45,
      20.0: 0.60,
      25.0: 0.75,
      30.0: 0.88,
      35.0: 0.97,
      37.0: 1.00,
      40.0: 0.96,
      45.0: 0.82,
      50.0: 0.60,
      55.0: 0.35,
    },

    // -------------------------------------------------------------
    // pH ACTIVITY
    // -------------------------------------------------------------

    phActivity: {
      4.0: 0.18,
      5.0: 0.35,
      6.0: 0.60,
      7.0: 0.84,
      7.5: 0.94,
      8.0: 1.00,
      8.5: 0.97,
      9.0: 0.91,
      10.0: 0.70,
      11.0: 0.42,
    },

    // -------------------------------------------------------------
    // INHIBITORS
    // -------------------------------------------------------------

    inhibitors: InhibitorData.inhibitors,
  ),
];


// ===============================================================
// HELPER FUNCTIONS
// ===============================================================

/// Finds an enzyme by name.
///
/// Example:
/// final enzyme = getEnzymeByName('Catalase');

Enzyme? getEnzymeByName(String name) {
  for (final enzyme in enzymes) {
    if (enzyme.name.toLowerCase() == name.toLowerCase()) {
      return enzyme;
    }
  }

  return null;
}


/// Returns the default enzyme.
///
/// Currently the first enzyme in the database is used.

Enzyme getDefaultEnzyme() {
  return enzymes.first;
}


/// Returns a list containing all enzyme names.
///
/// Useful for dropdowns, selection cards, and menus.

List<String> getEnzymeNames() {
  return enzymes
      .map((enzyme) => enzyme.name)
      .toList();
}