import 'dart:async';
import 'package:bookapp_customer/app/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:bookapp_customer/app/urls.dart';
import 'package:bookapp_customer/app/app_constants.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class KeylessLocationMapWithUser extends StatefulWidget {
  final double lat;
  final double lon;
  final double zoom;
  final double markerSize;
  final BorderRadiusGeometry borderRadius;
  final bool autoCenterOnUser;

  const KeylessLocationMapWithUser({
    super.key,
    required this.lat,
    required this.lon,
    this.zoom = 15,
    this.markerSize = 46,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.autoCenterOnUser = true,
  });

  @override
  State<KeylessLocationMapWithUser> createState() =>
      _KeylessLocationMapWithUserState();
}

class _KeylessLocationMapWithUserState
    extends State<KeylessLocationMapWithUser> {
  final MapController _mapController = MapController();
  LatLng? _myLatLng;
  StreamSubscription<Position>? _posSub;
  String? _error;
  bool _starting = false;

  // Provide via: flutter run --dart-define=MAPTILER_KEY=YOUR_KEY
  static const _mapTilerKey = mapTilerKey;

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _startLocation();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _posSub = null;
    super.dispose();
  }

  Future<void> _startLocation() async {
    if (_starting) return;
    _starting = true;

    // Ensure we don't have multiple listeners
    await _posSub?.cancel();
    _posSub = null;

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!mounted) return;
      if (!serviceEnabled) {
        _safeSetState(() => _error = 'Location services are disabled.');
        // keep going; user can enable later
      }

      var perm = await Geolocator.checkPermission();
      if (!mounted) return;
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (!mounted) return;

      if (perm == LocationPermission.deniedForever) {
        _safeSetState(
          () => _error =
              'Location permission permanently denied. Enable it in Settings.',
        );
        return;
      }
      if (perm == LocationPermission.denied) {
        _safeSetState(() => _error = 'Location permission denied.');
        return;
      }

      // Initial fix: guard after await
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      if (!mounted) return;

      final me = LatLng(p.latitude, p.longitude);
      _safeSetState(() => _myLatLng = me);
      if (widget.autoCenterOnUser && mounted) {
        _mapController.move(me, widget.zoom);
      }

      // Live updates (guard every callback)
      _posSub =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.best,
              distanceFilter: 5,
            ),
          ).listen(
            (pos) {
              if (!mounted) return;
              _safeSetState(() {
                _myLatLng = LatLng(pos.latitude, pos.longitude);
              });
            },
            onError: (e, st) {
              if (!mounted) return;
              _safeSetState(() => _error = 'Location stream error: $e');
            },
          );
    } catch (e) {
      if (!mounted) return;
      _safeSetState(() => _error = e.toString());
    } finally {
      _starting = false;
    }
  }

  void _centerOnMe() {
    final me = _myLatLng;
    if (me != null) {
      _mapController.move(me, widget.zoom);
    } else {
      _startLocation();
    }
  }

  void _centerOnPin() {
    if (!mounted) return;
    _mapController.move(LatLng(widget.lat, widget.lon), widget.zoom);
  }

  @override
  Widget build(BuildContext context) {
    final target = LatLng(widget.lat, widget.lon);

    final markers = <Marker>[
      // Target pin
      Marker(
        point: target,
        width: widget.markerSize,
        height: widget.markerSize,
        alignment: Alignment.bottomCenter,
        child: Icon(
          Icons.location_pin,
          size: widget.markerSize,
          color: AppColors.primaryColor,
        ),
      ),
      // User dot
      if (_myLatLng != null)
        Marker(
          point: _myLatLng!,
          width: 22,
          height: 22,
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withAlpha(95),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 6),
              ],
            ),
          ),
        ),
    ];

    return Stack(
      children: [
        ClipRRect(
          borderRadius: widget.borderRadius,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: target,
              initialZoom: widget.zoom,
            ),
            children: [
              if (_mapTilerKey.isNotEmpty)
                TileLayer(
                  urlTemplate: Urls.mapTilerUrlTemplate.replaceFirst('{key}', _mapTilerKey),
                  maxZoom: 20,
                )
              else
                TileLayer(
                  urlTemplate: Urls.openStreetMapUrlTemplate,
                  userAgentPackageName: 'com.example.bookapp_customer',
                  maxZoom: 19,
                ),

              MarkerLayer(markers: markers),

              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    _mapTilerKey.isNotEmpty
                        ? '© MapTiler © OpenStreetMap contributors'
                        : '© OpenStreetMap contributors',
                  ),
                ],
              ),
            ],
          ),
        ),

        // Buttons
        Positioned(
          right: 12,
          bottom: 12,
          child: Column(
            children: [
              FloatingActionButton.small(
                backgroundColor: AppColors.primaryColor,
                heroTag: 'meBtn',
                onPressed: _centerOnMe,
                child: const Icon(Icons.my_location, color: Colors.white),
              ),
              const SizedBox(height: 10),
              FloatingActionButton.small(
                backgroundColor: AppColors.primaryColor,
                heroTag: 'pinBtn',
                onPressed: _centerOnPin,
                child: const Icon(Icons.location_pin, color: Colors.white),
              ),
            ],
          ),
        ),

        // Error banner
        if (_error != null)
          Positioned(
            left: 12,
            right: 12,
            top: 12,
            child: Material(
              color: Colors.red.withAlpha(96),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
