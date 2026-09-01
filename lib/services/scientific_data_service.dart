import '../models/activity_point.dart';

class ScientificDataService {
  /// Finds the experimentally documented activity
  /// closest to the selected condition.
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

  /// Converts a measured activity value into a
  /// relative percentage using the highest
  /// documented activity in the dataset.
  static double relativeActivity(
      List<ActivityPoint> data,
      double condition,
      ) {
    if (data.isEmpty) {
      return 0;
    }

    final activity = findClosestActivity(
      data: data,
      condition: condition,
    );

    if (activity == null) {
      return 0;
    }

    final maximum = data
        .map((point) => point.activity)
        .reduce((a, b) => a > b ? a : b);

    if (maximum == 0) {
      return 0;
    }

    return (activity / maximum * 100)
        .clamp(0.0, 100.0);
  }
}