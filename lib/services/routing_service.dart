import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';

class RoutingService {
  static const String _baseUrl = 'https://router.project-osrm.org/route/v1/driving/';

  static Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final url = '$_baseUrl${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coordinates = data['routes'][0]['geometry']['coordinates'] as List;
        
        return coordinates.map((coord) {
          // OSRM returns coordinates as [longitude, latitude]
          return LatLng(coord[1].toDouble(), coord[0].toDouble());
        }).toList();
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
    
    // Return direct line if routing fails
    return [start, end];
  }

  static Future<List<LatLng>> getCompleteRoute(List<LatLng> stops) async {
    List<LatLng> completeRoute = [];
    
    for (int i = 0; i < stops.length - 1; i++) {
      final segment = await getRoute(stops[i], stops[i + 1]);
      completeRoute.addAll(segment);
    }
    
    return completeRoute;
  }
}

