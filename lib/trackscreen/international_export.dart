import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:yogayog/constants/app_colors.dart';

class InternationalExport extends StatefulWidget {
  const InternationalExport({
    super.key,
    this.trackingNumber = 'IEQ-2025-0047',
    this.subServiceId = 9,
    this.pickupName = '',
    this.pickupAddress = '',
    this.pickupCity = '',
    this.dropName = '',
    this.dropAddress = '',
    this.dropCity = '',
    this.riderName = '',
    this.riderMobile = '',
    this.orderDate = '',
    this.amount = 0,
    this.status = 'In Transit',
    this.paymentDone = false,
  });

  final String trackingNumber;
  final int subServiceId;
  final String pickupName, pickupAddress, pickupCity;
  final String dropName, dropAddress, dropCity;
  final String riderName, riderMobile, orderDate, status;
  final double amount;
  final bool paymentDone;

  @override
  State<InternationalExport> createState() => _InternationalExportState();
}

class _InternationalExportState extends State<InternationalExport> {
  static const navy = AppColors.primaryMain;
  static const yellow = Color(0xFFFFC400);
  static const page = Color(0xFFF4F4FA);
  static const _googleMapsApiKey = 'AIzaSyC6atqg-XZ8SVzSlLrt5W5mhCgkG-8h6Lo';
  gmaps.LatLng? _pickupLocation;
  gmaps.LatLng? _dropLocation;
  gmaps.GoogleMapController? _mapController;
  List<gmaps.LatLng> _routePoints = const [];
  bool _isMapLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMapLocations();
  }

  Future<void> _loadMapLocations() async {
    final pickup = await _coordinatesFor(
      widget.pickupAddress.isNotEmpty
          ? widget.pickupAddress
          : widget.pickupCity,
    );
    final drop = await _coordinatesFor(
      widget.dropAddress.isNotEmpty ? widget.dropAddress : widget.dropCity,
    );
    final route = pickup != null && drop != null
        ? await _fetchRoute(pickup, drop)
        : const <gmaps.LatLng>[];
    if (!mounted) return;
    setState(() {
      _pickupLocation = pickup;
      _dropLocation = drop;
      _routePoints = route;
      _isMapLoading = false;
    });
    _fitMapToRoute();
  }

  Future<gmaps.LatLng?> _coordinatesFor(String address) async {
    if (address.trim().isEmpty) return null;
    try {
      final locations = await locationFromAddress(address);
      if (locations.isEmpty) return null;
      return gmaps.LatLng(locations.first.latitude, locations.first.longitude);
    } catch (_) {
      return null;
    }
  }

  Future<List<gmaps.LatLng>> _fetchRoute(
    gmaps.LatLng origin,
    gmaps.LatLng destination,
  ) async {
    try {
      final response = await Dio().get(
        'https://maps.googleapis.com/maps/api/directions/json',
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'mode': 'driving',
          'key': _googleMapsApiKey,
        },
      );
      final data = response.data;
      final encoded =
          data is Map &&
              data['routes'] is List &&
              (data['routes'] as List).isNotEmpty
          ? ((data['routes'] as List).first['overview_polyline']?['points'])
          : null;
      return encoded is String ? _decodePolyline(encoded) : const [];
    } catch (_) {
      return const [];
    }
  }

  List<gmaps.LatLng> _decodePolyline(String encoded) {
    final points = <gmaps.LatLng>[];
    var index = 0, latitude = 0, longitude = 0;
    while (index < encoded.length) {
      var shift = 0, result = 0;
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
    final controller = _mapController;
    final pickup = _pickupLocation;
    final drop = _dropLocation;
    if (controller == null || pickup == null || drop == null) return;
    final bounds = gmaps.LatLngBounds(
      southwest: gmaps.LatLng(
        pickup.latitude < drop.latitude ? pickup.latitude : drop.latitude,
        pickup.longitude < drop.longitude ? pickup.longitude : drop.longitude,
      ),
      northeast: gmaps.LatLng(
        pickup.latitude > drop.latitude ? pickup.latitude : drop.latitude,
        pickup.longitude > drop.longitude ? pickup.longitude : drop.longitude,
      ),
    );
    controller.animateCamera(gmaps.CameraUpdate.newLatLngBounds(bounds, 55));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: page,
    body: SafeArea(
      child: Column(
        children: [
          _header(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _map(),
                  _delivery(),
                  _summary(),
                  _title('Customs & Flight Updates'),
                  _timeline(),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _header() => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(8, 7, 10, 22),
    color: navy,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Row(
            children: [
              Icon(Icons.arrow_back, color: Colors.white, size: 20),
              SizedBox(width: 4),
              Text(
                'All\nOrders',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  height: .95,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 12, top: 12),
          child: Text(
            widget.trackingNumber,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 12),
          child: Text(
            widget.subServiceId == 8
                ? 'International Import · India'
                : 'International Export · UAE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _map() {
    final pickup = _pickupLocation ?? const gmaps.LatLng(22.5726, 88.3639);
    final markers = <gmaps.Marker>{
      gmaps.Marker(
        markerId: const gmaps.MarkerId('pickup'),
        position: pickup,
        infoWindow: const gmaps.InfoWindow(title: 'Pickup'),
      ),
      if (_dropLocation != null)
        gmaps.Marker(
          markerId: const gmaps.MarkerId('drop'),
          position: _dropLocation!,
          icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
            gmaps.BitmapDescriptor.hueYellow,
          ),
          infoWindow: const gmaps.InfoWindow(title: 'Drop'),
        ),
    };
    final polylines = <gmaps.Polyline>{
      if (_routePoints.length > 1)
        gmaps.Polyline(
          polylineId: const gmaps.PolylineId('pickup_to_drop'),
          points: _routePoints,
          color: navy,
          width: 5,
        ),
    };
    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          Positioned.fill(
            child: gmaps.GoogleMap(
              initialCameraPosition: gmaps.CameraPosition(
                target: pickup,
                zoom: 4,
              ),
              markers: markers,
              polylines: polylines,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              onMapCreated: (controller) {
                _mapController = controller;
                _fitMapToRoute();
              },
            ),
          ),
          if (_isMapLoading)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0xFFE7EBFA),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _delivery() => Container(
    margin: const EdgeInsets.only(top: 12),
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 13),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F2FF),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Est. Delivery to Dubai',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
              SizedBox(height: 3),
              Text(
                widget.status,
                style: TextStyle(
                  color: navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        Text('✈️', style: TextStyle(fontSize: 29)),
      ],
    ),
  );

  Widget _summary() => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Row(
      children: [
        _info('📦', '18 kg', 'Weight'),
        _info('✈️', widget.subServiceId == 8 ? 'Import' : 'Export', 'Type'),
        _info('🏛️', '₹${widget.amount}', 'Amount'),
      ],
    ),
  );

  Widget _info(String icon, String value, String label) => Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: _card(),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    ),
  );

  Widget _title(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 15, 4, 7),
    child: Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
    ),
  );

  Widget _timeline() => Column(
    children: [
      _Step(
        'Shipment Booked',
        '${widget.trackingNumber} · ${widget.pickupCity}',
        widget.orderDate,
        true,
        false,
      ),
      _Step(
        'Customs Export Cleared',
        widget.pickupAddress,
        widget.status,
        true,
        false,
      ),
      _Step(
        'Departed India',
        '${widget.pickupCity} → ${widget.dropCity}',
        widget.status,
        true,
        false,
      ),
      _Step('Arrived Dubai', widget.dropAddress, widget.status, true, false),
      _Step(
        'UAE Customs Clearance',
        widget.riderName.isEmpty ? 'Customs processing' : widget.riderName,
        widget.riderMobile,
        false,
        true,
      ),
      _Step('Out for Delivery', widget.dropName, widget.status, false, false),
      _Step('Delivered', widget.dropName, 'Pending', false, false, last: true),
    ],
  );

  BoxDecoration _card() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [
      BoxShadow(color: Color(0x10000000), blurRadius: 7, offset: Offset(0, 3)),
    ],
  );
}

class _Step extends StatelessWidget {
  const _Step(
    this.title,
    this.subtitle,
    this.time,
    this.done,
    this.active, {
    this.last = false,
  });
  final String title, subtitle, time;
  final bool done, active, last;
  @override
  Widget build(BuildContext context) {
    final color = active
        ? const Color(0xFFFFC400)
        : done
        ? const Color(0xFF202A8D)
        : const Color(0xFFE1E3E9);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: color,
                child: Icon(
                  done ? Icons.check : Icons.circle,
                  size: 13,
                  color: active ? Colors.black : Colors.white,
                ),
              ),
              if (!last)
                Expanded(
                  child: Container(width: 2, color: const Color(0xFF202A8D)),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: active
                          ? const Color(0xFF202A8D)
                          : done
                          ? Colors.black
                          : Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  Text(
                    time,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapDot extends StatelessWidget {
  const _MapDot({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Icon(Icons.circle, color: Color(0xFF202A8D), size: 9),
      const SizedBox(width: 2),
      Text(
        label,
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
      ),
    ],
  );
}

class _WorldMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE7EBFA),
    );
    final grid = Paint()
      ..color = const Color(0x18002A80)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 32)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    for (double y = 0; y < size.height; y += 27)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    final globe = Paint()
      ..color = const Color(0x305D6F9B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;
    canvas.drawCircle(const Offset(187, 81), 48, globe);
    final route = Paint()
      ..color = const Color(0xFF9BA9E0)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(113, 102)
      ..quadraticBezierTo(153, 80, 193, 63);
    canvas.drawPath(path, route);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
