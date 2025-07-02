import 'package:flutter/foundation.dart';
import 'package:turf/turf.dart' as turf;

@immutable
class Waypoint {

  final turf.Position benchmark;
  final turf.Position point;
  final num distance;

  const Waypoint(this.benchmark, this.point, this.distance);
}