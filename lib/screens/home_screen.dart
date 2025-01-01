import 'package:flutter/material.dart';
import 'package:anbessa_bus_app/models/bus_route.dart';
import 'package:anbessa_bus_app/services/bus_route_service.dart';
import 'package:anbessa_bus_app/screens/route_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<BusRoute> busRoutes = [];
  bool isLoading = true;
  String errorMessage = '';
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _loadBusRoutes();

    // Initialize animation controller for animated header
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: Colors.red[700],
      end: Colors.red[400],
    ).animate(_controller);
  }

  Future<void> _loadBusRoutes() async {
    try {
      final routes = await BusRouteService.getBusRoutes();
      setState(() {
        busRoutes = routes;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load bus routes: $e';
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AnimatedBuilder(
          animation: _colorAnimation,
          builder: (context, child) {
            return AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/anbessa_bus_logo.png', 
                    height: 40,
                  ),
                  const SizedBox(width: 10),
                  const Text('Anbessa Bus Routes'),
                ],
              ),
              backgroundColor: _colorAnimation.value,
              foregroundColor: Colors.white,
              centerTitle: true,
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: busRoutes.length,
                  itemBuilder: (context, index) {
                    final route = busRoutes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red[700],
                          child: Text(
                            route.busNumber,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                            '${route.routeStart} - ${route.routeDestination}'),
                        subtitle: Text('Via: ${route.routePassBy}'),
                        trailing: Text(route.routeKilometers),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RouteDetailScreen(route: route),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
