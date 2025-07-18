import 'package:flutter/foundation.dart';
import 'package:turf/turf.dart' as turf;

/// Represents a geographical waypoint used for navigation or route analysis.
///
/// A [Waypoint] typically consists of:
/// - [benchmark]: A reference point or anchor position.
/// - [point]: The actual location of the waypoint.
/// - [distance]: The distance (in meters or desired units) between the benchmark and the point.
///
/// This class is immutable and can be used safely in collections or streams.
///
/// Example:
/// ```dart
/// final wp = Waypoint(
///   turf.Position.of([-82.3, 23.1]),
///   turf.Position.of([-82.301, 23.105]),
///   645
/// );
/// ```
@immutable
class Waypoint {

  /// Reference point from which the distance is measured.
  final turf.Position benchmark;

  /// Target location of this waypoint.
  final turf.Position point;

  /// Distance between [benchmark] and [point].
  final num distance;

  /// Creates a new immutable [Waypoint].
  const Waypoint(this.benchmark, this.point, this.distance);
}