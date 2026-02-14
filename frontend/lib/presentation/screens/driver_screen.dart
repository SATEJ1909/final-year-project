import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/socket_io_service.dart';

class DriverScreen extends StatefulWidget {
  final String userId;
  const DriverScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _DriverScreenState createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  late SocketService _socketService;

  // --- Configuration ---
  bool _isTestingMode = false; // CHANGED: Use real GPS by default

  // --- State ---
  LatLng _currentPosition = const LatLng(20.9374, 77.7796); 
  double _currentHeading = 0.0;
  bool _isLive = false;
  bool _autoFollow = true;
  double _currentSpeed = 0.0; // km/h
  List<LatLng> _routeHistory = []; // Trail of last positions

  StreamSubscription<Position>? _gpsSub;
  AnimationController? _moveAnim;
  Timer? _testTimer;

  @override
  void initState() {
    super.initState();
    _socketService = Provider.of<SocketService>(context, listen: false);
    _socketService.connectAndListen(userId: widget.userId, role: 'driver');
    _locateMe();
  }

  // --- LOGIC FUNCTIONS (Keep as they are working perfectly) ---
  void _toggleLiveMode() {
    setState(() { _isLive = !_isLive; _autoFollow = true; });
    if (_isLive) {
      _isTestingMode ? _startSimulation() : _startRealTracking();
    } else {
      _gpsSub?.cancel(); _testTimer?.cancel(); _moveAnim?.stop();
    }
  }

  void _startSimulation() {
    List<LatLng> route = [
      const LatLng(20.9374, 77.7796), const LatLng(20.9380, 77.7720),
      const LatLng(20.9310, 77.7520), const LatLng(20.9270, 77.7580),
    ];
    int i = 0;
    _testTimer = Timer.periodic(const Duration(seconds: 4), (t) {
      if (i >= route.length - 1 || !_isLive) { t.cancel(); return; }
      _onLocationNew(route[i + 1]); i++;
    });
  }

  void _startRealTracking() {
    _gpsSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 3),
    ).listen((p) {
      setState(() => _currentSpeed = p.speed * 3.6); // m/s to km/h
      _onLocationNew(LatLng(p.latitude, p.longitude));
    });
  }

  void _onLocationNew(LatLng target) {
    double heading = _calculateAngle(_currentPosition, target);
    
    // Add to route history for trail
    setState(() {
      _routeHistory.add(target);
      if (_routeHistory.length > 30) _routeHistory.removeAt(0); // Keep last 30 points
    });
    
    _glideTo(target, heading);
    _socketService.sendLocationUpdate(ambulanceId: widget.userId, lat: target.latitude, lng: target.longitude, heading: heading);
  }

  void _glideTo(LatLng end, double heading) {
    _moveAnim?.dispose();
    _moveAnim = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this); // Shorter duration for smoother feel
    final latT = Tween<double>(begin: _currentPosition.latitude, end: end.latitude);
    final lngT = Tween<double>(begin: _currentPosition.longitude, end: end.longitude);
    _moveAnim!.addListener(() {
      if (!mounted) return;
      setState(() {
        _currentPosition = LatLng(latT.evaluate(CurvedAnimation(parent: _moveAnim!, curve: Curves.easeOut)), lngT.evaluate(CurvedAnimation(parent: _moveAnim!, curve: Curves.easeOut))); // Added easing curve
        _currentHeading = heading;
      });
      if (_autoFollow) _mapController.move(_currentPosition, 17.5);
    });
    _moveAnim!.forward();
  }

  double _calculateAngle(LatLng a, LatLng b) {
    double dLon = (b.longitude - a.longitude);
    double y = math.sin(dLon) * math.cos(b.latitude);
    double x = math.cos(a.latitude) * math.sin(b.latitude) - math.sin(a.latitude) * math.cos(b.latitude) * math.cos(dLon);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  Future<void> _locateMe() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('GPS is disabled. Please enable location services.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission denied. Please grant permission in settings.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4),
              ),
            );
          }
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission permanently denied. Enable in device settings.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      // Get current position
      Position p = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() => _currentPosition = LatLng(p.latitude, p.longitude));
        _mapController.move(_currentPosition, 16.0);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Location acquired successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  void dispose() { _gpsSub?.cancel(); _testTimer?.cancel(); _moveAnim?.dispose(); super.dispose(); }

  // --- UPDATED UI BUILDER ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // 1. THE MAP
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 17.0,
              onPositionChanged: (pos, gesture) {
                if (gesture && _autoFollow) setState(() => _autoFollow = false);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              
              // Route trail polyline
              if (_routeHistory.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routeHistory,
                      strokeWidth: 4.0,
                      color: _isLive ? Colors.red.withOpacity(0.7) : Colors.grey.withOpacity(0.5),
                    ),
                  ],
                ),
              
              MarkerLayer(markers: [
                Marker(
                  point: _currentPosition,
                  width: 80, height: 80,
                  child: Transform.rotate(
                    angle: _currentHeading * (math.pi / 180),
                    child: _buildVehicleMarker(),
                  ),
                ),
              ]),
            ],
          ),

          // 2. TOP FLOATING NAVIGATION HEADER WITH SPEED
          if (_isLive)
            Positioned(
              top: 60, left: 16, right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF212121).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.navigation_rounded, color: Colors.greenAccent, size: 30),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("NAVIGATING LIVE", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                          Text(_isTestingMode ? "Simulation Active" : "Broadcasting GPS", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    // Speed indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getSpeedColor(_currentSpeed),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentSpeed.toStringAsFixed(0),
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const Text('km/h', style: TextStyle(color: Colors.white70, fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 3. RE-CENTER BUTTON (Uber Style)
          if (!_autoFollow)
            Positioned(
              bottom: 180, right: 16,
              child: FloatingActionButton(
                heroTag: "recenter",
                backgroundColor: Colors.white,
                elevation: 4,
                mini: true,
                onPressed: () => setState(() { _autoFollow = true; _mapController.move(_currentPosition, 17.5); }),
                child: const Icon(Icons.gps_fixed, color: Colors.black87),
              ),
            ),

          // 4. BOTTOM ACTION CARD
          Positioned(
            bottom: 30, left: 16, right: 16,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_isLive ? "ON DUTY" : "OFFLINE", style: TextStyle(color: _isLive ? Colors.red[700] : Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text(_isLive ? "Emergency Mode" : "Tap to Start Mission", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                        child: const Text("GPS OK", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10)),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _toggleLiveMode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLive ? const Color(0xFFE53935) : const Color(0xFF000000),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        _isLive ? "END MISSION" : "GO LIVE",
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // A custom vehicle marker widget
  // Helper method for speed color
  Color _getSpeedColor(double speed) {
    if (speed < 40) return Colors.green;
    if (speed < 60) return Colors.orange;
    return Colors.red;
  }

  Widget _buildVehicleMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing glow effect when live
        if (_isLive)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.2),
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Container(
                width: 60 * value,
                height: 60 * value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(0.3 / value),
                ),
              );
            },
            onEnd: () => setState(() {}), // Restart animation
          ),
        // Main marker
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.5),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.local_hospital, color: Colors.white, size: 28),
        ),
      ],
    );
  }
}