import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:anbessa_bus_app/models/bus_route.dart';


class RouteDetailScreen extends StatefulWidget {
  final BusRoute route;

  const RouteDetailScreen({Key? key, required this.route}) : super(key: key);

  @override
  _RouteDetailScreenState createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _busPositionAnimation;
  int _currentStopIndex = 0;
  final MapController _mapController = MapController();


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(
          seconds:
              10), // Changed from 30 to 10 seconds to speed up the animation
      vsync: this,
    );

    _busPositionAnimation =
        Tween<double>(begin: 0, end: 1).animate(_animationController)
          ..addListener(() {
            setState(() {});
          });

    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  LatLng _getInterpolatedPosition() {
    final totalStops = widget.route.stops.length;
    final animationProgress = _busPositionAnimation.value * (totalStops - 1);
    _currentStopIndex = animationProgress.floor();

    if (_currentStopIndex >= totalStops - 1) {
      return LatLng(widget.route.stops.last.lat, widget.route.stops.last.lng);
    }

    final currentStop = widget.route.stops[_currentStopIndex];
    final nextStop = widget.route.stops[_currentStopIndex + 1];
    final segmentProgress = animationProgress - _currentStopIndex;

    return LatLng(
      currentStop.lat + (nextStop.lat - currentStop.lat) * segmentProgress,
      currentStop.lng + (nextStop.lng - currentStop.lng) * segmentProgress,
    );
  }

  Widget _buildStopMarker(BusStop stop, bool isFirst, bool isLast) {
    Color markerColor;
    IconData markerIcon;
    double size;

    if (isFirst) {
      markerColor = Colors.green;
      markerIcon = Icons.trip_origin;
      size = 30.0;
    } else if (isLast) {
      markerColor = Colors.red;
      markerIcon = Icons.place;
      size = 30.0;
    } else {
      markerColor = Colors.blue;
      markerIcon = Icons.circle;
      size = 20.0;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(markerIcon, color: markerColor, size: size * 0.8),
    );
  }

  Widget _buildMovingBus() {
    return Container(
      width: 40,
      height: 40,
      child: Icon(
        Icons.directions_bus,
        color: Colors.red[700],
        size: 30,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bus ${widget.route.busNumber}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              '${widget.route.routeStart} → ${widget.route.routeDestination}',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        backgroundColor: Colors.red[700],
        elevation: 0,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(
                widget.route.stops[0].lat,
                widget.route.stops[0].lng,
              ),
              zoom: 13.0,
              maxZoom: 18.0,
              minZoom: 12.0,
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
                    points: widget.route.stops
                        .map((stop) => LatLng(stop.lat, stop.lng))
                        .toList(),
                    color: Colors.red[700]!,
                    strokeWidth: 4.0,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  ...widget.route.stops.asMap().entries.map(
                    (entry) {
                      final index = entry.key;
                      final stop = entry.value;
                      return Marker(
                        width: 30.0,
                        height: 30.0,
                        point: LatLng(stop.lat, stop.lng),
                        builder: (ctx) => _buildStopMarker(
                          stop,
                          index == 0,
                          index == widget.route.stops.length - 1,
                        ),
                      );
                    },
                  ),
                  Marker(
                    width: 40.0,
                    height: 40.0,
                    point: _getInterpolatedPosition(),
                    builder: (ctx) => _buildMovingBus(),
                  ),
                ],
              ),
            ],
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.2,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 12),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Route Information',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Distance: ${widget.route.routeKilometers}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (widget.route.routePassBy.isNotEmpty) ...[
                              SizedBox(height: 4),
                              Text(
                                'Via: ${widget.route.routePassBy}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                            Divider(height: 32),
                            Text(
                              'Stops',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            ...widget.route.stops.asMap().entries.map((entry) {
                              final index = entry.key;
                              final stop = entry.value;
                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: index == 0
                                            ? Colors.green
                                            : index ==
                                                    widget.route.stops.length -
                                                        1
                                                ? Colors.red
                                                : Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        stop.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: index == 0 ||
                                                  index ==
                                                      widget.route.stops
                                                              .length -
                                                          1
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'speed',
            backgroundColor: Colors.blue,
            child: Icon(Icons.speed),
            onPressed: () {
              setState(() {
                _animationController.duration = Duration(
                    seconds: _animationController.duration!.inSeconds == 10
                        ? 30
                        : 10);
                _animationController.repeat();
              });
            },
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'location',
            backgroundColor: Colors.red[700],
            child: Icon(Icons.my_location),
            onPressed: () {
              _mapController.move(
                LatLng(widget.route.stops[0].lat, widget.route.stops[0].lng),
                12.0,
              );
            },
          ),
        ],
      ),
    );
  }
}
