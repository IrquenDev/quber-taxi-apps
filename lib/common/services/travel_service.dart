import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quber_taxi/common/models/page.dart';
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
  /// - [destinationCoords]: list `[longitude, latitude]` representing the destination
  /// - [requiredSeats]: number of seats needed
  /// - [hasPets]: whether the passenger has pets
  /// - [taxiType]: required taxi type
  /// - [fixedDistance], [fixedPrice]: Estimations when user has chosen an specific destination.
  /// - [minDistance], [maxDistance]: Distance estimations when user has chosen a municipality as destination
  /// - [minPrice], [maxPrice]: Price estimations when user has chosen a municipality as destination
  ///
  /// Returns a parsed [Travel] object from the response.
  Future<http.Response> requestNewTravel({
    required int clientId,
    required String originName,
    required String destinationName,
    required List<num> originCoords,
    List<num>? destinationCoords,
    required int requiredSeats,
    required bool hasPets,
    required TaxiType taxiType,
    required double? fixedDistance,
    required double? minDistance,
    required double? maxDistance,
    required double? fixedPrice,
    required double? minPrice,
    required double? maxPrice,
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
        "destinationCoords": destinationCoords,
        "requiredSeats": requiredSeats,
        "hasPets": hasPets,
        "taxiType": taxiType.apiValue,
        "fixedDistance": fixedDistance,
        "minDistance": minDistance,
        "maxDistance": maxDistance,
        "fixedPrice": fixedPrice,
        "minPrice": minPrice,
        "maxPrice": maxPrice,
      }),
    );
    return response;
  }

  /// Fetches all available travels that match the driver's capabilities.
  ///
  /// Filters by [seats] and [type] with pagination support.
  ///
  /// Returns a [Page] of [Travel] objects.
  Future<Page<Travel>> fetchAvailableTravels(int seats, TaxiType type, {int page = 0, int size = 20}) async {
    final url = Uri.parse('${_apiConfig.baseUrl}/$_endpoint?seats=$seats&type=${type.apiValue}&page=$page&size=$size');
    final response = await http.get(url);
    if (response.body.trim().isEmpty) {
      return Page<Travel>(
        content: [],
        number: 0,
        size: size,
        totalElements: 0,
        totalPages: 0,
        first: true,
        last: true,
        empty: true,
      );
    }
    final Map<String, dynamic> jsonMap = jsonDecode(response.body);
    return Page.fromJson(jsonMap, (json) => Travel.fromJson(json));
  }

  /// Fetches all travels that have been completed.
  ///
  /// Filters by the state `completed` on the backend with pagination support.
  ///
  /// Returns a [Page] of [Travel] objects.
  Future<Page<Travel>> fetchAllCompletedTravels({int page = 0, int size = 20}) async {
    final url = Uri.parse('${_apiConfig.baseUrl}/$_endpoint/state/${TravelState.completed.apiValue}?page=$page&size=$size');
    final response = await http.get(url);
    if (response.body.trim().isEmpty) {
      return Page<Travel>(
        content: [],
        number: 0,
        size: size,
        totalElements: 0,
        totalPages: 0,
        first: true,
        last: true,
        empty: true,
      );
    }
    final Map<String, dynamic> jsonMap = jsonDecode(response.body);
    return Page.fromJson(jsonMap, (json) => Travel.fromJson(json));
  }

  /// Fetches all travels by state with pagination support.
  ///
  /// Filters by the given [state] on the backend.
  ///
  /// Returns a [Page] of [Travel] objects.
  Future<Page<Travel>> fetchTravelsByState(TravelState state, {int page = 0, int size = 20}) async {
    final url = Uri.parse('${_apiConfig.baseUrl}/$_endpoint/state/${state.apiValue}?page=$page&size=$size');
    final response = await http.get(url);
    if (response.body.trim().isEmpty) {
      return Page<Travel>(
        content: [],
        number: 0,
        size: size,
        totalElements: 0,
        totalPages: 0,
        first: true,
        last: true,
        empty: true,
      );
    }
    final Map<String, dynamic> jsonMap = jsonDecode(response.body);
    return Page.fromJson(jsonMap, (json) => Travel.fromJson(json));
  }

  /// Fetches all travels (for development purposes) with pagination support.
  ///
  /// Returns a [Page] of [Travel] objects.
  Future<Page<Travel>> fetchAllTravels({int page = 0, int size = 20}) async {
    final url = Uri.parse('${_apiConfig.baseUrl}/$_endpoint/dev?page=$page&size=$size');
    final response = await http.get(url);
    if (response.body.trim().isEmpty) {
      return Page<Travel>(
        content: [],
        number: 0,
        size: size,
        totalElements: 0,
        totalPages: 0,
        first: true,
        last: true,
        empty: true,
      );
    }
    final Map<String, dynamic> jsonMap = jsonDecode(response.body);
    return Page.fromJson(jsonMap, (json) => Travel.fromJson(json));
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

  Future<http.Response> markAsCompleted({
    required int travelId,
    required double finalPrice,
    required int finalDistance,
    required int finalDuration,
    required double quberCredit
  }) async {
    final url = Uri.parse("${_apiConfig.baseUrl}/$_endpoint/complete/$travelId");
    final headers = {'Content-Type': 'application/json'};
    return await http.post(url, headers: headers, body: jsonEncode({
      "finalPrice": double.parse(finalPrice.toStringAsFixed(2)),
      "finalDistance": finalDistance,
      "finalDuration": finalDuration,
      "credit": double.parse(quberCredit.toStringAsFixed(2))
    }));
  }

  Future<http.Response> markAsCompletedWithIssue({
    required int travelId,
  }) async {
    final url = Uri.parse("${_apiConfig.baseUrl}/$_endpoint/complete-with-issue/$travelId");
    final headers = {'Content-Type': 'application/json'};
    return await http.post(url, headers: headers);
  }

  Future<http.Response> getActiveTravelState(int clientId) async {
    final url = Uri.parse('${_apiConfig.baseUrl}/$_endpoint/active/$clientId');
    return await http.get(url);
  }
}