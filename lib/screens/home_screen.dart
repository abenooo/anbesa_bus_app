// import 'package:flutter/material.dart';
// import 'package:anbessa_bus_app/models/bus_route.dart';
// import 'package:anbessa_bus_app/services/bus_route_service.dart';
// import 'package:anbessa_bus_app/screens/route_detail_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   List<BusRoute> busRoutes = [];
//   bool isLoading = true;
//   String errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     _loadBusRoutes();
//   }

//   Future<void> _loadBusRoutes() async {
//     try {
//       final routes = await BusRouteService.getBusRoutes();
//       setState(() {
//         busRoutes = routes;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Failed to load bus routes: $e';
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Anbessa Bus Routes'),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : errorMessage.isNotEmpty
//               ? Center(child: Text(errorMessage))
//               : ListView.builder(
//                   itemCount: busRoutes.length,
//                   itemBuilder: (context, index) {
//                     final route = busRoutes[index];
//                     return ListTile(
//                       title: Text('Bus ${route.busNumber}'),
//                       subtitle: Text('${route.routeStart} - ${route.routeDestination}'),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => RouteDetailScreen(route: route),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:anbessa_bus_app/models/bus_route.dart';
import 'package:anbessa_bus_app/services/bus_route_service.dart';
import 'package:anbessa_bus_app/screens/route_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<BusRoute> busRoutes = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadBusRoutes();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anbessa Bus Routes'),
        backgroundColor: Colors.blue,
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
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            route.busNumber,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text('${route.routeStart} - ${route.routeDestination}'),
                        subtitle: Text('Via: ${route.routePassBy}'),
                        trailing: Text('${route.routeKilometers}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RouteDetailScreen(route: route),
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

