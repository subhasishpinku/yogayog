import 'package:flutter/material.dart';
import 'package:yogayog/Payment/payment_screen.dart';
import 'package:yogayog/constants/app_colors.dart';

class ConfirmOrder extends StatefulWidget {
  const ConfirmOrder({
    super.key,
    this.courierName = 'Delhivery',
    this.courierCode = 'DLVRY',
    this.serviceName = 'Express',
    this.origin = 'Kolkata, WB',
    this.destination = 'New Delhi',
    this.receiverName = 'Vikram Singh',
    this.weightKg = 5.2,
    this.freight = 215,
    this.fuelSurcharge = 18,
    this.gst = 65,
    this.total = 298,
    this.deliveryDate = 'Delivery in 3-4 days',
  });

  final String courierName;
  final String courierCode;
  final String serviceName;
  final String origin;
  final String destination;
  final String receiverName;
  final double weightKg;
  final double freight;
  final double fuelSurcharge;
  final double gst;
  final double total;
  final String deliveryDate;

  @override
  State<ConfirmOrder> createState() => _ConfirmOrderState();
}

class _ConfirmOrderState extends State<ConfirmOrder> {
  final instructionController = TextEditingController();

  @override
  void dispose() {
    instructionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4FA),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _courierSummary(),
                    const SizedBox(height: 14),
                    _priceDetails(),
                    const SizedBox(height: 14),
                    _notice(),
                    const SizedBox(height: 16),
                    const Text(
                      'DELIVERY INSTRUCTIONS (OPTIONAL)',
                      style: TextStyle(
                        color: Color(0xFF6B6B73),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 7),
                    TextField(
                      controller: instructionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'e.g. Fragile, call before delivery',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _confirmButton(),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      color: AppColors.primaryMain,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Confirm Order',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${widget.courierName} - ${widget.serviceName}',
            style: const TextStyle(color: Color(0xFFB7BCE0)),
          ),
        ],
      ),
    );
  }

  Widget _courierSummary() {
    return _card(
      Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFF424A),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(
              widget.courierCode,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.courierName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.deliveryDate,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          _badge('Cheapest', const Color(0xFFE3F7E7)),
        ],
      ),
    );
  }

  Widget _priceDetails() {
    return _card(
      Column(
        children: [
          _row('From', widget.origin),
          _row('To', widget.destination),
          _row('Receiver', widget.receiverName),
          _row('Courier', '${widget.courierName} ${widget.serviceName}'),
          _row('Weight', '${widget.weightKg.toStringAsFixed(1)} kg'),
          _row('Freight', 'Rs ${widget.freight.toStringAsFixed(0)}'),
          _row(
            'Fuel Surcharge',
            'Rs ${widget.fuelSurcharge.toStringAsFixed(0)}',
          ),
          _row('GST (18%)', 'Rs ${widget.gst.toStringAsFixed(0)}'),
          const Divider(),
          _row(
            'Total',
            'Rs ${widget.total.toStringAsFixed(0)}',
            bold: true,
            color: const Color(0xFF172786),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: bold ? Colors.black : Colors.grey.shade600,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: bold ? 20 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _notice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF0FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'AWB number and tracking link will be sent via SMS '
        'after pickup is scheduled.',
        style: TextStyle(color: Color(0xFF172786), fontSize: 12),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
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

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF23822E),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _confirmButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          height: 54,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order confirmed successfully')),
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentScreen(amount: widget.total),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC400),
              foregroundColor: const Color(0xFF172786),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(
              'CONFIRM - ${widget.courierName.toUpperCase()}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
