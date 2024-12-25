import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:anbessa_bus_app/models/bus_route.dart';

class MapWidget extends StatelessWidget {
  final BusRoute? selectedRoute;

  const MapWidget({Key? key, this.selectedRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LatLng addisAbaba = LatLng(9.0054, 38.7636);

    return FlutterMap(
      options: MapOptions(
        center: addisAbaba,
        zoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: const ['a', 'b', 'c'],
        ),
        if (selectedRoute != null) ...[
          PolylineLayer(
            polylines: [
              Polyline(
                points: selectedRoute!.routeCoordinates,
                color: Colors.blue,
                strokeWidth: 4.0,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: selectedRoute!.routeCoordinates.first,
                builder: (ctx) => Column(
                  children: [
                    const Icon(Icons.location_on, color: Colors.green),
                    Text(selectedRoute!.routeStart, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Marker(
                width: 80.0,
                height: 80.0,
                point: selectedRoute!.routeCoordinates.last,
                builder: (ctx) => Column(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red),
                    Text(selectedRoute!.routeDestination, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

