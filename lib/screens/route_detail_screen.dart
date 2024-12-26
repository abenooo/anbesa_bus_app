import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:anbessa_bus_app/models/bus_route.dart';
import 'package:anbessa_bus_app/services/routing_service.dart';

class RouteDetailScreen extends StatefulWidget {
  final BusRoute route;

  const RouteDetailScreen({Key? key, required this.route}) : super(key: key);

  @override
  _RouteDetailScreenState createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  List<LatLng> routePoints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    final points = await RoutingService.getCompleteRoute(
        widget.route.stops.map((stop) => stop.location).toList());
    setState(() {
      routePoints = points;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        titleTextStyle: const TextStyle(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Bus - ${widget.route.busNumber}'),
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
                  options: MapOptions(
                    center: widget.route.stops.first.location,
                    zoom: 13.0,
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
                          points: routePoints,
                          color: Colors.blue,
                          strokeWidth: 4.0,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: widget.route.stops
                          .map((stop) => Marker(
                                width: 30.0,
                                height: 30.0,
                                point: stop.location,
                                builder: (ctx) => const Icon(
                                  Icons.location_on,
                                  color: Colors.green,
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.1,
            maxChildSize: 0.5,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...widget.route.stops
                          .map((stop) => _buildStopItem(stop.name)),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            right: 16,
            bottom: 240,
            child: FloatingActionButton(
              backgroundColor: Colors.green,
              child: const Icon(Icons.my_location),
              onPressed: () {
                // Implement location centering
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopItem(String stopName) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            stopName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
