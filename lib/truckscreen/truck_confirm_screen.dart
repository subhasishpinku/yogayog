import 'package:flutter/material.dart';
import 'package:yogayog/Payment/Payment_wallet_Screen.dart';
import 'package:yogayog/Payment/payment_screen.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/core/services/truck_local_service.dart';
import 'package:yogayog/core/services/viewledger_service.dart';

class TruckConfirmScreen extends StatefulWidget {
  const TruckConfirmScreen({
    super.key,
    required this.rate,
    required this.distance,
    required this.pickup,
    required this.drop,
    this.pickupAddress = '',
    this.dropAddress = '',
    this.approximateWeightKg = 0,
    this.volumetricWeightKg = 0,
  });

  final TruckVehicleRate rate;
  final double distance;
  final Map<String, dynamic> pickup;
  final Map<String, dynamic> drop;
  final String pickupAddress;
  final String dropAddress;
  final double approximateWeightKg;
  final double volumetricWeightKg;

  @override
  State<TruckConfirmScreen> createState() => _TruckConfirmScreenState();
}

class _TruckConfirmScreenState extends State<TruckConfirmScreen> {
  static const Color blue = AppColors.primaryMain;
  static const Color yellow = AppColors.primaryButton;

  final instructionController = TextEditingController();
  bool _isCheckingWallet = false;

  double get totalWeight =>
      widget.approximateWeightKg > widget.volumetricWeightKg
      ? widget.approximateWeightKg
      : widget.volumetricWeightKg;

  String _locationValue(
    Map<String, dynamic> location,
    String key,
    String fallback,
  ) {
    final value = location[key]?.toString().trim() ?? '';
    return value.isEmpty ? fallback : value;
  }

  String _cityPin(Map<String, dynamic> location) {
    final city = location['city']?.toString().trim() ?? '';
    final pin = location['pincode']?.toString().trim() ?? '';
    final parts = [
      city,
      if (pin.isNotEmpty) 'PIN $pin',
    ].where((part) => part.isNotEmpty).toList();
    return parts.isEmpty ? 'Not provided' : parts.join(' · ');
  }

  @override
  void dispose() {
    instructionController.dispose();
    super.dispose();
  }

  Future<void> _proceedToPayment() async {
    if (_isCheckingWallet) return;
    setState(() => _isCheckingWallet = true);

    final orderPayload = <String, dynamic>{
      'order_type': 'local',
      'payment_method': 'ONLINE',
      'price': widget.rate.price,
      'pieces': 1,
      'package_type_id': 1,
      'service_id': 1,
      'sub_service_id': 3,
      'pickup_date': DateTime.now().toIso8601String().substring(0, 10),
      'delivery_instructions': instructionController.text.trim(),
      'pickup': widget.pickup,
      'drop': widget.drop,
    };

    try {
      final ledger = await ViewledgerService().getLedger();
      if (!mounted) return;

      if (ledger.currentBalance >= widget.rate.price) {
        orderPayload['payment_method'] = 'WALLET';
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentWalletScreen(
              amount: widget.rate.price,
              currentBalance: ledger.currentBalance,
              orderPayload: orderPayload,
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentScreen(
              amount: widget.rate.price,
              orderPayload: orderPayload,
            ),
          ),
        );
      }
    } on ViewledgerException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${error.message}. Opening payment.')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            amount: widget.rate.price,
            orderPayload: orderPayload,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isCheckingWallet = false);
    }
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
                    const SizedBox(height: 5),

                    _buildSummaryCard(),

                    const SizedBox(height: 5),

                    // const Text(
                    //   'DELIVERY INSTRUCTIONS (OPTIONAL)',
                    //   style: TextStyle(
                    //     color: Color(0xFF667085),
                    //     fontSize: 11,
                    //     fontWeight: FontWeight.bold,
                    //     letterSpacing: .6,
                    //   ),
                    // ),

                    // const SizedBox(height: 6),

                    // TextField(
                    //   controller: instructionController,
                    //   maxLines: 1,
                    //   decoration: InputDecoration(
                    //     hintText: 'e.g. Call on arrival, leave at gate...',
                    //     hintStyle: const TextStyle(
                    //       color: Color(0xFF8A8F9C),
                    //       fontSize: 14,
                    //     ),
                    //     filled: true,
                    //     fillColor: Colors.white,
                    //     contentPadding: const EdgeInsets.symmetric(
                    //       horizontal: 16,
                    //       vertical: 15,
                    //     ),
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(14),
                    //       borderSide: BorderSide.none,
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 26),
                    // _buildCommissionCard(),
                    // const SizedBox(height: 12),
                    // _buildDocumentNotice(),

                    /*
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
                    */
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: _buildBookingActions(),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      color: blue,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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

              const SizedBox(width: 12),

              const Text(
                'Confirm Booking',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 3),

          const Text(
            'Review before paying',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 6),
          _buildSteps(),
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
            color: active ? yellow : Colors.white70,
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
        color: Colors.white54,
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
          _summaryRow(
            'Pickup address',
            _locationValue(widget.pickup, 'address', widget.pickupAddress),
          ),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            initiallyExpanded: false,
            title: const Text(
              'View booking details',
              style: TextStyle(color: blue, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Total ₹${widget.rate.price.toStringAsFixed(2)}',
              style: const TextStyle(color: Color(0xFF8A8F9C)),
            ),
            children: [
              _summaryRow(
                'Pickup name',
                _locationValue(widget.pickup, 'name', 'Not provided'),
              ),
              _summaryRow(
                'Pickup number',
                _locationValue(widget.pickup, 'mobile', 'Not provided'),
              ),
              _summaryRow('Pickup city/PIN', _cityPin(widget.pickup)),
              _summaryRow(
                'Drop address',
                _locationValue(widget.drop, 'address', widget.dropAddress),
              ),
              _summaryRow(
                'Drop name',
                _locationValue(widget.drop, 'name', 'Not provided'),
              ),
              _summaryRow(
                'Drop number',
                _locationValue(widget.drop, 'mobile', 'Not provided'),
              ),
              _summaryRow('Drop city/PIN', _cityPin(widget.drop)),
              _summaryRow('Vehicle', '🚚 ${widget.rate.vehicleType}'),
              _summaryRow(
                'Distance',
                '${widget.distance.toStringAsFixed(2)} km',
              ),
              _summaryRow('Weight', '${totalWeight.toStringAsFixed(2)} kg'),
              _summaryRow('Pickup', 'Now (~15 min)'),
              _summaryRow(
                'Base Fare',
                '₹${widget.rate.breakdown.basePrice.toStringAsFixed(2)}',
              ),
              _summaryRow(
                'Other Charges',
                '₹${widget.rate.breakdown.otherCharges.toStringAsFixed(2)}',
              ),
              _summaryRow(
                'GST',
                '₹${widget.rate.breakdown.gstAmount.toStringAsFixed(2)}',
              ),
              const Divider(height: 18),
              Row(
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    '₹${widget.rate.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: blue,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionCard() {
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

  Widget _buildDocumentNotice() {
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

  Widget _buildBookingActions() {
    return Row(
      children: [
        // Expanded(
        //   child: SizedBox(
        //     height: 80,
        //     child: OutlinedButton.icon(
        //       onPressed: () {
        //         ScaffoldMessenger.of(context).showSnackBar(
        //           const SnackBar(content: Text('Document checklist is ready.')),
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
              onPressed: _isCheckingWallet ? null : _proceedToPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: yellow,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: _isCheckingWallet
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
    );
  }

  Widget _summaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 118,
            child: Text(
              title,
              style: const TextStyle(color: Color(0xFF8A8F9C), fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value.isEmpty ? '—' : value,
              textAlign: TextAlign.left,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
