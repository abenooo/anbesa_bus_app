import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:anbessa_bus_app/models/bus_route.dart';

class RouteDetailScreen extends StatelessWidget {
  final BusRoute route;

  const RouteDetailScreen({Key? key, required this.route}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bus ${route.busNumber} Details'),
        backgroundColor: Colors.red[700],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: FlutterMap(
              options: MapOptions(
                center: LatLng(route.stops[0].lat, route.stops[0].lng),
                zoom: 12.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: route.stops
                          .map((stop) => LatLng(stop.lat, stop.lng))
                          .toList(),
                      color: Colors.red,
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: route.stops
                      .map((stop) => Marker(
                            width: 40.0,
                            height: 40.0,
                            point: LatLng(stop.lat, stop.lng),
                            builder: (ctx) => const Icon(Icons.location_on,
                                color: Colors.red),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: ListView(
              children: [
                ListTile(
                  title: Text(
                      'Route: ${route.routeStart} - ${route.routeDestination}'),
                  subtitle: Text('Via: ${route.routePassBy}'),
                ),
                ListTile(
                  title: Text('Distance: ${route.routeKilometers}'),
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Stops:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ...route.stops.map((stop) => ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.red),
                      title: Text(stop.name),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
