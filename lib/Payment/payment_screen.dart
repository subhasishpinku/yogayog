import 'package:flutter/material.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/bookingsuccess/bookingsuccess.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, this.amount = 149});

  final double amount;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? selectedMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4FA),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _securityNotice(),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Payment Method',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  _paymentMethods(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (selectedMethod == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a payment method'),
                    ),
                  );
                  return;
                }
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const BookingSuccess()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButton,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                textStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: const Text('Process Payment →'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      color: AppColors.primaryMain,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              const SizedBox(width: 12),
              const Text(
                'Payment',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          const Text(
            'Secured by BillDesk',
            style: TextStyle(color: Color(0xFFB7BCE0), fontSize: 14),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF303B9D),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Amount Due',
                        style: TextStyle(
                          color: Color(0xFFB7BCE0),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Rs ' + widget.amount.toStringAsFixed(2),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC400),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.credit_card,
                    color: Colors.black,
                    size: 25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _securityNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF0FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: Colors.black, size: 25),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(color: Color(0xFF6B6B73), fontSize: 12),
                children: [
                  TextSpan(text: 'Payments processed by '),
                  TextSpan(
                    text: 'BillDesk',
                    style: TextStyle(
                      color: Color(0xFF172786),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' - 256-bit SSL encryption, PCI DSS compliant.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentMethods() {
    return Container(
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
      child: Column(
        children: [
          _paymentTile(
            icon: Icons.phone_android,
            iconColor: Colors.cyan,
            title: 'Online UPI Payment',
            subtitle: 'GPay, PhonePe, Paytm, any UPI ID',
            method: 'UPI',
          ),
          _divider(),
          _paymentTile(
            icon: Icons.credit_card,
            iconColor: Colors.orange,
            title: 'Wallet',
            subtitle: 'Visa, Mastercard, RuPay',
            method: 'Card',
          ),
          // _divider(),
          // _paymentTile(
          //   icon: Icons.account_balance,
          //   iconColor: Colors.green,
          //   title: 'Net Banking',
          //   subtitle: 'All major Indian banks',
          //   method: 'Net Banking',
          // ),
          _divider(),
          _paymentTile(
            icon: Icons.money,
            iconColor: Colors.amber,
            title: 'Cash on Delivery',
            subtitle: 'Pay at pickup',
            method: 'Cash on Delivery',
          ),
        ],
      ),
    );
  }

  Widget _paymentTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String method,
  }) {
    final selected = selectedMethod == method;

    return InkWell(
      onTap: () {
        setState(() {
          selectedMethod = method;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$method selected')));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.chevron_right,
              color: selected ? const Color(0xFF172786) : Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: Colors.grey.shade200,
      indent: 16,
      endIndent: 16,
    );
  }
}
