import 'package:flutter/material.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/core/services/history_service.dart';
import 'package:yogayog/dashboard/dashboard_scren.dart';

class PickupRescheduled extends StatelessWidget {
  const PickupRescheduled({
    super.key,
    this.booking,
    this.date = 'Today',
    this.timeSlot = '7:00–7:30 PM',
    this.orderId = '',
    this.pickupDate = '',
    this.pickupTime = '',
  });

  final Booking? booking;
  final String date;
  final String timeSlot;
  final String orderId;
  final String pickupDate;
  final String pickupTime;

  String get orderNo =>
      booking?.orderNo.isNotEmpty == true ? booking!.orderNo : 'YCG-2025-00934';
  String get address => booking?.pickupCity.isNotEmpty == true
      ? booking!.pickupCity
      : 'Salt Lake, Kolkata';

  @override
  Widget build(BuildContext context) {
    const blue = AppColors.primaryMain;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: blue,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 82,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pickup rescheduled',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            Text(
              orderNo,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(6, 17, 6, 20),
        children: [
          _summaryCard(blue),
          const SizedBox(height: 16),
          _nextSteps(blue),
          const SizedBox(height: 30),
          SizedBox(
            height: 49,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const Dashboard()),
                  (route) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: blue,
                side: const BorderSide(color: blue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Back to Home',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(Color blue) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 21, 16, 14),
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
        children: [
          Container(
            width: 55,
            height: 55,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFE5F8E8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Color(0xFF0B9B42), size: 34),
          ),
          const SizedBox(height: 13),
          Text(
            'Your pickup is updated',
            style: TextStyle(
              color: blue,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'We’ll notify you when a rider is assigned',
            style: TextStyle(color: Color(0xFF667085), fontSize: 12),
          ),
          const SizedBox(height: 13),
          const Divider(height: 1, color: Color(0xFFE5E7ED)),
          _infoRow('New pickup time', '$date, $timeSlot', blue),
          const Divider(height: 1, color: Color(0xFFE5E7ED)),
          _infoRow('Pickup address', address, blue),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, Color blue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF667085), fontSize: 11),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: blue,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nextSteps(Color blue) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 13, 13, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECFF),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What happens next',
            style: TextStyle(
              color: blue,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Your driver will be assigned closer to the updated\npickup window. You can still reschedule or cancel\nfrom Profile.',
            style: TextStyle(color: blue, fontSize: 12, height: 1.45),
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order details'),
        content: Text(
          'Order: $orderNo\nPickup: $address\nTime: $date, $timeSlot',
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
}
