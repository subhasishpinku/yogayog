import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:yogayog/constants/app_colors.dart';

class LocalTruckOutForDelivery extends StatefulWidget {
  const LocalTruckOutForDelivery({
    super.key,
    this.trackingNumber = 'YCG-2025-00904',
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
    this.status = 'Pickup Scheduled',
    this.paymentDone = false,
  });

  final String trackingNumber;
  final String pickupName;
  final String pickupAddress;
  final String pickupCity;
  final String dropName;
  final String dropAddress;
  final String dropCity;
  final String riderName;
  final String riderMobile;
  final String orderDate;
  final double amount;
  final String status;
  final bool paymentDone;

  @override
  State<LocalTruckOutForDelivery> createState() =>
      _LocalTruckOutForDeliveryState();
}

class _LocalTruckOutForDeliveryState extends State<LocalTruckOutForDelivery> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: page,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(9, 0, 9, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _mapPanel(),
                    _pickupCard(),
                    _notice(),
                    _quickInfo(),
                    _title('Shipment Details'),
                    _detailsCard(),
                    _title('Status Updates'),
                    _timeline(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(8, 7, 10, 23),
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
          padding: EdgeInsets.only(left: 6, top: 12),
          child: Text(
            widget.trackingNumber,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
        const Text(
          'Local Truck · Pickup Scheduled',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );

  Widget _mapPanel() {
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
                zoom: 11,
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

  Widget _pickupCard() => Container(
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
                'Pickup Window',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
              SizedBox(height: 3),
              Text(
                widget.orderDate.isEmpty ? widget.status : widget.orderDate,
                style: TextStyle(
                  color: navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        Text('🗓️', style: TextStyle(fontSize: 27)),
      ],
    ),
  );

  Widget _notice() => Container(
    margin: const EdgeInsets.only(top: 12),
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF6D5),
      borderRadius: BorderRadius.circular(13),
    ),
    child: Text(
      '⏰ Pickup: ${widget.pickupAddress.isEmpty ? widget.pickupCity : widget.pickupAddress}\nRider: ${widget.riderName.isEmpty ? 'Not assigned' : widget.riderName}',
      style: TextStyle(color: Color(0xFF765A00), fontSize: 12, height: 1.35),
    ),
  );

  Widget _quickInfo() => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Row(
      children: [
        _info('📦', '480 kg', 'Weight'),
        _info('🚚', 'Truck', 'Vehicle'),
        _info(
          '💵',
          widget.paymentDone
              ? 'Paid ₹${widget.amount}'
              : 'Due ₹${widget.amount}',
          'Payment',
        ),
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

  Widget _title(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 15, 4, 7),
    child: Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
    ),
  );

  Widget _detailsCard() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
    decoration: _card(),
    child: Column(
      children: [
        _row(
          'From',
          '${widget.pickupName.isEmpty ? 'Pickup' : widget.pickupName}\n${widget.pickupAddress.isEmpty ? widget.pickupCity : widget.pickupAddress}',
        ),
        _row(
          'To',
          '${widget.dropName.isEmpty ? 'Drop' : widget.dropName}\n${widget.dropAddress.isEmpty ? widget.dropCity : widget.dropAddress}',
        ),
        _row('Service', 'Local – Truck'),
        _row('Booked On', widget.orderDate.isEmpty ? '—' : widget.orderDate),
      ],
    ),
  );

  Widget _timeline() => Column(
    children: [
      _Step(
        'Booking Confirmed',
        widget.trackingNumber,
        widget.orderDate,
        true,
        false,
      ),
      _Step(
        'Rider Assigned · En route',
        widget.riderName.isEmpty
            ? 'Rider not assigned'
            : '${widget.riderName} · ${widget.riderMobile}',
        widget.status,
        true,
        true,
      ),
      _Step('Picked Up', widget.pickupAddress, widget.status, false, false),
      _Step(
        'Delivered',
        widget.dropName.isEmpty ? widget.dropCity : widget.dropName,
        'Pending',
        false,
        false,
        last: true,
      ),
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

Widget _row(String label, String value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 10),
  child: Row(
    children: [
      SizedBox(
        width: 80,
        child: Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ),
      Expanded(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ),
    ],
  ),
);

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
              padding: const EdgeInsets.only(bottom: 18),
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

class _TruckMapPainter extends CustomPainter {
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
    final route = Paint()
      ..color = const Color(0xFFB0BADB)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(70, 100)
      ..lineTo(190, 100)
      ..quadraticBezierTo(245, 100, 245, 53);
    canvas.drawPath(path, route);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
