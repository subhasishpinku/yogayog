import 'package:flutter/material.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/dashboard/dashboard_scren.dart';
import 'package:yogayog/homescreen/home_screen.dart';
import 'package:yogayog/core/services/payment_service.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingSuccess extends StatefulWidget {
  const BookingSuccess({super.key, this.order});

  final PaymentOrderResponse? order;

  @override
  State<BookingSuccess> createState() => _BookingSuccessState();
}

class _BookingSuccessState extends State<BookingSuccess> {
  static const _green = AppColors.primaryMain;
  static const _yellow = AppColors.primaryButton;

  void _backToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Dashboard()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 92, 18, 28),
          child: Column(
            children: [
              const _SuccessIcon(),
              const SizedBox(height: 20),
              const Text(
                'Booking Confirmed!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'Shipment booked on behalf of Rahul Das.\nRider will pickup before 4:00 PM today.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 21),
              _TrackingCard(orderId: widget.order?.orderId ?? ''),
              const SizedBox(height: 20),
              if (widget.order != null) ...[
                _InvoiceCard(order: widget.order!),
                const SizedBox(height: 20),
              ],
              // const _CommissionCard(),
              // const SizedBox(height: 21),
              SizedBox(
                width: double.infinity,
                height: 57,
                child: ElevatedButton(
                  onPressed: _backToHome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _yellow,
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
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessIcon extends StatelessWidget {
  const _SuccessIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5EF),
        shape: BoxShape.circle,
        border: Border.all(color: _BookingSuccessState._green, width: 3),
      ),
      child: Container(
        width: 58,
        height: 58,
        color: const Color(0xFF0ACB08),
        child: const Icon(Icons.check, color: Colors.white, size: 44),
      ),
    );
  }
}

class _TrackingCard extends StatelessWidget {
  const _TrackingCard({required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5EF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            'TRACKING ID',
            style: TextStyle(
              color: Color(0xFF7B8493),
              fontSize: 11,
              letterSpacing: .6,
            ),
          ),
          SizedBox(height: 4),
          Text(
            orderId.isEmpty ? 'Order created' : orderId,
            style: TextStyle(
              color: _BookingSuccessState._green,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.order});

  final PaymentOrderResponse order;

  Future<void> _downloadInvoice(BuildContext context) async {
    final uri = Uri.tryParse(order.invoiceUrl);
    if (uri == null || !await canLaunchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open invoice download link')),
        );
      }
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E2E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'INVOICE DETAILS',
            style: TextStyle(
              color: Color(0xFF667085),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: .6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Invoice: ${order.invoiceId.isEmpty ? '-' : order.invoiceId}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: order.invoiceUrl.isEmpty
                  ? null
                  : () => _downloadInvoice(context),
              icon: const Icon(Icons.download_outlined),
              label: const Text('Download Invoice'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButton,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommissionCard extends StatelessWidget {
  const _CommissionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF08743D), Color(0xFF10A65B)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        children: [
          Text(
            'COMMISSION EARNED',
            style: TextStyle(
              color: Color(0xFFB8DDC8),
              fontSize: 11,
              letterSpacing: .6,
            ),
          ),
          SizedBox(height: 3),
          Text(
            '₹89.00',
            style: TextStyle(
              color: AppColors.primaryButton,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            'Pending · Credited after delivery',
            style: TextStyle(color: Color(0xFFB8DDC8), fontSize: 11),
          ),
        ],
      ),
    );
  }
}
