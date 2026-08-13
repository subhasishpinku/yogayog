import 'package:flutter/material.dart';
import 'package:yogayog/constants/app_colors.dart';

class NationalExpressInTransit extends StatefulWidget {
  const NationalExpressInTransit({super.key});

  @override
  State<NationalExpressInTransit> createState() =>
      _NationalExpressInTransitState();
}

class _NationalExpressInTransitState extends State<NationalExpressInTransit> {
  static const navy = AppColors.primaryMain;
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
                    _deliveryCard(),
                    _quickInfo(),
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
  }

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
          padding: EdgeInsets.only(left: 6, top: 12),
          child: Text(
            'YCG-2025-00891 · Delhivery',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
        const Text(
          'National Express · In Transit',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );

  Widget _mapPanel() => SizedBox(
    height: 180,
    child: Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _ExpressMapPainter())),
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
                  'Current',
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
                Text(
                  'Varanasi Hub',
                  style: TextStyle(
                    color: yellow,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Positioned(left: 156, top: 72, child: _CargoPin()),
        const Positioned(left: 54, top: 108, child: _MapDot(label: 'KOL')),
        const Positioned(right: 46, top: 50, child: _MapDot(label: 'DEL')),
      ],
    ),
  );

  Widget _deliveryCard() => Container(
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
                'Saturday, 2 Aug 2026',
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

  Widget _quickInfo() => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Row(
      children: [
        _info('📦', '5.2 kg', 'Weight'),
        _info('🚚', 'Express', 'Service'),
        _info('📍', '1,480 km', 'Distance'),
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
        'Picked Up',
        'Jodhpur Park, Kolkata',
        'Jul 30, 10:15 AM',
        true,
        false,
      ),
      _Step(
        'Inscanned at Branch',
        'YCG-BR-KOL-01 · Jodhpur Park',
        'Jul 30, 1:00 PM',
        true,
        false,
      ),
      _Step(
        'Air Dispatched',
        'CCU → Varanasi · IndiGo 6E-204',
        'Jul 30, 5:30 PM',
        true,
        false,
      ),
      _Step(
        'In Transit · Varanasi Hub',
        'Sorting & forwarding to Delhi',
        'Jul 31, 2:10 AM · Now',
        false,
        true,
      ),
      _Step('Arrived Delhi Hub', '', 'Expected Aug 1', false, false),
      _Step('Out for Delivery · Delhi', '', 'Expected Aug 2', false, false),
      _Step('Delivered', '', 'Expected Aug 2', false, false, last: true),
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

class _CargoPin extends StatelessWidget {
  const _CargoPin();
  @override
  Widget build(BuildContext context) => Container(
    width: 38,
    height: 32,
    decoration: BoxDecoration(
      color: Colors.orange,
      borderRadius: BorderRadius.circular(8),
      boxShadow: const [BoxShadow(color: Color(0x28000000), blurRadius: 8)],
    ),
    child: const Center(child: Text('🚚', style: TextStyle(fontSize: 18))),
  );
}

class _MapDot extends StatelessWidget {
  const _MapDot({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
      ),
      const SizedBox(width: 2),
      const Icon(Icons.circle, size: 11, color: Color(0xFFFFC400)),
    ],
  );
}

class _ExpressMapPainter extends CustomPainter {
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
      ..moveTo(58, 108)
      ..lineTo(178, 108)
      ..lineTo(286, 54);
    canvas.drawPath(path, route);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
