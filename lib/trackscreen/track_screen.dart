import 'package:flutter/material.dart';
import 'package:yogayog/constants/app_colors.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({
    super.key,
    this.trackingNumber = 'YCG-2025-00921',
    this.from = 'Jodhpur Park',
    this.to = 'Park Street, Kolkata',
    this.riderName = 'Suresh Kumar',
    this.riderPhone = 'KA 01 AB 1234',
    this.weight = '2 kg',
    this.vehicle = 'Bike',
    this.distance = '7.2 km',
    this.eta = 'Today, ~5:45 PM',
  });

  final String trackingNumber;
  final String from;
  final String to;
  final String riderName;
  final String riderPhone;
  final String weight;
  final String vehicle;
  final String distance;
  final String eta;

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  int selectedTab = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4FA),
      body: SafeArea(
        child: Column(
          children: [
            _topHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                children: [
                  _riderCard(),
                  const SizedBox(height: 12),
                  _etaCard(),
                  const SizedBox(height: 12),
                  _stats(),
                  const SizedBox(height: 15),
                  const Text(
                    'Status Updates',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _timeline(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topHeader() {
    return Container(
      color: AppColors.primaryMain,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              // child: InkWell(
              //   onTap: () => Navigator.pop(context),
              //   child: Container(
              //     width: 38,
              //     height: 38,
              //     decoration: BoxDecoration(
              //       color: Colors.white.withOpacity(.18),
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     child: const Icon(Icons.arrow_back, color: Colors.white),
              //   ),
              // ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF3843A0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tracking Number',
                  style: TextStyle(color: Color(0xFFB7BCE0), fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.trackingNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.from + '  ->  ' + widget.to,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _mapPreview(),
        ],
      ),
    );
  }

  Widget _mapPreview() {
    return Container(
      height: 160,
      width: double.infinity,
      color: const Color(0xFFE2E5F7),
      child: Stack(
        children: [
          Positioned(
            left: 65,
            right: 75,
            top: 90,
            child: CustomPaint(
              size: const Size(double.infinity, 40),
              painter: _RoutePainter(),
            ),
          ),
          Positioned(left: 48, top: 48, child: _mapDot(Colors.white, 8)),
          Positioned(
            right: 70,
            top: 104,
            child: _mapDot(const Color(0xFFFFC400), 13),
          ),
          Positioned(
            left: 148,
            top: 62,
            child: Container(
              width: 44,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF172786),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x44000000),
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Text('🏍️'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapDot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF172786), width: 1),
      ),
    );
  }

  Widget _riderCard() {
    return _card(
      Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFEFF0FF),
            child: const Text('👨', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.riderName + ' · 🏍️ ' + widget.vehicle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  widget.riderPhone + ' · ★ 4.8',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.call, size: 15),
            label: const Text('Call'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC400),
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _etaCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF0FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Arrival',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.eta,
                  style: const TextStyle(
                    color: Color(0xFF172786),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.calendar_month_outlined,
            size: 30,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _stats() {
    return Row(
      children: [
        Expanded(child: _stat('📦', widget.weight, 'Weight')),
        const SizedBox(width: 10),
        Expanded(child: _stat('🏍️', widget.vehicle, 'Vehicle')),
        const SizedBox(width: 10),
        Expanded(child: _stat('📍', widget.distance, 'Distance')),
      ],
    );
  }

  Widget _stat(String icon, String value, String label) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _timeline() {
    return Column(
      children: [
        _timelineItem(
          title: 'Booking Confirmed',
          subtitle: 'Payment received',
          time: '5:10 PM',
          state: _TimelineState.done,
        ),
        _timelineItem(
          title: 'Rider Assigned',
          subtitle: widget.riderName + ' on the way',
          time: '5:12 PM',
          state: _TimelineState.done,
        ),
        _timelineItem(
          title: 'Picked Up · En Route',
          subtitle: widget.from + ' collected',
          time: '5:28 PM · Now',
          state: _TimelineState.current,
        ),
        _timelineItem(
          title: 'Out for Delivery',
          subtitle: 'Approaching ' + widget.to,
          time: 'Expected 5:45 PM',
          state: _TimelineState.pending,
        ),
        _timelineItem(
          title: 'Delivered',
          subtitle: widget.to,
          time: 'Expected 5:50 PM',
          state: _TimelineState.pending,
          last: true,
        ),
      ],
    );
  }

  Widget _timelineItem({
    required String title,
    required String subtitle,
    required String time,
    required _TimelineState state,
    bool last = false,
  }) {
    final active = state != _TimelineState.pending;
    final color = state == _TimelineState.current
        ? const Color(0xFFFFC400)
        : const Color(0xFF202B91);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 32,
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? color : const Color(0xFFE1E2E8),
                  shape: BoxShape.circle,
                ),
                child: state == _TimelineState.done
                    ? const Icon(Icons.check, color: Colors.white, size: 15)
                    : state == _TimelineState.current
                    ? const Text(
                        '-',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              if (!last)
                Container(width: 1, height: 48, color: const Color(0xFFD9DAE1)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 19),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: active
                        ? const Color(0xFF202B91)
                        : Colors.grey.shade500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

enum _TimelineState { done, current, pending }

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9FA8D5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * .65, 0)
      ..quadraticBezierTo(size.width, 0, size.width, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
