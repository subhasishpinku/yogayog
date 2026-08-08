import 'package:flutter/material.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/core/services/history_service.dart';
import 'package:yogayog/history/provider/history_provider.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int selectedFilter = 0;

  static const filters = <_HistoryFilter>[
    _HistoryFilter('All'),
    // _HistoryFilter('Local', 1),
    _HistoryFilter('Bike', 1, 2),
    _HistoryFilter('Truck', 1, 3),
    _HistoryFilter('National/Domestic', 4),
    // _HistoryFilter('International', 7),
    _HistoryFilter('Import', 7, 8),
    _HistoryFilter('Export', 7, 9),
  ];

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadFilter(filters[selectedFilter]);
    });
  }

  void _loadFilter(_HistoryFilter filter) {
    context.read<HistoryProvider>().loadBookings(
      serviceId: filter.serviceId,
      subServiceId: filter.subServiceId,
    );
  }

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
            Expanded(child: _buildBookings()),
          ],
        ),
      ),
    );
  }

  Widget _buildBookings() {
    final provider = context.watch<HistoryProvider>();
    if (provider.isLoading && provider.history == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null && provider.history == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              provider.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
            TextButton(
              onPressed: provider.loadBookings,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    final bookings = provider.history?.ordersToDisplay ?? const <Booking>[];
    if (bookings.isEmpty) {
      return const Center(child: Text('No bookings found'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: bookings.length,
      itemBuilder: (_, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _bookingCard(bookings[index]),
      ),
    );
  }

  Widget _bookingCard(Booking item) {
    final delivered = item.status.toLowerCase() == 'delivered';
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
                child: Icon(
                  Icons.local_shipping,
                  color: delivered
                      ? const Color(0xFF62D746)
                      : const Color(0xFFFFC400),
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.orderNo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${item.serviceName} - ${item.orderDate}',
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
              '${item.pickupCity}  →  ${item.dropCity}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Divider(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${item.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF172786),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                item.subServiceName,
                style: const TextStyle(
                  color: Color(0xFF172786),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _header() {
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
                  onTap: () {
                    setState(() => selectedFilter = index);
                    _loadFilter(filters[index]);
                  },
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
                      filters[index].label,
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

class _HistoryFilter {
  const _HistoryFilter(this.label, [this.serviceId, this.subServiceId]);

  final String label;
  final int? serviceId;
  final int? subServiceId;
}
