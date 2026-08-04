import 'package:flutter/material.dart';
import 'package:yogayog/constants/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int selectedFilter = 0;

  final shipments = const [
    _Shipment(
      'YCG-2025-00921',
      'Local Bike',
      'Jul 30, 2025',
      'Jodhpur Park',
      'Park Street, Kolkata',
      149,
      'In Transit',
      Icons.two_wheeler,
      Color(0xFFFFC400),
    ),
    _Shipment(
      'YCG-2025-00891',
      'National Express',
      'Jul 28, 2025',
      'Kolkata',
      'New Delhi',
      395,
      'Delivered',
      Icons.local_shipping,
      Color(0xFF62D746),
    ),
    _Shipment(
      'YCG-2025-00872',
      'National Standard',
      'Jul 26, 2025',
      'Kolkata',
      'Mumbai, MH',
      210,
      'Delivered',
      Icons.inventory_2_outlined,
      Color(0xFFD49A67),
    ),
    _Shipment(
      'YCG-2025-0047',
      'Intl Express',
      'Jul 25, 2025',
      'Kolkata',
      'London',
      980,
      'Delivered',
      Icons.flight,
      Color(0xFF55B8E8),
    ),
  ];

  List<_Shipment> get filteredShipments {
    if (selectedFilter == 1) {
      return shipments.where((x) => x.status == 'In Transit').toList();
    }
    if (selectedFilter == 2) {
      return shipments.where((x) => x.status == 'Delivered').toList();
    }
    return shipments;
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
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                itemCount: filteredShipments.length,
                itemBuilder: (_, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _shipmentCard(filteredShipments[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    const filters = ['All', 'Active', 'Delivered', 'Local', 'National'];

    return Container(
      width: double.infinity,
      color: AppColors.primaryMain,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Shipments',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'All your past & active orders',
            style: TextStyle(color: Color(0xFFB7BCE0)),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                final active = selectedFilter == index;
                return GestureDetector(
                  onTap: () => setState(() => selectedFilter = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFFFFC400)
                          : const Color(0xFF3B47A2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      filters[index],
                      style: TextStyle(
                        color: active
                            ? const Color(0xFF172786)
                            : const Color(0xFFD3D6F1),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _shipmentCard(_Shipment item) {
    final delivered = item.status == 'Delivered';

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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF0FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color, size: 25),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.tracking,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      item.service + ' - ' + item.date,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(item.status),
            ],
          ),
          const SizedBox(height: 13),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              item.from + '  ->  ' + item.to,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Divider(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rs ' + item.price.toString(),
                style: const TextStyle(
                  color: Color(0xFF172786),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        delivered
                            ? 'Receipt download started'
                            : 'Opening live tracking',
                      ),
                    ),
                  );
                },
                child: Text(
                  delivered ? 'Download Receipt' : 'Track Live ->',
                  style: const TextStyle(
                    color: Color(0xFF172786),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final delivered = status == 'Delivered';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: delivered ? const Color(0xFFE2F7E5) : const Color(0xFFFFF5D0),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: delivered ? const Color(0xFF23822E) : const Color(0xFF9C7600),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _Shipment {
  const _Shipment(
    this.tracking,
    this.service,
    this.date,
    this.from,
    this.to,
    this.price,
    this.status,
    this.icon,
    this.color,
  );

  final String tracking;
  final String service;
  final String date;
  final String from;
  final String to;
  final int price;
  final String status;
  final IconData icon;
  final Color color;
}
