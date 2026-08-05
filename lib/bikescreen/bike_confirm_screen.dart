import 'package:flutter/material.dart';
import 'package:yogayog/Payment/payment_screen.dart';
import 'package:yogayog/constants/app_colors.dart';

class BikeConfirmScreem extends StatefulWidget {
  const BikeConfirmScreem({super.key});

  @override
  State<BikeConfirmScreem> createState() => _BikeConfirmScreemState();
}

class _BikeConfirmScreemState extends State<BikeConfirmScreem> {
  static const Color blue = AppColors.primaryMain;
  static const Color yellow = AppColors.primaryButton;

  final instructionController = TextEditingController();

  @override
  void dispose() {
    instructionController.dispose();
    super.dispose();
  }

  void _proceedToPayment() {
    // এখানে PaymentScreen-এ navigation করুন
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Proceeding to payment')));
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PaymentScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSteps(),

                    const SizedBox(height: 18),

                    _buildSummaryCard(),

                    const SizedBox(height: 12),

                    const Text(
                      'DELIVERY INSTRUCTIONS (OPTIONAL)',
                      style: TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: .6,
                      ),
                    ),

                    const SizedBox(height: 6),

                    TextField(
                      controller: instructionController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText: 'e.g. Call on arrival, leave at gate...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF8A8F9C),
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _proceedToPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: yellow,
                          foregroundColor: blue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Proceed to Payment →',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 162,
      width: double.infinity,
      color: blue,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'Confirm Booking',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 3),

          const Text(
            'Review before paying',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSteps() {
    return Row(
      children: [
        _step('✓', 'Address', true),
        _line(),
        _step('✓', 'Vehicle', true),
        _line(),
        _step('3', 'Confirm', true),
      ],
    );
  }

  Widget _step(String number, String title, bool active) {
    return Column(
      children: [
        Container(
          width: 27,
          height: 27,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: number == '3' ? yellow : blue,
          ),
          child: Text(
            number,
            style: TextStyle(
              color: number == '3' ? blue : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 5),

        Text(
          title,
          style: TextStyle(
            color: active ? blue : Colors.grey,
            fontSize: 10,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _line() {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: blue,
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 7, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          _summaryRow('From', 'Jodhpur Park, Kolkata'),
          _summaryRow('To', 'Park Street, Kolkata'),
          _summaryRow('Vehicle', '🏍 Bike'),
          _summaryRow('Package', 'Documents · 2 kg'),
          _summaryRow('Pickup', 'Now (~15 min)'),
          _summaryRow('Base Fare', '₹99'),
          _summaryRow('Distance Charge', '₹42'),
          _summaryRow('GST (18%)', '₹8'),

          const Divider(height: 18),

          Row(
            children: const [
              Text(
                'Total',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Text(
                '₹149',
                style: TextStyle(
                  color: blue,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(color: Color(0xFF8A8F9C), fontSize: 12),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF202020),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
