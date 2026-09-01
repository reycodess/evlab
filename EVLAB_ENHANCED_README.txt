EV-LAB ENHANCED BUILD
======================

This package is a rebuilt copy of the EV-LAB project you provided.
The original 3D models are included under:
  assets/models/amylase.glb
  assets/models/catalase.glb
  assets/models/lipase.glb

What was improved
-----------------
1. The Virtual Lab now includes a real ModelViewer 3D enzyme panel using the
   existing GLB assets and the selected enzyme's model3D path.
2. The Virtual Lab now has a hands-on bench with ADD DROP and STIR actions.
3. Mixing quality contributes a modest handling factor to the final simulated
   activity, while the existing temperature, pH, substrate, and inhibitor
   model remains the main driver.
4. The Structure screen continues to use the same real GLB assets.
5. Existing database, missions, history, graphs, results, and other screens
   are preserved.

INSTALL
-------
1. Make a backup of your current EV-LAB project.
2. Extract this ZIP.
3. Use the extracted project as the project source, or copy the changed files
   into your current project if you have made newer changes yourself.
4. From the project root run:

   flutter clean
   flutter pub get
   flutter run -d emulator-5554

3D MODEL / ANDROID NOTE
-----------------------
model_viewer_plus uses an Android WebView. If your generated Android project
blocks local/cleartext WebView content, open:

  android/app/src/main/AndroidManifest.xml

and make sure the application element contains:

  android:usesCleartextTraffic="true"

For example:

  <application
      android:label="evlab"
      android:usesCleartextTraffic="true"
      ... >

Do not add a second <application> element. Only add the attribute to the
existing one.

If the 3D model still appears blank, run the app on an Android 9+ emulator,
wait a few seconds for the WebView to initialize, and verify that the model
files are present in assets/models/.

IMPORTANT
---------
The ZIP contains the complete source tree and the original model assets.
Do not delete assets/models/ or remove model_viewer_plus from pubspec.yaml.
