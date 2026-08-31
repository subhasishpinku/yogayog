import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yogayog/Payment/provider/payment_national_provider.dart';
import 'package:yogayog/bookingsuccess/bookingsuccess.dart';
import 'package:yogayog/constants/app_colors.dart';

class PaymentWalletNationalScreen extends StatelessWidget {
  const PaymentWalletNationalScreen({
    super.key,
    required this.amount,
    required this.currentBalance,
    required this.orderPayload,
  });

  final double amount;
  final double currentBalance;
  final Map<String, dynamic> orderPayload;

  Future<void> _payFromWallet(BuildContext context) async {
    final payload = Map<String, dynamic>.from(orderPayload)
      ..['payment_method'] = 'WALLET';
    final order = await context.read<PaymentNationalProvider>().createOrder(
      payload: payload,
    );
    if (!context.mounted) return;
    if (order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<PaymentNationalProvider>().errorMessage ??
                'Unable to complete wallet payment',
          ),
        ),
      );
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => BookingSuccess(order: order)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<PaymentNationalProvider>().isLoading;
    final balanceAfterPayment = currentBalance - amount;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4FA),
      appBar: AppBar(
        title: const Text('Wallet Payment'),
        backgroundColor: AppColors.primaryMain,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _balanceCard('Available Balance', currentBalance),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _row('Booking Amount', amount),
                const Divider(height: 24),
                _row('Balance After Payment', balanceAfterPayment),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : () => _payFromWallet(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryButton,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Pay ₹${amount.toStringAsFixed(2)} from Wallet'),
          ),
        ),
      ),
    );
  }

  Widget _balanceCard(String title, double value) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryMain,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            '₹${value.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String title, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.black54)),
        Text(
          '₹${value.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
