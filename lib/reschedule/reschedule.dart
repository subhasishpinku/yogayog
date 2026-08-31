import 'package:flutter/material.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/core/services/history_service.dart';
import 'package:yogayog/reschedule/reschedule_pickup.dart';

class Reschedule extends StatefulWidget {
  const Reschedule({super.key, this.booking});

  final Booking? booking;

  @override
  State<Reschedule> createState() => _RescheduleState();
}

class _RescheduleState extends State<Reschedule> {
  static const _blue = AppColors.primaryMain;
  static const _background = Color(0xFFF5F6FA);

  Booking? get _booking => widget.booking;
  String get _orderNo => _booking?.orderNo.isNotEmpty == true
      ? _booking!.orderNo
      : 'YCG-2025-00934';
  String get _service => _booking?.serviceName.isNotEmpty == true
      ? _booking!.serviceName
      : 'Local Bike';
  String get _date => _booking?.orderDate.isNotEmpty == true
      ? _booking!.orderDate
      : 'Pickup today, 6:00–6:30 PM';
  String get _pickup => _booking?.pickupCity.isNotEmpty == true
      ? _booking!.pickupCity
      : 'Salt Lake';
  String get _drop => _booking?.dropCity.isNotEmpty == true
      ? _booking!.dropCity
      : 'New Town, Kolkata';
  String get _status =>
      _booking?.status.isNotEmpty == true ? _booking!.status : 'Scheduled';
  String get _amount => '₹${(_booking?.amount ?? 119).toStringAsFixed(0)}';
  String get _payment =>
      _booking?.paymentDone == true ? 'Prepaid' : 'Payment pending';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 84,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming pickups',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 3),
            Text(
              'Manage your scheduled orders',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(6, 16, 6, 20),
        children: [
          _pickupCard(),
          const SizedBox(height: 30),
          _notice(),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _chooseNewTime,
              style: _buttonStyle(),
              child: const Text(
                'Reschedule pickup',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: _confirmCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: _blue,
                side: const BorderSide(color: _blue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancel order',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pickupCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 43,
                height: 43,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9EDFF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Text('🏍️', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _orderNo,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      '$_service · $_date',
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 10,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              _pill(_status, const Color(0xFFFFF3C4), const Color(0xFF806500)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '$_pickup  →  $_drop',
            style: const TextStyle(
              color: _blue,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 11),
          const Divider(height: 1, color: Color(0xFFE5E7ED)),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '$_amount · $_payment',
                style: const TextStyle(color: Color(0xFF667085), fontSize: 10),
              ),
              const Spacer(),
              _link('View details'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _notice() {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 13, 13, 11),
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECFF),
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Need a different time?',
            style: TextStyle(
              color: _blue,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'You can change your pickup until 30 minutes\nbefore the scheduled slot.',
            style: TextStyle(color: _blue, fontSize: 12, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _link(String text) {
    return InkWell(
      onTap: _showDetails,
      child: Text(
        text,
        style: const TextStyle(
          color: _blue,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  void _showDetails() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pickup details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Order', _orderNo),
            _detailRow('Service', _service),
            _detailRow('Pickup time', _date),
            _detailRow('Route', '$_pickup → $_drop'),
            _detailRow('Amount', '$_amount · $_payment'),
            _detailRow('Status', _status),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Color(0xFF667085), fontSize: 12),
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle() => ElevatedButton.styleFrom(
    backgroundColor: _blue,
    foregroundColor: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  void _chooseNewTime() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReschedulePickup(booking: widget.booking),
      ),
    );
  }

  Future<void> _confirmCancel() async {
    final cancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel order?'),
        content: const Text(
          'Are you sure you want to cancel this scheduled pickup?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep order'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel order'),
          ),
        ],
      ),
    );
    if (cancel == true && mounted) _showMessage('Order cancellation requested');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
