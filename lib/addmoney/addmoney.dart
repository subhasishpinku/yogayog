import 'package:flutter/material.dart';
import 'package:yogayog/Payment/payment_screen.dart';
import 'package:yogayog/constants/app_colors.dart';

class Addmoney extends StatefulWidget {
  const Addmoney({super.key});

  @override
  State<Addmoney> createState() => _AddmoneyState();
}

class _AddmoneyState extends State<Addmoney> {
  final amountController = TextEditingController(text: '1000');
  int selectedAmount = 1000;

  @override
  void dispose() {
    amountController.dispose();
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
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _balance(),
                  const SizedBox(height: 16),
                  const Text(
                    'Quick Select',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (final amount in [500, 1000, 2000, 5000]) ...[
                        Expanded(child: _quickAmount(amount)),
                        if (amount != 5000) const SizedBox(width: 8),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ENTER TOP-UP AMOUNT',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixText: '₹ ',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    color: const Color(0xFFF0F1FF),
                    child: const Text(
                      '🔒  Payments via BillDesk — PCI DSS secured',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _proceed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryButton,
                        foregroundColor: AppColors.primaryBlue,
                      ),
                      child: const Text(
                        'Proceed to Payment →',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() => Container(
    width: double.infinity,
    color: AppColors.primaryMain,
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF4D59A7),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Wallet Top-up',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Text(
          'Securely add funds to your wallet',
          style: TextStyle(color: Color(0xFFD2D5FF)),
        ),
      ],
    ),
  );

  Widget _balance() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
    ),
    child: const Column(
      children: [
        Text(
          'CURRENT BALANCE',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '₹10,000.00',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );

  Widget _quickAmount(int amount) {
    final active = amount == selectedAmount;
    return OutlinedButton(
      onPressed: () => setState(() {
        selectedAmount = amount;
        amountController.text = '$amount';
      }),
      style: OutlinedButton.styleFrom(
        backgroundColor: active ? const Color(0xFFF0F1FF) : Colors.white,
        side: BorderSide(
          color: active ? AppColors.primaryBlue : Colors.transparent,
          width: 2,
        ),
        padding: const EdgeInsets.symmetric(vertical: 13),
      ),
      child: Text(
        '₹${amount.toString()}',
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _proceed() {
    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PaymentScreen(amount: amount)),
    );
  }
}
