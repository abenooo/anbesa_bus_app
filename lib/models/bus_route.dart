import 'package:latlong2/latlong.dart';

class BusStop {
  final String name;
  final double lat;
  final double lng;

  BusStop({
    required this.name,
    required this.lat,
    required this.lng,
  });

  LatLng get location => LatLng(lat, lng);

  factory BusStop.fromJson(Map<String, dynamic> json) {
    return BusStop(
      name: json['name'] as String,
      lat: json['lat'] as double,
      lng: json['lng'] as double,
    );
  }
}

class BusRoute {
  final String busNumber;
  final String routeStart;
  final String routePassBy;
  final String routeDestination;
  final String routeKilometers;
  final List<BusStop> stops;

  BusRoute({
    required this.busNumber,
    required this.routeStart,
    required this.routePassBy,
    required this.routeDestination,
    required this.routeKilometers,
    required this.stops,
  });

  List<LatLng> get routeCoordinates {
    return stops.map((stop) => stop.location).toList();
  }

  factory BusRoute.fromJson(Map<String, dynamic> json) {
    return BusRoute(
      busNumber: json['busNumber'] as String,
      routeStart: json['routeStart'] as String,
      routePassBy: json['routePassBy'] as String,
      routeDestination: json['routeDestination'] as String,
      routeKilometers: json['routeKilometers'] as String,
      stops: (json['stops'] as List)
          .map((stop) => BusStop.fromJson(stop as Map<String, dynamic>))
          .toList(),
    );
  }
}

