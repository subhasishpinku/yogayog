import 'package:flutter/material.dart';
import 'package:yogayog/constants/app_colors.dart';

class LocalBikeOutForDelivery extends StatefulWidget {
  const LocalBikeOutForDelivery({super.key});

  @override
  State<LocalBikeOutForDelivery> createState() =>
      _LocalBikeOutForDeliveryState();
}

class _LocalBikeOutForDeliveryState extends State<LocalBikeOutForDelivery> {
  static const navy = AppColors.primaryMain;
  static const green = Color(0xFF2DBE5B);
  static const yellow = Color(0xFFFFC400);
  static const page = Color(0xFFF4F4FA);

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
          const Padding(
            padding: EdgeInsets.only(left: 6, top: 12),
            child: Text(
              'YCG-2025-00921',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Local Bike · Out for Delivery',
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
    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _MapPainter())),
          Positioned(
            left: 0,
            top: 12,
            child: _mapLabel('Rider distance', '2.1 km away'),
          ),
          Positioned(
            right: 0,
            top: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: yellow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '🚚 Full Map',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suresh Kumar · 🛵',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 3),
                Text(
                  'KA 01 AB 1234 · ⭐ 4.8',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {},
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

  Widget _quickInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          _infoTile('📦', '2 kg', 'Weight'),
          _infoTile('🛵', 'Bike', 'Vehicle'),
          _infoTile('💵', 'COD ₹0', 'Payment'),
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
          _detailRow('From', 'Santanu Roy · Jodhpur Park'),
          _detailRow('To', 'Priya Mehta · Kalighat'),
          _detailRow('Service', 'Local – Bike'),
          _detailRow('Booked On', '31 Jul 2026, 8:45 AM'),
          _detailRow('Payment', 'Prepaid · ₹149 ✓'),
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
      children: const [
        _TimelineItem(
          'Booking Confirmed',
          'Payment received',
          '8:45 AM',
          Icons.check,
          navy,
        ),
        _TimelineItem(
          'Rider Assigned',
          'Suresh Kumar · En route to pickup',
          '8:52 AM',
          Icons.check,
          navy,
        ),
        _TimelineItem(
          'Picked Up',
          'Jodhpur Park collected',
          '9:10 AM',
          Icons.check,
          navy,
        ),
        _TimelineItem(
          'Out for Delivery · 2.1 km away',
          'Rashbehari Ave, Kolkata',
          'Now · 9:41 AM',
          Icons.circle,
          yellow,
        ),
        _TimelineItem(
          'Delivered',
          'Priya Mehta · Kalighat',
          'Expected ~9:56 AM',
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
