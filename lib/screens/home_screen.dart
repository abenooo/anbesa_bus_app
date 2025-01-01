import 'package:flutter/material.dart';
import '/models/bus_route.dart';
import '/services/bus_route_service.dart';
import '/screens/route_detail_screen.dart';
import 'dart:async';

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
  String selectedBusType = 'Anbessa';
  int _anbessaCount = 0;
  int _shegerCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadBusRoutes();

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
      _startCountAnimation();
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load bus routes: $e';
        isLoading = false;
      });
    }
  }

  void _startCountAnimation() {
    final anbessaRoutes = busRoutes.where((route) => route.busType == 'Anbessa').length;
    final shegerRoutes = busRoutes.where((route) => route.busType == 'Sheger').length;
    const animationDuration = Duration(milliseconds: 2000);
    const interval = Duration(milliseconds: 50);
    int anbessaStep = 0;
    int shegerStep = 0;

    _timer = Timer.periodic(interval, (timer) {
      setState(() {
        if (_anbessaCount < anbessaRoutes) {
          _anbessaCount += (anbessaRoutes / (animationDuration.inMilliseconds / interval.inMilliseconds)).ceil();
          if (_anbessaCount > anbessaRoutes) _anbessaCount = anbessaRoutes;
        }
        if (_shegerCount < shegerRoutes) {
          _shegerCount += (shegerRoutes / (animationDuration.inMilliseconds / interval.inMilliseconds)).ceil();
          if (_shegerCount > shegerRoutes) _shegerCount = shegerRoutes;
        }
      });

      if (_anbessaCount >= anbessaRoutes && _shegerCount >= shegerRoutes) {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildInfoCard({
    required String title,
    required int value,
    required Color color,
    required String imagePath,
    required String logoText,
    Gradient? gradient,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null ? color : null,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: (gradient != null ? gradient.colors.first : color)
                  .withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    imagePath,
                    height: 32,
                    width: 32,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    logoText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            TweenAnimationBuilder(
              tween: IntTween(begin: 0, end: value),
              duration: const Duration(seconds: 2),
              builder: (context, int value, child) {
                return Text(
                  value.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.white.withOpacity(0.5),
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBusRoutesList(String busType) {
    setState(() {
      selectedBusType = busType;
    });
  }

  Widget _buildBusRoutesList() {
    final filteredRoutes = busRoutes.where((route) => route.busType == selectedBusType).toList();
    return ListView.builder(
      itemCount: filteredRoutes.length,
      itemBuilder: (context, index) {
        final route = filteredRoutes[index];
        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red[700],
              child: Text(
                route.busNumber,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              '${route.routeStart} - ${route.routeDestination}',
            ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(180),
        child: AnimatedBuilder(
          animation: _colorAnimation,
          builder: (context, child) {
            return AppBar(
              backgroundColor: _colorAnimation.value,
              elevation: 0,
              flexibleSpace: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              title: 'Total Routes',
                              value: _anbessaCount,
                              color: Colors.redAccent,
                              imagePath: 'assets/anbessa_bus_logo.png',
                              logoText: 'አንበሳ አውቶቡስ',
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF500F), Color(0xFFFFEF53)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              onTap: () => _showBusRoutesList('Anbessa'),
                              isSelected: selectedBusType == 'Anbessa',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInfoCard(
                              title: 'Total Routes',
                              value: _shegerCount,
                              color: Colors.transparent,
                              imagePath: 'assets/shger_bus.png',
                              logoText: 'ሸገር አውቶቡስ',
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1BA4EA), Color(0xFF2DC7DE)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              onTap: () => _showBusRoutesList('Sheger'),
                              isSelected: selectedBusType == 'Sheger',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : _buildBusRoutesList(),
    );
  }
}

