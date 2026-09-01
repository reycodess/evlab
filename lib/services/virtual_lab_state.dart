import 'package:flutter/foundation.dart';

/// Shared state for an interactive Virtual Lab.
///
/// This service is intentionally independent of VirtualLabScreen so the
/// existing large screen can keep its current UI and navigation.
class VirtualLabState extends ChangeNotifier {
  double temperature;
  double ph;
  double substrate;
  bool inhibitor;
  bool mixing;

  bool thermometerCollected;
  bool phMeterCollected;
  bool pipetteCollected;
  bool stirrerCollected;
  bool inhibitorCollected;

  VirtualLabState({
    this.temperature = 37.0,
    this.ph = 7.0,
    this.substrate = 1.0,
    this.inhibitor = false,
    this.mixing = false,
    this.thermometerCollected = false,
    this.phMeterCollected = false,
    this.pipetteCollected = false,
    this.stirrerCollected = false,
    this.inhibitorCollected = false,
  });

  void collectThermometer() {
    thermometerCollected = true;
    notifyListeners();
  }

  void collectPhMeter() {
    phMeterCollected = true;
    notifyListeners();
  }

  void collectPipette() {
    pipetteCollected = true;
    notifyListeners();
  }

  void collectStirrer() {
    stirrerCollected = true;
    notifyListeners();
  }

  void collectInhibitor() {
    inhibitorCollected = true;
    notifyListeners();
  }

  void setTemperature(double value) {
    if (!thermometerCollected) return;
    temperature = value.clamp(0.0, 100.0);
    notifyListeners();
  }

  void setPh(double value) {
    if (!phMeterCollected) return;
    ph = value.clamp(0.0, 14.0);
    notifyListeners();
  }

  void addSubstrate([double amount = 0.5]) {
    if (!pipetteCollected) return;
    substrate = (substrate + amount).clamp(0.0, 100.0);
    notifyListeners();
  }

  void toggleInhibitor() {
    if (!inhibitorCollected) return;
    inhibitor = !inhibitor;
    notifyListeners();
  }

  void toggleMixing() {
    if (!stirrerCollected) return;
    mixing = !mixing;
    notifyListeners();
  }

  void resetExperiment() {
    temperature = 37.0;
    ph = 7.0;
    substrate = 1.0;
    inhibitor = false;
    mixing = false;
    notifyListeners();
  }
}
