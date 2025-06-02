import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:quber_taxi/common/models/mapbox_route.dart';

extension CameraOptionsExtension on CameraOptions {

  CameraOptions copyWith({
    Point? center,
    MbxEdgeInsets? padding,
    ScreenCoordinate? anchor,
    double? zoom,
    double? bearing,
    double? pitch
}){
    return CameraOptions(
      center: center ?? this.center,
      padding: padding ?? this.padding,
      anchor: anchor ?? this.anchor,
      zoom: zoom ?? this.zoom,
      bearing: bearing ?? this.bearing,
      pitch: pitch ?? this.pitch
    );
  }
}

Future<MapboxRoute> loadGeoJsonFakeRoute(String source) async {
  final data = await rootBundle.loadString(source);
  return MapboxRoute.fromJson(json.decode(data));
}