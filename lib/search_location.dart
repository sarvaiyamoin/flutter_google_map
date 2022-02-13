import 'dart:convert';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;

class SearchLocation {
  final String APIkey = "AIzaSyCPuEsCvU5_RfMNSe4U1RFS9uxkOXQ9Fz8";

  Future<String> getPlaceId(String location) async {
    final url =
        "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$location&inputtype=textquery&key=$APIkey";
    final response = await http.get(Uri.parse(url));
    final body = jsonDecode(response.body);
    print("response" + response.body);

    var placeId = body['candidates'][0]['place_id'] as String;

    print("Place id" + placeId);
    return placeId;
  }

  Future<Map<String, dynamic>> getPlace(String location) async {
    final placeId = await getPlaceId(location);
    final String url =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$APIkey";
    final response = await http.get(Uri.parse(url));
    final body = jsonDecode(response.body);
    print("response" + response.body);

    var result = body['result'] as Map<String, dynamic>;

    print("Place id" + result.toString());
    return result;
  }

  Future<Map<String, dynamic>> getDirection(
      String origin, String destination) async {
    final url =
        "https://maps.googleapis.com/maps/api/directions/json?destination=$destination&origin=$origin&key=$APIkey";
    final response = await http.get(Uri.parse(url));
    final body = jsonDecode(response.body);
    print("response" + response.body);
    var result = {
      'bounds_ne': body['routes'][0]['bounds']['northeast'],
      'bounds_sw': body['routes'][0]['bounds']['southwest'],
      'start_location': body['routes'][0]['legs'][0]['start_location'],
      'end_location': body['routes'][0]['legs'][0]['end_location'],
      'polyline': body['routes'][0]['overview_polyline']['points'],
      'polyline_decode': PolylinePoints()
          .decodePolyline(body['routes'][0]['overview_polyline']['points']),
    };
    // var result = body['result'] as ;

    print("Place id" + result.toString());
    return result;
  }
}
