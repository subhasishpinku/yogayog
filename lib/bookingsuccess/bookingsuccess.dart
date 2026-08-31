import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/dashboard/dashboard_scren.dart';
import 'package:yogayog/homescreen/home_screen.dart';
import 'package:yogayog/core/services/payment_service.dart';
import 'package:yogayog/paperworkrequired/paperwork_required.dart';
import 'package:yogayog/bookingsuccess/provider/bookingsuccess_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

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
                height: 57,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PaperworkRequired(),
                            ),
                          );
                        },
                        style: _actionButtonStyle(),
                        child: const Text('Upload'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _backToHome,
                        style: _actionButtonStyle(),
                        child: const Text('Back to Home'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ButtonStyle _actionButtonStyle() => ElevatedButton.styleFrom(
    backgroundColor: _yellow,
    foregroundColor: Colors.black,
    elevation: 0,
    minimumSize: const Size.fromHeight(57),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
  );
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

class _InvoiceCard extends StatefulWidget {
  const _InvoiceCard({required this.order});

  final PaymentOrderResponse order;

  @override
  State<_InvoiceCard> createState() => _InvoiceCardState();
}

class _InvoiceCardState extends State<_InvoiceCard> {
  final _provider = BookingSuccessProvider();

  Future<void> _downloadInvoice(BuildContext context) async {
    final orderId = int.tryParse(widget.order.orderId);
    if (orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order ID is unavailable for invoice')),
      );
      return;
    }
    final bytes = await _provider.downloadInvoice(orderId);
    if (!context.mounted) return;
    if (bytes != null) {
      final filePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Download invoice',
        fileName: 'invoice_$orderId.pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        bytes: Uint8List.fromList(bytes),
      );
      if (!context.mounted) return;
      if (filePath == null || filePath.isEmpty) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invoice downloaded: $filePath')));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_provider.errorMessage ?? 'Unable to download invoice'),
      ),
    );
  }

  Future<void> _shareInvoice(BuildContext context) async {
    final orderId = int.tryParse(widget.order.orderId);
    if (orderId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order ID is unavailable for invoice')),
        );
      }
      return;
    }
    final bytes = await _provider.downloadInvoice(orderId);
    if (!context.mounted) return;
    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_provider.errorMessage ?? 'Unable to download invoice'),
        ),
      );
      return;
    }
    final temporaryDirectory = await getTemporaryDirectory();
    final file = File('${temporaryDirectory.path}/invoice_$orderId.pdf');
    await file.writeAsBytes(bytes, flush: true);
    if (!context.mounted) return;
    await Share.shareXFiles(
      [
        XFile(
          file.path,
          mimeType: 'application/pdf',
          name: 'invoice_$orderId.pdf',
        ),
      ],
      text:
          'Invoice ${widget.order.invoiceId.isEmpty ? orderId : widget.order.invoiceId}',
    );
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
            'Invoice: ${widget.order.invoiceId.isEmpty ? '-' : widget.order.invoiceId}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _downloadInvoice(context),
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Download'),
                  style: _invoiceButtonStyle(),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _shareInvoice(context),
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('WhatsApp'),
                  style: _invoiceButtonStyle(
                    backgroundColor: const Color(0xFFE8F5EF),
                    foregroundColor: const Color(0xFF08743D),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ButtonStyle _invoiceButtonStyle({
    Color backgroundColor = AppColors.primaryButton,
    Color foregroundColor = Colors.black,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 0,
      minimumSize: const Size.fromHeight(48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
