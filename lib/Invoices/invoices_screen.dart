import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:yogayog/bookscreen/book_screen.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/core/services/invoices_service.dart';
import 'package:yogayog/history/history_screen.dart';
import 'package:yogayog/homescreen/home_screen.dart';
import 'package:yogayog/more/tools_information.dart';
import 'package:yogayog/profile/profile_screen.dart';
import 'package:yogayog/trackscreen/track_screen.dart';
import 'package:yogayog/Invoices/provider/invoices_provider.dart';
import 'package:yogayog/core/services/invoices_service.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<InvoicesProvider>().loadInvoices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4FA),
      body: SafeArea(
        child: Column(
          children: [
            Consumer<InvoicesProvider>(
              builder: (_, provider, __) =>
                  _summaryHeader(provider.pendingCount),
            ),
            Expanded(
              child: Consumer<InvoicesProvider>(
                builder: (_, provider, __) {
                  if (provider.isLoading && provider.invoices.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.errorMessage != null &&
                      provider.invoices.isEmpty) {
                    return _stateMessage(
                      provider.errorMessage!,
                      onRetry: provider.loadInvoices,
                    );
                  }
                  if (provider.invoices.isEmpty) {
                    return _stateMessage('No invoices found');
                  }
                  return RefreshIndicator(
                    onRefresh: provider.loadInvoices,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                      itemCount: provider.invoices.length + 1,
                      separatorBuilder: (_, index) => index == 0
                          ? const SizedBox(height: 10)
                          : const SizedBox(height: 12),
                      itemBuilder: (_, index) {
                        if (index == 0) {
                          return const Text(
                            'All Invoices',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                        final invoice = provider.invoices[index - 1];
                        return _invoiceCard(
                          invoiceId: invoice.id,
                          id: invoice.invoiceId.isEmpty
                              ? '#${invoice.id}'
                              : invoice.invoiceId,
                          order: invoice.orderId,
                          date: _formatDate(
                            invoice.createdAt,
                            invoice.pickupDate,
                          ),
                          type: _invoiceType(invoice),
                          senderAddress:
                              'From location #${invoice.fromLocationId}',
                          receiver: null,
                          receiverAddress: null,
                          amount: invoice.amount == null
                              ? '—'
                              : '₹${invoice.amount!.toStringAsFixed(2)}',
                          status: invoice.paymentStatus,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            // _bottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _summaryHeader(int pendingCount) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
    color: AppColors.primaryMain,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            const SizedBox(width: 4),
            const Text(
              'Invoices',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F1FF),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Column(
            children: [
              const Text(
                'Pending',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
              Text(
                '$pendingCount',
                style: TextStyle(
                  color: Color(0xFF9A7800),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _stateMessage(String message, {VoidCallback? onRetry}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 10),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }

  String _formatDate(String createdAt, String pickupDate) {
    final value = createdAt.isNotEmpty ? createdAt : pickupDate;
    return value.replaceFirst(' ', ' • ');
  }

  String _invoiceType(InvoiceData invoice) {
    if (invoice.serviceId == 7) return '🌐 International';
    if (invoice.serviceId == 4) return '🚚 National';
    return '🏍️ Local Delivery';
  }

  Widget _invoiceCard({
    required int invoiceId,
    required String id,
    required String order,
    required String date,
    required String type,
    required String senderAddress,
    required String? receiver,
    required String? receiverAddress,
    required String amount,
    required String status,
  }) => Container(
    padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    id,
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Order: $order • $date',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
            _statusBadge(status),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          type,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _person('📤', 'SENDER', 'Santanu Roy', senderAddress),
        if (receiver != null) ...[
          const Divider(height: 22),
          _person('📍', 'RECEIVER', receiver, receiverAddress!),
        ],
        const Divider(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
                Text(
                  amount,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (receiver != null)
                  const Text(
                    'Payment: COD',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
              ],
            ),
            TextButton.icon(
              onPressed: () => _downloadInvoicePdf(
                invoiceId: invoiceId,
                id: id,
                order: order,
                date: date,
                type: type,
                senderAddress: senderAddress,
                receiver: receiver,
                receiverAddress: receiverAddress,
                amount: amount,
              ),
              icon: const Icon(Icons.download, size: 16),
              label: const Text('PDF'),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF0F1FF),
                foregroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _statusBadge(String status) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF5CC),
      borderRadius: BorderRadius.circular(13),
    ),
    child: Text(
      status.isEmpty ? 'Unknown' : status,
      style: const TextStyle(
        color: Color(0xFF9A7800),
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _person(String icon, String label, String name, String address) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(icon, style: const TextStyle(fontSize: 15)),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            Text(
              address,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Future<void> _downloadInvoicePdf({
    required int invoiceId,
    required String id,
    required String order,
    required String date,
    required String type,
    required String senderAddress,
    required String? receiver,
    required String? receiverAddress,
    required String amount,
  }) async {
    try {
      final bytes = await context.read<InvoicesProvider>().downloadInvoice(
        invoiceId,
      );
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Save invoice PDF from server',
        fileName:
            'invoice_${order.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')}.pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        bytes: Uint8List.fromList(bytes),
      );
      if (!mounted) return;
      _message(
        path == null ? 'PDF download cancelled' : 'PDF saved successfully',
      );
    } on InvoicesException catch (error) {
      if (mounted) _message(error.message);
    } catch (_) {
      if (mounted) _message('Unable to download invoice PDF');
    }
  }

  Widget _bottomNavigation() => BottomNavigationBar(
    currentIndex: 3,
    onTap: (index) {
      final pages = [
        const HomeScreen(),
        // const BookScreen(),
        const TrackScreen(),
        const HistoryScreen(),
        const ToolInformation(),
      ];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => pages[index]),
      );
    },
    type: BottomNavigationBarType.fixed,
    backgroundColor: Colors.white,
    selectedItemColor: const Color(0xFF1F2A8A),
    unselectedItemColor: Colors.grey,
    selectedFontSize: 10,
    unselectedFontSize: 10,
    items: [
      _navItem('assets/images/home.png', 'Home'),
      // _navItem('assets/images/book.png', 'Book'),
      _navItem('assets/images/track.png', 'Track'),
      _navItem('assets/images/history.png', 'History'),
      _navItem('assets/images/more.png', 'More'),
    ],
  );

  BottomNavigationBarItem _navItem(String path, String label) =>
      BottomNavigationBarItem(
        icon: Image.asset(path, width: 24, height: 24),
        activeIcon: Image.asset(path, width: 24, height: 24),
        label: label,
      );

  void _message(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}
