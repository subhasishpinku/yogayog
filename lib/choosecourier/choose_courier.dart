import 'package:flutter/material.dart';
import 'package:yogayog/confirmorder/confirm_order.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/core/services/national_service.dart';

class ChooseCourier extends StatefulWidget {
  const ChooseCourier({
    super.key,
    required this.approximateWeightKg,
    required this.volumetricWeightKg,
    this.rates,
    this.orderPayload = const {},
    this.origin = 'Kolkata',
    this.destination = 'New Delhi',
  });

  final double approximateWeightKg;
  final double volumetricWeightKg;
  final String origin;
  final String destination;
  final NationalRateResponse? rates;
  final Map<String, dynamic> orderPayload;

  @override
  State<ChooseCourier> createState() => _ChooseCourierState();
}

class _ChooseCourierState extends State<ChooseCourier> {
  String? selectedCourier;

  double get totalWeight {
    return widget.approximateWeightKg >= widget.volumetricWeightKg
        ? widget.approximateWeightKg
        : widget.volumetricWeightKg;
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
              child: ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.rates?.rates.length ?? 3} options available',
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

                  if (widget.rates != null)
                    ...widget.rates!.rates.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _courierCard(
                          name: entry.value.carrierName,
                          code: entry.value.serviceMode,
                          totalPrice: entry.value.price,
                          color: _courierColor(entry.key),
                          price: 'Rs ${entry.value.price.toStringAsFixed(2)}',
                          delivery: entry.value.deliveryTime.isEmpty
                              ? 'Delivery time unavailable'
                              : entry.value.deliveryTime,
                          note:
                              'Zone ${widget.rates!.zone} • ${widget.rates!.distance.toStringAsFixed(2)} km',
                          tags: [
                            entry.value.serviceMode,
                            'Prepaid',
                            'Door Pickup',
                          ],
                          cheapest: entry.key == 0,
                        ),
                      ),
                    )
                  else ...[
                    _courierCard(
                      name: 'Delhivery',
                      code: 'DLVRY',
                      totalPrice: 298,
                      color: const Color(0xFFFF424A),
                      price: 'Rs 298',
                      delivery: 'Delivery in 3-4 days',
                      note: 'Real-time tracking included',
                      tags: const ['Door Pickup', 'Door Delivery'],
                      cheapest: true,
                    ),
                  ],

                  const SizedBox(height: 12),
                  _infoBanner(),
                ],
              ),
            ),
          ],
        ),
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
    final isSelected = selectedCourier == name;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCourier = name;
        });

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
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
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
                const SizedBox(width: 14),
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
                      const SizedBox(height: 4),
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
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: tags.map(_tag).toList(),
              ),
            ),
            const SizedBox(height: 12),
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
