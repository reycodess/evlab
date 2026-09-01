# EV-LAB Complete Rebuild

This build targets Flutter 3.41.x and avoids audioplayers versions requiring Flutter 3.44+.

## Setup
1. Back up your current project.
2. Extract this ZIP as the project root.
3. Run `flutter clean`.
4. Run `flutter pub get`.
5. Run `flutter analyze`.
6. Run `flutter run`.

## Scientific scope
EV-LAB is an educational simulation. Numerical activity curves are model outputs, not experimental measurements. Enzyme behavior is grounded in OpenStax biology concepts; the 3Rs content is grounded in NIH OLAW guidance.

## Main learning loop
Home -> Mission / 3Rs / Quiz -> Virtual Lab -> Trial result -> explanation -> XP / Progress.
