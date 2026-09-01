import '../models/activity_point.dart';

class ScientificData {
  // Finds the activity value closest to the
  // experimental condition selected by the user.
  static double? findClosestActivity({
    required List<ActivityPoint> data,
    required double condition,
  }) {
    if (data.isEmpty) {
      return null;
    }

    ActivityPoint closest = data.first;

    double smallestDifference =
    (closest.condition - condition).abs();

    for (final point in data) {
      final difference =
      (point.condition - condition).abs();

      if (difference < smallestDifference) {
        smallestDifference = difference;
        closest = point;
      }
    }

    return closest.activity;
  }
}