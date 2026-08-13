import 'package:flutter/material.dart';
import 'package:yogayog/constants/app_colors.dart';

class InternationalExport extends StatefulWidget {
  const InternationalExport({super.key});

  @override
  State<InternationalExport> createState() => _InternationalExportState();
}

class _InternationalExportState extends State<InternationalExport> {
  static const navy = AppColors.primaryMain;
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
        const Padding(
          padding: EdgeInsets.only(left: 12, top: 12),
          child: Text(
            'IEQ-2025-0047',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Text(
            'International Export · UAE',
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

  Widget _map() => SizedBox(
    height: 180,
    child: Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _WorldMapPainter())),
        Positioned(
          left: 5,
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
                  'Status',
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
                Text(
                  'UAE Customs',
                  style: TextStyle(
                    color: Color(0xFF32A5FF),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Positioned(left: 103, top: 97, child: _MapDot(label: 'KOL')),
        const Positioned(right: 113, top: 62, child: _MapDot(label: 'DXB')),
        const Positioned(
          left: 157,
          top: 55,
          child: Icon(Icons.flight_takeoff, color: Colors.black, size: 25),
        ),
      ],
    ),
  );

  Widget _delivery() => Container(
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
                'Est. Delivery to Dubai',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
              SizedBox(height: 3),
              Text(
                'Aug 5–7, 2026',
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
        _info('✈️', 'Export', 'Type'),
        _info('🏛️', 'Garments', 'Contents'),
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
      _Step(
        'Shipment Booked',
        'YCG-OUT-0047 · Jodhpur Park',
        'Jul 25, 2:00 PM',
        true,
        false,
      ),
      _Step(
        'Customs Export Cleared',
        'Shipping Bill filed · CCU Airport',
        'Jul 26, 11:30 AM',
        true,
        false,
      ),
      _Step(
        'Departed India',
        'CCU → DXB · EK 572',
        'Jul 28, 9:20 PM',
        true,
        false,
      ),
      _Step(
        'Arrived Dubai',
        'DXB · Cargo terminal',
        'Jul 29, 12:40 AM',
        true,
        false,
      ),
      _Step(
        'UAE Customs Clearance',
        'Dubai Customs Authority · In progress',
        'Now',
        false,
        true,
      ),
      _Step('Out for Delivery · Dubai', '', 'Expected Aug 5', false, false),
      _Step('Delivered', '', 'Expected Aug 5–7', false, false, last: true),
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
