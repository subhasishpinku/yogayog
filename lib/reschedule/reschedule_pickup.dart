import 'package:flutter/material.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/core/services/history_service.dart';
import 'package:yogayog/reschedule/pickup_rescheduled.dart';
import 'package:yogayog/reschedule/provider/pickup_rescheduled_provider.dart';

class ReschedulePickup extends StatefulWidget {
  const ReschedulePickup({super.key, this.booking});

  final Booking? booking;

  @override
  State<ReschedulePickup> createState() => _ReschedulePickupState();
}

class _ReschedulePickupState extends State<ReschedulePickup> {
  static const _blue = AppColors.primaryMain;
  static const _background = Color(0xFFF5F6FA);

  int _selectedDate = 0;
  int _selectedSlot = 1;
  final _rescheduleProvider = PickupRescheduledProvider();

  String get _orderNo => widget.booking?.orderNo.isNotEmpty == true
      ? widget.booking!.orderNo
      : 'YCG-2025-00934';

  DateTime get _firstPickupDate => DateTime.now();
  DateTime get _secondPickupDate => DateTime.now().add(const Duration(days: 1));
  DateTime get _thirdPickupDate => DateTime.now().add(const Duration(days: 2));

  DateTime get _selectedPickupDate =>
      [_firstPickupDate, _secondPickupDate, _thirdPickupDate][_selectedDate];

  String _fullDate(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  String _shortDay(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }

  String _apiDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _blue,
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
              'Reschedule pickup',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            Text(
              _orderNo,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(8, 18, 8, 20),
        children: [
          const Text(
            'Select a new date',
            style: TextStyle(
              color: Color(0xFF667085),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          _dateCard(
            0,
            _shortDay(_firstPickupDate),
            _fullDate(_firstPickupDate),
            'Available slots until 8:00 PM',
          ),
          const SizedBox(height: 9),
          _dateCard(
            1,
            _shortDay(_secondPickupDate),
            _fullDate(_secondPickupDate),
            'All day availability',
          ),
          const SizedBox(height: 9),
          _dateCard(
            2,
            _shortDay(_thirdPickupDate),
            _fullDate(_thirdPickupDate),
            'All day availability',
          ),
          const SizedBox(height: 17),
          const Text(
            'Available time slots',
            style: TextStyle(
              color: Color(0xFF667085),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 9,
            mainAxisSpacing: 9,
            childAspectRatio: 1.9,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _slotCard(0, '6:30–7 PM', 'Recommended'),
              _slotCard(1, '7–7:30 PM', 'Selected'),
              _slotCard(2, '7:30–8 PM', 'Available'),
              _slotCard(3, '8–8:30 PM', 'Available'),
            ],
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.fromLTRB(13, 11, 13, 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5CC),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rescheduling is free.',
                  style: TextStyle(
                    color: Color(0xFF735A00),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Driver assignment will be refreshed after confirmation.',
                  style: TextStyle(color: Color(0xFF735A00), fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(8, 11, 8, 10),
        child: SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: _reviewPickup,
            style: ElevatedButton.styleFrom(
              backgroundColor: _blue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Review new pickup time →',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dateCard(int index, String day, String date, String subtitle) {
    final selected = _selectedDate == index;
    return InkWell(
      onTap: () => setState(() => _selectedDate = index),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF8F9FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? _blue : const Color(0xFFE1E4EC)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 42,
              child: Text(day, style: const TextStyle(fontSize: 14)),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? _blue : const Color(0xFFC4CBD9),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _slotCard(int index, String time, String label) {
    final selected = _selectedSlot == index;
    return InkWell(
      onTap: () => setState(() => _selectedSlot = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF0F1FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? _blue : const Color(0xFFE1E4EC)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              time,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Text(
              selected ? 'Selected' : label,
              style: TextStyle(
                color: selected ? _blue : const Color(0xFF667085),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _reviewPickup() {
    final selectedDate = _selectedPickupDate;
    final date = _fullDate(selectedDate);
    const slots = ['6:30–7 PM', '7–7:30 PM', '7:30–8 PM', '8–8:30 PM'];
    const apiTimes = ['18:30', '19:00', '19:30', '20:00'];
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Review pickup time'),
        content: Text('$date · ${slots[_selectedSlot]}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go back'),
          ),
          ElevatedButton(
            onPressed: () async {
              final orderId = widget.booking?.orderId.trim() ?? '';
              if (orderId.isEmpty) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Order ID is unavailable')),
                );
                return;
              }
              final success = await _rescheduleProvider.reschedulePickup(
                orderId: orderId,
                pickupDate: _apiDate(selectedDate),
                pickupTime: apiTimes[_selectedSlot],
              );
              if (!mounted) return;
              if (!success) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _rescheduleProvider.errorMessage ??
                          'Unable to reschedule pickup',
                    ),
                  ),
                );
                return;
              }
              Navigator.pop(context);
              Navigator.pushReplacement(
                this.context,
                MaterialPageRoute(
                  builder: (_) => PickupRescheduled(
                    booking: widget.booking,
                    date: _fullDate(selectedDate),
                    timeSlot: slots[_selectedSlot],
                    orderId: orderId,
                    pickupDate: _apiDate(selectedDate),
                    pickupTime: apiTimes[_selectedSlot],
                  ),
                ),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
