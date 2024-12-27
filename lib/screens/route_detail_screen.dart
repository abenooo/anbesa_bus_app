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
      widget.route.stops.map((stop) => LatLng(stop.lat, stop.lng)).toList()
    );
    setState(() {
      routePoints = points;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Bus ${widget.route.busNumber}: ${widget.route.routeStart} - ${widget.route.routeDestination}'),
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
                  options: MapOptions(
                    center: LatLng(widget.route.stops.first.lat, widget.route.stops.first.lng),
                    zoom: 13.0,
                    maxZoom: 18.0,
                    minZoom: 10.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
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
                      markers: widget.route.stops.asMap().entries.map((entry) {
                        final index = entry.key;
                        final stop = entry.value;
                        return Marker(
                          width: 30.0,
                          height: 30.0,
                          point: LatLng(stop.lat, stop.lng),
                          builder: (ctx) => Container(
                            decoration: BoxDecoration(
                              color: index == 0 || index == widget.route.stops.length - 1 ? Colors.red : Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
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
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
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
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Total Distance: ${widget.route.routeKilometers}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ...widget.route.stops.asMap().entries.map((entry) => _buildStopItem(entry.key, entry.value.name)),
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

  Widget _buildStopItem(int index, String stopName) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: index == 0 || index == widget.route.stops.length - 1 ? Colors.red : Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            stopName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: index == 0 || index == widget.route.stops.length - 1 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

