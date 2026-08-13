import 'package:flutter/material.dart';
import 'package:yogayog/constants/app_colors.dart';

class NationalOutForDelivery extends StatefulWidget {
  const NationalOutForDelivery({super.key});

  @override
  State<NationalOutForDelivery> createState() => _NationalOutForDeliveryState();
}

class _NationalOutForDeliveryState extends State<NationalOutForDelivery> {
  static const navy = AppColors.primaryMain;
  static const green = Color(0xFF2DBE5B);
  static const yellow = Color(0xFFFFC400);
  static const page = Color(0xFFF4F4FA);

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
                  _eta(),
                  _summary(),
                  _title('Tracking Updates'),
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
        const Padding(
          padding: EdgeInsets.only(left: 8, top: 12),
          child: Text(
            'YCG-2025-00872 · DTDC',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
        Row(
          children: [
            const Expanded(
              child: Text(
                'National · Out for Delivery',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

  Widget _map() => SizedBox(
    height: 180,
    child: Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _DeliveryMapPainter())),
        Positioned(
          left: 0,
          top: 12,
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 6, 13, 6),
            decoration: BoxDecoration(
              color: const Color(0xFF555861),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery area',
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
                Text(
                  'Andheri, Mumbai',
                  style: TextStyle(
                    color: green,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Positioned(left: 160, top: 75, child: _TruckPin()),
        const Positioned(
          left: 78,
          top: 94,
          child: Icon(Icons.circle, color: Colors.white, size: 10),
        ),
        const Positioned(
          right: 64,
          top: 48,
          child: Icon(Icons.circle, color: yellow, size: 14),
        ),
      ],
    ),
  );

  Widget _eta() => Container(
    margin: const EdgeInsets.only(top: 12),
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
                'Estimated Delivery',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
              SizedBox(height: 3),
              Text(
                'Today by 6:00 PM',
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

  Widget _summary() => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Row(
      children: [
        _info('📦', '3.5 kg', 'Weight'),
        _info('🚚', 'Standard', 'Service'),
        _info('💵', 'Prepaid', 'Payment'),
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

  Widget _timeline() => const Column(
    children: [
      _Step('Picked Up', 'Kolkata, WB', 'Jul 26, 11:00 AM', true, false),
      _Step('In Transit', 'Nagpur Sorting Hub', 'Jul 27, 8:40 PM', true, false),
      _Step(
        'Arrived Mumbai Hub',
        'Bhiwandi DTDC Hub',
        'Jul 30, 4:20 AM',
        true,
        false,
      ),
      _Step(
        'Out for Delivery',
        'DTDC Andheri Delivery Center',
        'Today 9:00 AM',
        true,
        false,
      ),
      _Step(
        'On the Way · Andheri area',
        'Delivery agent: Rajesh M.',
        'Now · Delivery by 6 PM',
        false,
        true,
      ),
      _Step('Delivered', '', 'Expected by 6:00 PM', false, false, last: true),
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
                          ? const Color(0xFF20B957)
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

class _TruckPin extends StatelessWidget {
  const _TruckPin();
  @override
  Widget build(BuildContext context) => Container(
    width: 38,
    height: 34,
    decoration: BoxDecoration(
      color: const Color(0xFF2DBE5B),
      borderRadius: BorderRadius.circular(9),
      boxShadow: const [BoxShadow(color: Color(0x28000000), blurRadius: 8)],
    ),
    child: const Center(child: Text('🚚', style: TextStyle(fontSize: 18))),
  );
}

class _DeliveryMapPainter extends CustomPainter {
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
      ..color = const Color(0xFF9BA9E0)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(78, 124)
      ..lineTo(190, 124)
      ..quadraticBezierTo(252, 124, 252, 70)
      ..lineTo(252, 58);
    canvas.drawPath(path, route);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
