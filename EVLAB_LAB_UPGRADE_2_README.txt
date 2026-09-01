EV-LAB LAB UPGRADE 2

This ZIP is based on EVLAB_INTEGRATION_FIXED and keeps the existing project structure,
services, progress integration, simulation engine, database, and assets.

CHANGES
1. Temperature control
   - Replaced the custom thermometer gesture control in VirtualLabScreen with a standard
     Flutter Slider from 0 to 100 C.
   - It is interactive immediately and is no longer locked to the optimum value.
   - The starting temperature is intentionally slightly away from optimum so the learner
     can see the effect of changing it.

2. pH control
   - Replaced the custom pH meter gesture control in VirtualLabScreen with a standard
     Flutter Slider from pH 0 to 14.
   - It is interactive immediately and is no longer locked to the optimum.

3. Better lab setup
   - The equipment drawer is no longer used by the main screen.
   - A visible Bench Setup workflow replaces it: calibrate thermometer, calibrate pH meter,
     load micropipette, and power the magnetic stirrer.
   - The run action still requires real preparation/mixing instead of simply pressing RUN.

4. Live experiment
   - Existing reaction-chamber animation remains in place.
   - Temperature, pH, substrate, inhibitor, and mixing changes continue to feed the
     EnzymeSimulation virtual-lab calculation.

5. 3D model loading
   - The original large catalase and lipase files were causing excessive WebView/renderer
     memory pressure. The old source files are preserved under:
       assets/models/source_originals/
   - Lightweight educational GLB versions are now used by the normal asset paths:
       assets/models/catalase.glb
       assets/models/lipase.glb
   - Amylase remains included at its existing path.
   - The existing model_viewer_plus viewer is retained, so the three models can still be
     rotated and zoomed when the WebView renderer supports them.
   - The molecular animation remains underneath the 3D viewer as a visual fallback.

IMPORTANT
The lightweight catalase/lipase GLBs are optimized educational molecular representations,
not replacements for laboratory measurements. The original source GLBs are preserved in the
ZIP so they are not lost.

AFTER REPLACING THE PROJECT
Run:
  flutter clean
  flutter pub get
  flutter run -d emulator-5554
