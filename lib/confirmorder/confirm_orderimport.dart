import 'package:flutter/material.dart';
import 'package:yogayog/Payment/payment_national_Import_wallet_screen.dart';
import 'package:yogayog/Payment/payment_national_import_screen.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/core/services/viewledger_service.dart';

class ConfirmOrderImport extends StatefulWidget {
  const ConfirmOrderImport({
    super.key,
    this.courierName = 'Delhivery',
    this.courierCode = 'DLVRY',
    this.serviceName = 'Express',
    this.origin = '',
    this.destination = '',
    this.receiverName = '',
    this.weightKg = 5.2,
    this.freight = 215,
    this.fuelSurcharge = 18,
    this.gst = 65,
    this.total = 298,
    this.deliveryDate = 'Delivery in 3-4 days',
    this.orderPayload = const {},
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
  final Map<String, dynamic> orderPayload;

  @override
  State<ConfirmOrderImport> createState() => _ConfirmOrderState();
}

class _ConfirmOrderState extends State<ConfirmOrderImport> {
  final instructionController = TextEditingController();
  bool _checkingWallet = false;

  Map<String, dynamic> get _pickup {
    final value = widget.orderPayload['pickup'];
    return value is Map ? Map<String, dynamic>.from(value) : {};
  }

  Map<String, dynamic> get _drop {
    final value = widget.orderPayload['drop'];
    return value is Map ? Map<String, dynamic>.from(value) : {};
  }

  String _payloadText(Map<String, dynamic> data, String key) {
    return data[key]?.toString().trim() ?? '';
  }

  String _locationText(Map<String, dynamic> data, String fallback) {
    final parts = [
      _payloadText(data, 'address'),
      _payloadText(data, 'city'),
      _payloadText(data, 'pincode'),
    ].where((part) => part.isNotEmpty).toList();
    return parts.isEmpty ? fallback : parts.join(', ');
  }

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
                    // _notice(),
                    // const SizedBox(height: 16),
                    // const Text(
                    //   'DELIVERY INSTRUCTIONS (OPTIONAL)',
                    //   style: TextStyle(
                    //     color: Color(0xFF6B6B73),
                    //     fontSize: 12,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    // const SizedBox(height: 7),
                    // TextField(
                    //   controller: instructionController,
                    //   maxLines: 3,
                    //   decoration: InputDecoration(
                    //     hintText: 'e.g. Fragile, call before delivery',
                    //     filled: true,
                    //     fillColor: Colors.white,
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(15),
                    //       borderSide: BorderSide.none,
                    //     ),
                    //   ),
                    // ),
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
                'Confirm Order',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
          _row('From', _locationText(_pickup, widget.origin)),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            initiallyExpanded: false,
            title: const Text(
              'View order details',
              style: TextStyle(
                color: Color(0xFF172786),
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Total Rs ${widget.total.toStringAsFixed(0)}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            children: [
              _row('To', _locationText(_drop, widget.destination)),
              _row(
                'Pickup',
                '${_payloadText(_pickup, 'name')} ${_payloadText(_pickup, 'mobile')}'
                    .trim(),
              ),
              _row(
                'Drop',
                '${_payloadText(_drop, 'name')} ${_payloadText(_drop, 'mobile')}'
                    .trim(),
              ),
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
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: bold ? Colors.black : Colors.grey.shade600,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 16 : 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              textAlign: TextAlign.end,
              maxLines: bold ? 1 : 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color ?? Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: bold ? 20 : 14,
              ),
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
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // _commissionCard(),
            // const SizedBox(height: 10),
            // _documentNotice(),
            const SizedBox(height: 12),
            Row(
              children: [
                // Expanded(
                //   child: SizedBox(
                //     height: 80,
                //     child: OutlinedButton.icon(
                //       onPressed: () {
                //         ScaffoldMessenger.of(context).showSnackBar(
                //           const SnackBar(
                //             content: Text('Document checklist is ready.'),
                //           ),
                //         );
                //       },
                //       icon: const Text('📄', style: TextStyle(fontSize: 20)),
                //       label: const Text(
                //         'Check Docs',
                //         style: TextStyle(
                //           color: AppColors.primaryMain,
                //           fontSize: 17,
                //           fontWeight: FontWeight.w800,
                //         ),
                //       ),
                //       style: OutlinedButton.styleFrom(
                //         backgroundColor: const Color(0xFFE8F5EF),
                //         side: BorderSide.none,
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(15),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                // const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _checkingWallet ? null : _proceedToPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC400),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _checkingWallet
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Confirm Booking',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _proceedToPayment() async {
    setState(() => _checkingWallet = true);
    final payload = {...widget.orderPayload, 'price': widget.total};

    try {
      final ledger = await ViewledgerService().getLedger();
      if (!mounted) return;
      final destination = ledger.currentBalance >= widget.total
          ? PaymentWalletNationalImportWalletScreen(
              amount: widget.total,
              currentBalance: ledger.currentBalance,
              orderPayload: payload,
            )
          : PaymentNationalScreenImport(
              amount: widget.total,
              orderPayload: payload,
            );
      Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
    } on ViewledgerException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _checkingWallet = false);
    }
  }

  Widget _commissionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B8048),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR COMMISSION',
                  style: TextStyle(
                    color: Color(0xFFB8DDC8),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .5,
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
                  '8% · Credited after delivery',
                  style: TextStyle(color: Color(0xFFB8DDC8), fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            width: 43,
            height: 43,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primaryButton,
              shape: BoxShape.circle,
            ),
            child: const Text('💰', style: TextStyle(fontSize: 23)),
          ),
        ],
      ),
    );
  }

  Widget _documentNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5EF),
        border: Border.all(color: const Color(0xFFB5DCC7)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        '📋 Ensure customer has signed the Consignment\nNote. Check required docs before rider pickup.',
        style: TextStyle(
          color: AppColors.primaryMain,
          fontSize: 12,
          height: 1.4,
        ),
      ),
    );
  }
}
