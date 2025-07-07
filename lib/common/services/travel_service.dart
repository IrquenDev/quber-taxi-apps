import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/config/api_config.dart';
import 'package:quber_taxi/enums/taxi_type.dart';
import 'package:quber_taxi/enums/travel_state.dart';

/// A service class that handles operations related to travel requests,
/// including creating new travels, fetching available or completed travels,
/// and changing travel states.
///
/// All methods communicate with the backend API defined in [ApiConfig].
class TravelService {

  /// API configuration instance.
  final _apiConfig = ApiConfig();

  /// Base endpoint for travel-related operations.
  final _endpoint = "travels";

  /// Creates a new travel request for a client.
  ///
  /// Sends a POST request with detailed trip requirements:
  /// - [clientId]: ID of the client making the request
  /// - [originName] / [destinationName]: display names for the locations
  /// - [originCoords]: list `[longitude, latitude]` representing the origin
  /// - [requiredSeats]: number of seats needed
  /// - [hasPets]: whether the passenger has pets
  /// - [taxiType]: required taxi type
  /// - [minDistance], [maxDistance]: distance filters in kilometers
  /// - [minPrice], [maxPrice]: price range the client is willing to pay
  ///
  /// Returns a parsed [Travel] object from the response.
  Future<Travel> requestNewTravel({
    required int clientId,
    required String originName,
    required String destinationName,
    required List<num> originCoords,
    required int requiredSeats,
    required bool hasPets,
    required TaxiType taxiType,
    required num minDistance,
    required num maxDistance,
    required num minPrice,
    required num maxPrice,
  }) async {
    final url = Uri.parse("${_apiConfig.baseUrl}/$_endpoint/$clientId");
    final headers = {'Content-Type': 'application/json'};

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        "originName": originName,
        "destinationName": destinationName,
        "originCoords": originCoords,
        "requiredSeats": requiredSeats,
        "hasPets": hasPets,
        "taxiType": taxiType.apiValue,
        "minDistance": minDistance,
        "maxDistance": maxDistance,
        "minPrice": minPrice,
        "maxPrice": maxPrice,
      }),
    );

    return Travel.fromJson(jsonDecode(response.body));
  }

  /// Fetches all available travels that match the driver's capabilities.
  ///
  /// Filters by [seats] and [type].
  ///
  /// Returns a list of [Travel] objects.
  Future<List<Travel>> fetchAvailableTravels(int seats, TaxiType type) async {
    final url = Uri.parse('${_apiConfig.baseUrl}/$_endpoint?seats=$seats&type=${type.apiValue}');
    final response = await http.get(url);
    if (response.body.trim().isEmpty) return [];
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((json) => Travel.fromJson(json)).toList();
  }

  /// Fetches all travels that have been completed.
  ///
  /// Filters by the state `completed` on the backend.
  ///
  /// Returns a list of [Travel] objects.
  Future<List<Travel>> fetchAllCompletedTravels() async {
    final url = Uri.parse('${_apiConfig.baseUrl}/$_endpoint/state/${TravelState.completed.apiValue}');
    final response = await http.get(url);
    if (response.body.trim().isEmpty) return [];
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((json) => Travel.fromJson(json)).toList();
  }

  /// Changes the state of a specific travel to the given [state].
  ///
  /// Sends a PATCH request to update the state of travel with [travelId].
  ///
  /// Example usage:
  /// ```dart
  /// await travelService.changeState(
  ///   travelId: 120,
  ///   state: TravelState.inProgress
  /// );
  /// ```
  Future<http.Response> changeState({
    required int travelId,
    required TravelState state,
  }) async {
    final url = Uri.parse("${_apiConfig.baseUrl}/$_endpoint/$travelId?state=${state.apiValue}");
    final headers = {'Content-Type': 'application/json'};
    return await http.patch(url, headers: headers);
  }
}