# EV-LAB

An interactive Flutter enzyme-activity laboratory for learning how temperature,
pH, substrate concentration, mixing, and inhibition affect reaction rate.

## Improvements in this build

- Experiment results now use a snapshot of the prepared sample, so stirring
  affects the saved activity instead of being cleared before calculation.
- The primary lab bench is the single experiment interface; advanced settings
  are limited to inhibitor configuration to avoid repeated controls.
- Pipetting and stirring update the live experiment state and activity.
- Unused duplicate simulation/state/widget implementations were removed.
- Generated build, IDE, and cache folders are excluded from this release.

## Run

```bash
flutter pub get
flutter run
```

## Recommended next work

Add automated kinetics tests, persistent learner progress, controlled
experiment templates with replicates, and result graphs based on grouped
student measurements rather than only idealized model curves.

## Figma-inspired scientific lab upgrade

This build adds a guided dark laboratory console with live condition status,
experiment-design guidance, pH 0–14 controls, and non-flat activity behavior
outside supplied reference-data ranges.
