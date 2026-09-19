import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/core/services/home_service.dart';
import 'package:yogayog/disputes/claims.dart';
import 'package:yogayog/disputes/provider/disputes_provider.dart';

class ClaimsRefundScreen extends StatefulWidget {
  const ClaimsRefundScreen({
    super.key,
    this.orderNo = '',
    this.orderId = '',
    this.serviceName = 'Local Bike',
    this.subServiceName = 'Package issue',
    this.orderDate = 'Today, 5:00 PM',
    this.pickupCity = 'Jodhpur Park',
    this.dropCity = 'Park Street, Kolkata',
    this.status = 'In transit',
    this.amount = 149,
  });

  final String orderNo;
  final String orderId;
  final String serviceName;
  final String subServiceName;
  final String orderDate;
  final String pickupCity;
  final String dropCity;
  final String status;
  final double amount;

  @override
  State<ClaimsRefundScreen> createState() => _ClaimsRefundScreenState();
}

class _ClaimsRefundScreenState extends State<ClaimsRefundScreen> {
  static const Color _blue = AppColors.primaryMain;
  static const Color _background = Color(0xFFF5F6FA);
  static const Color _yellow = Color(0xFFFFC400);

  final _detailsController = TextEditingController();
  late final TextEditingController _orderNoController = TextEditingController(
    text: widget.orderNo,
  );
  final _provider = DisputesProvider();
  Timer? _trackingDebounce;
  TrackOrderData? _trackedOrder;
  int _selectedIssue = 0;

  @override
  void dispose() {
    _detailsController.dispose();
    _orderNoController.dispose();
    _trackingDebounce?.cancel();
    _provider.dispose();
    super.dispose();
  }

  void _onOrderNoChanged(String value) {
    _trackingDebounce?.cancel();
    _trackingDebounce = Timer(const Duration(milliseconds: 500), () async {
      final trackingNumber = value.trim();
      if (trackingNumber.isEmpty) {
        if (mounted) setState(() => _trackedOrder = null);
        return;
      }

      final order = await _provider.trackOrder(trackingNumber);
      if (!mounted || _orderNoController.text.trim() != trackingNumber) return;
      setState(() => _trackedOrder = order);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDelivered =
        (_trackedOrder?.status ?? widget.status).trim().toLowerCase() ==
        'delivered';
    const issueNames = ['Package issue', 'Delivery issue', 'Payment & refund'];
    const issueCodes = ['item_mismatch', 'not_received_shipment', 'damaged'];
    final selectedIssue = issueNames[_selectedIssue];
    final selectedIssueCode = issueCodes[_selectedIssue];

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 88,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Claims & Refunds',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 3),
            Text(
              'Choose an issue to start a claim',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(9, 15, 9, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _orderCard(),
            const SizedBox(height: 15),
            _protectionMessage(),
            const SizedBox(height: 38),
            _issueCard(
              0,
              Icons.inventory_2_outlined,
              'Package issue',
              'Damaged, missing or wrong item',
            ),
            const SizedBox(height: 8),
            _issueCard(
              1,
              Icons.watch_later_outlined,
              'Delivery issue',
              'Late, not delivered or wrong address',
            ),
            const SizedBox(height: 8),
            _issueCard(
              2,
              Icons.currency_rupee,
              'Payment & refund',
              'Charged twice, cancellation or refund status',
            ),
            const SizedBox(height: 17),
            const Text(
              'Tell us briefly',
              style: TextStyle(
                color: _blue,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            TextField(
              controller: _detailsController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe what happened...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE1E4EC)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE1E4EC)),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(9, 7, 9, 9),
        child: ElevatedButton(
          onPressed: () async {
            if (!isDelivered) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'You can continue after the order is delivered.',
                  ),
                ),
              );
              return;
            }

            if (selectedIssue == 'Payment & refund') {
              final id = int.tryParse(
                widget.orderId.isEmpty ? widget.orderNo : widget.orderId,
              );
              if (id == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order ID is unavailable')),
                );
                return;
              }

              final submitted = await _provider.submitIssue(
                orderId: id,
                issue: selectedIssueCode,
                description: _detailsController.text.trim().isEmpty
                    ? 'Issue submitted from the app'
                    : _detailsController.text.trim(),
                photos: const [],
              );
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    submitted
                        ? 'Payment issue submitted successfully'
                        : (_provider.errorMessage ??
                              'Unable to submit payment issue'),
                  ),
                ),
              );
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Claims(
                  orderNo: widget.orderNo,
                  orderId: widget.orderId.isEmpty
                      ? widget.orderNo
                      : widget.orderId,
                  issue: selectedIssueCode,
                  description: _detailsController.text.trim(),
                  amount: widget.amount,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _blue,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            isDelivered ? 'Continue to evidence →' : 'Available after delivery',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }

  Widget _orderCard() {
    return Container(
      padding: const EdgeInsets.all(14),
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
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFECEFDF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.delivery_dining, color: _blue),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _orderNoController,
                      onChanged: _onOrderNoChanged,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                      decoration: const InputDecoration(
                        hintText: 'Enter order number',
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              _statusChip(),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${widget.pickupCity}  →  ${widget.dropCity}',
              style: TextStyle(
                color: _blue,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _yellow.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _trackedOrder?.status ?? widget.status,
        style: TextStyle(
          color: Color(0xFF806500),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _protectionMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECFF),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What happened?',
            style: TextStyle(color: _blue, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 5),
          Text(
            'Your order stays protected while we review your request.',
            style: TextStyle(color: _blue, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _issueCard(int index, IconData icon, String title, String subtitle) {
    final selected = _selectedIssue == index;
    return InkWell(
      onTap: () => setState(() => _selectedIssue = index),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF7F8FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _blue : const Color(0xFFE1E4EC),
            width: selected ? 1.2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87, size: 22),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? _blue : const Color(0xFFC4CBD9),
              size: 23,
            ),
          ],
        ),
      ),
    );
  }
}
