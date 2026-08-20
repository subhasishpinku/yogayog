import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:yogayog/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class LocalBikeOutForDelivery extends StatefulWidget {
  const LocalBikeOutForDelivery({
    super.key,
    this.trackingNumber = 'YCG-2025-00921',
    this.pickupName = '',
    this.pickupCity = '',
    this.pickupAddress = '',
    this.pickupMobile = '',
    this.dropName = '',
    this.dropCity = '',
    this.dropAddress = '',
    this.dropMobile = '',
    this.riderName = '',
    this.riderMobile = '',
    this.orderDate = '',
    this.amount = 0,
    this.status = 'Out for Delivery',
    this.paymentDone = false,
  });

  final String trackingNumber;
  final String pickupName;
  final String pickupCity;
  final String pickupAddress;
  final String pickupMobile;
  final String dropName;
  final String dropCity;
  final String dropAddress;
  final String dropMobile;
  final String riderName;
  final String riderMobile;
  final String orderDate;
  final double amount;
  final String status;
  final bool paymentDone;

  @override
  State<LocalBikeOutForDelivery> createState() =>
      _LocalBikeOutForDeliveryState();
}

class _LocalBikeOutForDeliveryState extends State<LocalBikeOutForDelivery> {
  static const navy = AppColors.primaryMain;
  static const green = Color(0xFF2DBE5B);
  static const yellow = Color(0xFFFFC400);
  static const page = Color(0xFFF4F4FA);

  gmaps.LatLng? _pickupLocation;
  gmaps.LatLng? _dropLocation;
  gmaps.GoogleMapController? _mapController;
  bool _isMapLoading = true;
  List<gmaps.LatLng> _routePoints = const [];
  static const _googleMapsApiKey = 'AIzaSyC6atqg-XZ8SVzSlLrt5W5mhCgkG-8h6Lo';

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
      if (encoded is! String || encoded.isEmpty) return const [];
      return _decodePolyline(encoded);
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
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _mapPanel(),
                    _etaCard(),
                    _riderCard(),
                    _quickInfo(),
                    _sectionTitle('Shipment Details'),
                    _detailsCard(),
                    _sectionTitle('Status Updates'),
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

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 7, 8, 22),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Local Bike · ${widget.status}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8EC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, color: green, size: 8),
                    SizedBox(width: 4),
                    Text(
                      'Live',
                      style: TextStyle(
                        color: green,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
              compassEnabled: true,
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
          Positioned(
            left: 0,
            top: 12,
            child: _mapLabel('Rider distance', '2.1 km away'),
          ),
          Positioned(
            right: 0,
            top: 12,
            child: InkWell(
              onTap: _openFullMap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: yellow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  '🗺️ Full Map',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),
            ),
          ),
          const Positioned(left: 124, top: 66, child: _BikePin()),
          const Positioned(
            right: 52,
            bottom: 42,
            child: Icon(Icons.location_on, color: Color(0xFFE5B900), size: 25),
          ),
        ],
      ),
    );
  }

  Future<void> _openFullMap() async {
    final origin = widget.pickupAddress.isNotEmpty
        ? widget.pickupAddress
        : widget.pickupCity;
    final destination = widget.dropAddress.isNotEmpty
        ? widget.dropAddress
        : widget.dropCity;

    if (origin.isEmpty || destination.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pickup or drop address is unavailable.')),
      );
      return;
    }

    final uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'origin': origin,
      'destination': destination,
      'travelmode': 'driving',
    });

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to open the map.')));
    }
  }

  Widget _mapLabel(String title, String value) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 5),
      decoration: BoxDecoration(
        color: const Color(0xFF555861),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          Text(
            value,
            style: const TextStyle(
              color: yellow,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _etaCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 13),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Arrival',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
                SizedBox(height: 3),
                Text(
                  'Today · ~15 minutes',
                  style: TextStyle(
                    color: green,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Text('⚡', style: TextStyle(fontSize: 29)),
        ],
      ),
    );
  }

  Widget _riderCard() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFECEFFF),
            child: const Text(
              'SK',
              style: TextStyle(color: navy, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.riderName.isEmpty ? 'Rider' : widget.riderName} · 🛵',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 3),
                Text(
                  widget.riderMobile.isEmpty
                      ? 'Rider contact unavailable'
                      : widget.riderMobile,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _callRider,
            icon: const Icon(Icons.call, size: 16),
            label: const Text('Call'),
            style: ElevatedButton.styleFrom(
              backgroundColor: yellow,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _callRider() async {
    final phone = widget.riderMobile.replaceAll(RegExp(r'[^0-9+]'), '');
    if (phone.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rider phone number is unavailable.')),
      );
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open the phone dialer.')),
      );
    }
  }

  Widget _quickInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          _infoTile('📦', '2 kg', 'Weight'),
          _infoTile('🛵', 'Bike', 'Vehicle'),
          _infoTile(
            '💵',
            widget.paymentDone
                ? 'Paid ₹${widget.amount}'
                : 'Due ₹${widget.amount}',
            'Payment',
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String icon, String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 15, 4, 7),
    child: Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
    ),
  );

  Widget _detailsCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 9, 15, 9),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _detailRow(
            'From',
            '${widget.pickupName.isEmpty ? 'Pickup' : widget.pickupName}\n${widget.pickupAddress.isEmpty ? '—' : widget.pickupAddress}',
          ),
          _detailRow(
            'To',
            '${widget.dropName.isEmpty ? 'Drop' : widget.dropName}\n${widget.dropAddress.isEmpty ? '—' : widget.dropAddress}',
          ),
          _detailRow('Service', 'Local – Bike'),
          _detailRow(
            'Booked On',
            widget.orderDate.isEmpty ? '—' : widget.orderDate,
          ),
          _detailRow(
            'Payment',
            widget.paymentDone
                ? 'Paid · ₹${widget.amount}'
                : 'Payment pending · ₹${widget.amount}',
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          SizedBox(
            width: 85,
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
  }

  Widget _timeline() {
    return Column(
      children: [
        _TimelineItem(
          'Booking Confirmed',
          'Order ${widget.orderDate.isEmpty ? widget.trackingNumber : widget.orderDate}',
          widget.paymentDone ? 'Payment received' : 'Payment pending',
          Icons.check,
          navy,
        ),
        _TimelineItem(
          'Rider Assigned',
          widget.riderName.isEmpty
              ? 'Rider assignment pending'
              : '${widget.riderName} · ${widget.riderMobile}',
          widget.status,
          Icons.check,
          navy,
        ),
        _TimelineItem(
          'Picked Up',
          widget.pickupAddress.isEmpty
              ? widget.pickupName
              : widget.pickupAddress,
          widget.status,
          Icons.check,
          navy,
        ),
        _TimelineItem(
          widget.status,
          widget.dropAddress.isEmpty ? widget.dropName : widget.dropAddress,
          'Current status',
          Icons.circle,
          yellow,
        ),
        _TimelineItem(
          'Delivered',
          widget.dropName.isEmpty ? widget.dropCity : widget.dropName,
          'Pending',
          Icons.circle,
          Color(0xFFE1E3E9),
          last: true,
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [
      BoxShadow(color: Color(0x10000000), blurRadius: 7, offset: Offset(0, 3)),
    ],
  );
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem(
    this.title,
    this.subtitle,
    this.time,
    this.icon,
    this.color, {
    this.last = false,
  });
  final String title, subtitle, time;
  final IconData icon;
  final Color color;
  final bool last;

  @override
  Widget build(BuildContext context) {
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
                  icon,
                  size: 13,
                  color: color == const Color(0xFFFFC400)
                      ? Colors.black
                      : Colors.white,
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
                      color: color == const Color(0xFFFFC400)
                          ? const Color(0xFF202A8D)
                          : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
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

class _BikePin extends StatelessWidget {
  const _BikePin();
  @override
  Widget build(BuildContext context) => Container(
    width: 42,
    height: 38,
    decoration: BoxDecoration(
      color: const Color(0xFF202A8D),
      borderRadius: BorderRadius.circular(11),
      boxShadow: const [BoxShadow(color: Color(0x30000000), blurRadius: 8)],
    ),
    child: const Center(child: Text('🛵', style: TextStyle(fontSize: 19))),
  );
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFE7EBFA);
    canvas.drawRect(Offset.zero & size, bg);
    final grid = Paint()
      ..color = const Color(0x18002A80)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 32)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    for (double y = 0; y < size.height; y += 27)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    final route = Paint()
      ..color = const Color(0xFF9BA9E0)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(65, 128)
      ..lineTo(200, 128)
      ..quadraticBezierTo(252, 128, 252, 78)
      ..lineTo(252, 58);
    canvas.drawPath(path, route);
    canvas.drawCircle(
      const Offset(65, 128),
      3,
      Paint()..color = const Color(0xFF202A8D),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
