import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:anbessa_bus_app/models/bus_route.dart';

class BusRouteService {
  static Future<List<BusRoute>> getBusRoutes() async {
    try {
      final String response = await rootBundle.loadString('assets/bus_routes.json');
      // print('Loaded JSON: $response'); // Debug print
      final List<dynamic> data = json.decode(response) as List<dynamic>;
      // print('Decoded JSON: $data'); // Debug print
      return data
          .map((json) => BusRoute.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      print('Error loading bus routes: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  static Future<BusRoute?> getBusRouteByNumber(String busNumber) async {
    final routes = await getBusRoutes();
    try {
      return routes.firstWhere((route) => route.busNumber == busNumber);
    } catch (e) {
      print('Error getting route by number: $e');
      return null;
    }
  }

  static Future<List<BusRoute>> searchBusRoutes(String query) async {
    final routes = await getBusRoutes();
    return routes.where((route) =>
      route.busNumber.toLowerCase().contains(query.toLowerCase()) ||
      route.routeStart.toLowerCase().contains(query.toLowerCase()) ||
      route.routeDestination.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}

