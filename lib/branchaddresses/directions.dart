import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/constants/app_colors.dart';

const _googleMapsApiKey = String.fromEnvironment(
  'GOOGLE_MAPS_API_KEY',
  defaultValue: 'AIzaSyC6atqg-XZ8SVzSlLrt5W5mhCgkG-8h6Lo',
);

class Directions extends StatefulWidget {
  const Directions({
    super.key,
    required this.destination,
    required this.destinationName,
    this.originLatitude,
    this.originLongitude,
  });

  final String destination;
  final String destinationName;
  final double? originLatitude;
  final double? originLongitude;

  @override
  State<Directions> createState() => _DirectionsState();
}

class _DirectionsState extends State<Directions> {
  gmaps.GoogleMapController? _mapController;
  gmaps.LatLng? _destinationPoint;
  List<gmaps.LatLng> _routePoints = const [];
  bool _isLoading = true;
  String? _error;

  gmaps.LatLng? get _originPoint {
    if (widget.originLatitude == null || widget.originLongitude == null) {
      return null;
    }
    return gmaps.LatLng(widget.originLatitude!, widget.originLongitude!);
  }

  @override
  void initState() {
    super.initState();
    _loadDestination();
  }

  Future<void> _loadDestination() async {
    try {
      final locations = await locationFromAddress(widget.destination);
      if (!mounted) return;
      if (locations.isEmpty) {
        setState(() {
          _isLoading = false;
          _error = 'Unable to locate this branch address.';
        });
        return;
      }
      setState(() {
        _destinationPoint = gmaps.LatLng(
          locations.first.latitude,
          locations.first.longitude,
        );
      });
      await _loadRoadRoute();
      if (!mounted) return;
      setState(() => _isLoading = false);
      _fitMapToRoute();
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Unable to locate this branch address.';
        });
      }
    }
  }

  Future<void> _loadRoadRoute() async {
    final origin = _originPoint;
    final destination = _destinationPoint;
    if (origin == null || destination == null) return;

    try {
      final response = await ApiClient.dio.get(
        'https://maps.googleapis.com/maps/api/directions/json',
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'mode': 'driving',
          'key': _googleMapsApiKey,
        },
      );
      final data = response.data;
      final routes = data is Map ? data['routes'] : null;
      final route = routes is List && routes.isNotEmpty && routes.first is Map
          ? Map<String, dynamic>.from(routes.first as Map)
          : null;
      final overviewPolyline = route?['overview_polyline'];
      final encoded = overviewPolyline is Map
          ? overviewPolyline['points']
          : null;
      if (encoded is String && encoded.isNotEmpty) {
        _routePoints = _decodePolyline(encoded);
      } else {
        final legs = route?['legs'];
        final stepPoints = <gmaps.LatLng>[];
        if (legs is List) {
          for (final leg in legs) {
            if (leg is! Map || leg['steps'] is! List) continue;
            for (final step in leg['steps'] as List) {
              if (step is! Map || step['polyline'] is! Map) continue;
              final stepEncoded = step['polyline']['points'];
              if (stepEncoded is String && stepEncoded.isNotEmpty) {
                stepPoints.addAll(_decodePolyline(stepEncoded));
              }
            }
          }
        }
        if (stepPoints.isNotEmpty) {
          _routePoints = stepPoints;
        }
      }
    } catch (_) {
      // Keep the fallback line when the Directions API is unavailable.
    }
  }

  List<gmaps.LatLng> _decodePolyline(String encoded) {
    final points = <gmaps.LatLng>[];
    var index = 0;
    var latitude = 0;
    var longitude = 0;

    while (index < encoded.length) {
      var shift = 0;
      var result = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20 && index < encoded.length);
      latitude += (result & 1) != 0 ? ~(result >> 1) : result >> 1;

      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20 && index < encoded.length);
      longitude += (result & 1) != 0 ? ~(result >> 1) : result >> 1;

      points.add(gmaps.LatLng(latitude / 1e5, longitude / 1e5));
    }
    return points;
  }

  void _fitMapToRoute() {
    final origin = _originPoint;
    final destination = _destinationPoint;
    if (_mapController == null || destination == null) return;
    if (origin == null) {
      _mapController!.animateCamera(
        gmaps.CameraUpdate.newLatLngZoom(destination, 15),
      );
      return;
    }
    final bounds = gmaps.LatLngBounds(
      southwest: gmaps.LatLng(
        origin.latitude < destination.latitude
            ? origin.latitude
            : destination.latitude,
        origin.longitude < destination.longitude
            ? origin.longitude
            : destination.longitude,
      ),
      northeast: gmaps.LatLng(
        origin.latitude > destination.latitude
            ? origin.latitude
            : destination.latitude,
        origin.longitude > destination.longitude
            ? origin.longitude
            : destination.longitude,
      ),
    );
    _mapController!.animateCamera(
      gmaps.CameraUpdate.newLatLngBounds(bounds, 70),
    );
  }

  Set<gmaps.Polyline> _routePolylines() {
    final origin = _originPoint;
    final destination = _destinationPoint;
    if (origin == null || destination == null) return const {};

    return {
      gmaps.Polyline(
        polylineId: const gmaps.PolylineId('current_to_branch_route'),
        points: _routePoints.isEmpty ? [origin, destination] : _routePoints,
        color: AppColors.primaryMain,
        width: 6,
        zIndex: 5,
        jointType: gmaps.JointType.round,
        startCap: gmaps.Cap.roundCap,
        endCap: gmaps.Cap.roundCap,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final origin = _originPoint;
    final destination = _destinationPoint;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
        backgroundColor: AppColors.primaryMain,
        foregroundColor: Colors.white,
        title: const Text('Directions'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.primaryMain),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.destinationName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!))
                : gmaps.GoogleMap(
                    initialCameraPosition: gmaps.CameraPosition(
                      target:
                          destination ?? const gmaps.LatLng(22.5726, 88.3639),
                      zoom: 12,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                      _fitMapToRoute();
                    },
                    myLocationEnabled: origin != null,
                    myLocationButtonEnabled: true,
                    markers: {
                      if (origin != null)
                        gmaps.Marker(
                          markerId: const gmaps.MarkerId('current_location'),
                          position: origin,
                          infoWindow: const gmaps.InfoWindow(
                            title: 'Current location',
                          ),
                        ),
                      if (destination != null)
                        gmaps.Marker(
                          markerId: const gmaps.MarkerId('branch'),
                          position: destination,
                          infoWindow: gmaps.InfoWindow(
                            title: widget.destinationName,
                          ),
                        ),
                    },
                    polylines: _routePolylines(),
                  ),
          ),
        ],
      ),
    );
  }
}
