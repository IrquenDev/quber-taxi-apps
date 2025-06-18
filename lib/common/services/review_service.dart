import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quber_taxi/common/models/review.dart';
import 'package:quber_taxi/config/api_config.dart';

class ReviewService {

  final _apiConfig = ApiConfig();
  final _endpoint = "reviews";

  Future<http.Response> submitReview({
    required String comment,
    required int rating,
    required int clientId,
    required int driverId
  }) async {
    final url = Uri.parse("${_apiConfig.baseUrl}/$_endpoint?clientId=$clientId&driverId=$driverId");
    final headers = {'Content-Type': 'application/json'};
    return await http.post(url, headers: headers, body: jsonEncode({
      "comment": comment,
      "rating": rating
    }));
  }

  Future<List<Review>> findAll() async {
    final url = Uri.parse('${_apiConfig.baseUrl}/$_endpoint');
    final response = await http.get(url);
    if (response.body.trim().isEmpty) {
      return [];
    }
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((json) => Review.fromJson(json)).toList();
  }
}