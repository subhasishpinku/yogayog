import 'package:flutter/material.dart';
import 'package:yogayog/confirmorder/confirm_order.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/core/services/national_service.dart';
import 'package:yogayog/dashboard/dashboard_scren.dart';
import 'package:yogayog/nationaldetails/provider/national_provider.dart';
import 'package:provider/provider.dart';

class ChooseCourier extends StatefulWidget {
  const ChooseCourier({
    super.key,
    required this.approximateWeightKg,
    required this.volumetricWeightKg,
    this.rates,
    this.orderPayload = const {},
    this.origin = 'Kolkata',
    this.destination = 'New Delhi',
    this.onDropDetailsRequired,
  });

  final double approximateWeightKg;
  final double volumetricWeightKg;
  final String origin;
  final String destination;
  final NationalRateResponse? rates;
  final Map<String, dynamic> orderPayload;
  final VoidCallback? onDropDetailsRequired;

  @override
  State<ChooseCourier> createState() => _ChooseCourierState();
}

class _ChooseCourierState extends State<ChooseCourier> {
  String? selectedCourier;
  bool _isSubmittingPostPaid = false;

  bool get _isPostPaid =>
      widget.orderPayload['payment_mode']
          ?.toString()
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'[\s_-]'), '') ==
      'postpaid';

  double get totalWeight {
    return widget.approximateWeightKg >= widget.volumetricWeightKg
        ? widget.approximateWeightKg
        : widget.volumetricWeightKg;
  }

  @override
  void initState() {
    super.initState();
    if (_isPostPaid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoCreatePostPaidOrder();
      });
    }
  }

  void _autoCreatePostPaidOrder() {
    if (_isSubmittingPostPaid || widget.rates?.rates.isEmpty != false) return;
    final rate = widget.rates!.rates.first;
    setState(() => selectedCourier = '0');
    _createPostPaidOrder(
      courierName: rate.carrierName,
      courierCode: rate.serviceMode,
      price: rate.price,
      delivery: rate.deliveryTime.isEmpty
          ? 'Delivery time unavailable'
          : rate.deliveryTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            _shipmentSummary(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.rates?.rates.length ?? 0} options available',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                        const Text(
                          'Cheapest first',
                          style: TextStyle(
                            color: Color(0xFF172786),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (widget.rates != null &&
                        widget.rates!.rates.isNotEmpty) ...[
                      for (
                        var index = 0;
                        index < widget.rates!.rates.length;
                        index++
                      )
                        _courierCardFromRate(index),
                    ] else ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Center(
                          child: Text(
                            'No courier rates available',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),
                    _infoBanner(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _courierCardFromRate(int index) {
    final rate = widget.rates!.rates[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _courierCard(
        selectionKey: '$index',
        name: rate.carrierName,
        code: rate.serviceMode,
        totalPrice: rate.price,
        color: _courierColor(index),
        price: 'Rs ${rate.price.toStringAsFixed(2)}',
        delivery: rate.deliveryTime.isEmpty
            ? 'Delivery time unavailable'
            : rate.deliveryTime,
        note:
            'Zone ${widget.rates!.zone} • ${widget.rates!.distance.toStringAsFixed(2)} km',
        tags: [rate.serviceMode, 'Prepaid', 'Door Pickup'],
        cheapest: index == 0,
      ),
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
                'Choose Courier',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.origin} -> ${widget.destination} - '
            '${totalWeight.toStringAsFixed(1)} kg',
            style: const TextStyle(color: Color(0xFFB7BCE0), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _shipmentSummary() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          const Text(
            'PACKAGE',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${totalWeight.toStringAsFixed(1)} kg - Express',
                  style: const TextStyle(
                    color: Color(0xFF172786),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.origin} -> ${widget.destination}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _courierCard({
    String? selectionKey,
    required String name,
    required String code,
    required double totalPrice,
    required Color color,
    required String price,
    required String delivery,
    required String note,
    required List<String> tags,
    bool cheapest = false,
  }) {
    final cardSelectionKey = selectionKey ?? '$name::$code';
    final isSelected = selectedCourier == cardSelectionKey;

    return GestureDetector(
      onTap: _isSubmittingPostPaid
          ? null
          : () {
              setState(() {
                selectedCourier = cardSelectionKey;
              });

              if (_isPostPaid) {
                _createPostPaidOrder(
                  courierName: name,
                  courierCode: code,
                  price: totalPrice,
                  delivery: delivery,
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ConfirmOrder(
                    courierName: name,
                    courierCode: code,
                    serviceName: 'Express',
                    origin: widget.origin,
                    destination: widget.destination,
                    weightKg: totalWeight,
                    total: totalPrice,
                    deliveryDate: delivery,
                    orderPayload: {
                      ...widget.orderPayload,
                      'price': totalPrice,
                      'service_id': 4,
                      'sub_service_id': 5,
                    },
                    onDropDetailsRequired: widget.onDropDetailsRequired,
                  ),
                ),
              );
            },
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF172786)
                : cheapest
                ? const Color(0xFFFFB800)
                : Colors.transparent,
            width: cheapest || isSelected ? 1.8 : 0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x15000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            if (cheapest)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  color: const Color(0xFFFFC400),
                  child: const Text(
                    'CHEAPEST',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    code,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        delivery,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    color: Color(0xFF172786),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: tags.map(_tag).toList(),
              ),
            ),
            const SizedBox(height: 5),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    note,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ),
                Text(
                  isSelected ? 'Selected' : 'Select ->',
                  style: const TextStyle(
                    color: Color(0xFF172786),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createPostPaidOrder({
    required String courierName,
    required String courierCode,
    required double price,
    required String delivery,
  }) async {
    setState(() => _isSubmittingPostPaid = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final payload = <String, dynamic>{
      ...widget.orderPayload,
      'price': price,
      'service_id': 4,
      'sub_service_id': 5,
      'payment_mode': 'Post-Paid',
      'courier_name': courierName,
      'courier_code': courierCode,
      'delivery_date': delivery,
    };
    final order = await context.read<NationalProvider>().createPostpaidOrder(
      payload: payload,
    );
    if (!mounted) return;

    if (order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<NationalProvider>().errorMessage ??
                'Unable to create post-paid order',
          ),
        ),
      );
      setState(() => _isSubmittingPostPaid = false);
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Dashboard()),
      (route) => false,
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F8E8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFF23752E), fontSize: 11),
      ),
    );
  }

  Color _courierColor(int index) {
    const colors = [
      Color(0xFFFF424A),
      Color(0xFFFF6D12),
      Color(0xFF2345B7),
      Color(0xFF168A5B),
    ];
    return colors[index % colors.length];
  }

  Widget _infoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF0FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'All prices include 18% GST. Fuel surcharge and '
        'additional fees may apply.',
        style: TextStyle(color: Color(0xFF172786), fontSize: 12),
      ),
    );
  }
}
