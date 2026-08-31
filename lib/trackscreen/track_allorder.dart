import 'package:flutter/material.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/core/services/history_service.dart';
import 'package:yogayog/trackscreen/track_screen.dart';
import 'package:yogayog/trackscreen/international_export.dart';
import 'package:yogayog/trackscreen/local_bike _out_for_delivery.dart';
import 'package:yogayog/trackscreen/local_truck _out_for_delivery.dart';
import 'package:yogayog/trackscreen/national_out_for_delivery.dart';

class _DemoOrder {
  const _DemoOrder({
    this.trackingNumber = '',
    this.serviceId = 0,
    this.subServiceId = 0,
    required this.orderNo,
    required this.orderDate,
    required this.serviceName,
    required this.subServiceName,
    required this.amount,
    required this.status,
    required this.pickupCity,
    required this.dropCity,
    this.pickupName = '',
    this.pickupAddress = '',
    this.pickupMobile = '',
    this.dropName = '',
    this.dropAddress = '',
    this.dropMobile = '',
    this.riderName = '',
    this.riderMobile = '',
    this.paymentDone = false,
  });

  final String trackingNumber;
  final int serviceId;
  final int subServiceId;
  final String orderNo;
  final String orderDate;
  final String serviceName;
  final String subServiceName;
  final double amount;
  final String status;
  final String pickupCity;
  final String dropCity;
  final String pickupName;
  final String pickupAddress;
  final String pickupMobile;
  final String dropName;
  final String dropAddress;
  final String dropMobile;
  final String riderName;
  final String riderMobile;
  final bool paymentDone;

  factory _DemoOrder.fromBooking(Booking booking) {
    return _DemoOrder(
      trackingNumber: booking.orderId,
      serviceId: booking.serviceId,
      subServiceId: booking.subServiceId,
      orderNo: booking.orderNo,
      orderDate: booking.orderDate,
      serviceName: booking.serviceName,
      subServiceName: booking.subServiceName,
      amount: booking.amount,
      status: booking.status,
      pickupCity: booking.pickupCity,
      dropCity: booking.dropCity,
      pickupName: booking.pickupName,
      pickupAddress: booking.pickupAddress,
      pickupMobile: booking.pickupMobile,
      dropName: booking.dropName,
      dropAddress: booking.dropAddress,
      dropMobile: booking.dropMobile,
      riderName: booking.riderName,
      riderMobile: booking.riderMobile,
      paymentDone: booking.paymentDone,
    );
  }
}

class TrackAllOrder extends StatefulWidget {
  const TrackAllOrder({super.key, this.trackingNumber});

  final String? trackingNumber;
  @override
  State<TrackAllOrder> createState() => _TrackAllOrderState();
}

class _TrackAllOrderState extends State<TrackAllOrder> {
  final TextEditingController search = TextEditingController();
  final HistoryService _service = HistoryService();

  String filter = 'All';
  List<_DemoOrder> _apiOrders = const [];
  bool _isLoading = true;
  String? _errorMessage;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color headerBlue = AppColors.primaryMain;
  static const Color headerDarkBlue = AppColors.primaryMain;

  static const Color green = Color(0xFF2DBE5B);
  static const Color greenLight = Color(0xFFE8F8EC);

  static const Color orange = Color(0xFFFF9800);
  static const Color orangeLight = Color(0xFFFFF3E0);

  static const Color blue = Color(0xFF202A8D);
  static const Color blueLight = Color(0xFFEFF0FF);

  static const Color greyText = Color(0xFF666666);
  static const Color lightGrey = Color(0xFFE9EBF1);
  static const Color pageBackground = Color(0xFFF4F4FA);

  static const List<_DemoOrder> demoOrders = [
    _DemoOrder(
      orderNo: 'YCG-2025-00921',
      orderDate: '2025-08-13',
      serviceName: 'Bike',
      subServiceName: 'Local Delivery',
      amount: 180,
      status: 'Out for Delivery',
      pickupCity: 'Jodhpur Park',
      dropCity: 'Kalighat',
    ),
    _DemoOrder(
      orderNo: 'YCG-2025-00872',
      orderDate: '2025-08-13',
      serviceName: 'DTDC',
      subServiceName: 'National Delivery',
      amount: 420,
      status: 'Out for Delivery',
      pickupCity: 'Kolkata',
      dropCity: 'Mumbai',
    ),
    _DemoOrder(
      orderNo: 'YCG-2025-00872',
      orderDate: '2025-08-13',
      serviceName: 'DTDC',
      subServiceName: 'National Delivery',
      amount: 420,
      status: 'In Transit',
      pickupCity: 'Kolkata',
      dropCity: 'Mumbai',
    ),
    _DemoOrder(
      orderNo: 'YCG-2025-00864',
      orderDate: '2025-08-12',
      serviceName: 'Truck',
      subServiceName: 'Local Delivery',
      amount: 860,
      status: 'In Transit',
      pickupCity: 'Delhi',
      dropCity: 'Kolkata',
    ),
    _DemoOrder(
      orderNo: 'YCG-2025-00841',
      orderDate: '2025-08-12',
      serviceName: 'Bike',
      subServiceName: 'Local Delivery',
      amount: 150,
      status: 'Pickup Scheduled',
      pickupCity: 'Salt Lake',
      dropCity: 'New Town',
    ),
    _DemoOrder(
      orderNo: 'YCG-2025-00798',
      orderDate: '2025-08-11',
      serviceName: 'DTDC',
      subServiceName: 'National Delivery',
      amount: 390,
      status: 'Out for Delivery',
      pickupCity: 'Pune',
      dropCity: 'Kolkata',
    ),
    _DemoOrder(
      orderNo: 'YCG-2025-00764',
      orderDate: '2025-08-10',
      serviceName: 'Bike',
      subServiceName: 'Local Delivery',
      amount: 210,
      status: 'Out for Delivery',
      pickupCity: 'Ballygunge',
      dropCity: 'Park Street',
    ),
    _DemoOrder(
      orderNo: 'YCG-2025-00731',
      orderDate: '2025-08-09',
      serviceName: 'Air Cargo',
      subServiceName: 'International Delivery',
      amount: 1250,
      status: 'In Transit',
      pickupCity: 'Kolkata',
      dropCity: 'Dubai',
    ),
  ];

  // ============================================================
  // LIFECYCLE
  // ============================================================
  @override
  void initState() {
    super.initState();

    final awb = widget.trackingNumber?.trim();
    print('Track_number: $awb');

    if (awb != null && awb.isNotEmpty) {
      search.text = awb;
    }
    _loadBookings();
  }

  @override
  void didUpdateWidget(covariant TrackAllOrder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trackingNumber != widget.trackingNumber) {
      final trackingNumber = widget.trackingNumber?.trim() ?? '';
      search.value = TextEditingValue(
        text: trackingNumber,
        selection: TextSelection.collapsed(offset: trackingNumber.length),
      );
      setState(() {});
    }
  }

  Future<void> _loadBookings() async {
    try {
      final history = await _service.getBookings();
      if (!mounted) return;
      setState(() {
        _apiOrders = [
          ...history.upcomingOrders,
          ...history.pastOrders,
        ].map(_DemoOrder.fromBooking).toList();
        _isLoading = false;
      });
    } on HistoryException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to load bookings.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final orders = _apiOrders;

    final visible = orders.where(_searchMatches).where(_filterMatches).toList();

    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            _filters(orders),
            if (filter != 'All')
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                  child: Text(
                    'Showing ${visible.length} of ${orders.length} orders',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_errorMessage!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _loadBookings,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : visible.isEmpty
                  ? const Center(
                      child: Text(
                        'No orders found',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(10, 4, 10, 24),
                      children: _grouped(visible),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 19),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [headerBlue, headerDarkBlue],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      filter == 'All'
                          ? 'Track Your Shipments'
                          : 'Filtered View',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      filter == 'All' ? 'Active Orders' : filter,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),

              // Notification / Clear button
              if (filter == 'All')
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: const Color(0xFF303B9D),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xFFFFC400),
                    size: 25,
                  ),
                )
              else
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      filter = 'All';
                    });
                  },
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text(
                    'Clear',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: green,
                    backgroundColor: const Color(0xFF303B9D),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // Search
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
            ),
            child: TextField(
              controller: search,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search AWB, city or receiver...',
                hintStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Colors.white70,
                  size: 21,
                ),
                suffixIcon: search.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          search.clear();
                          setState(() {});
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white54,
                          size: 19,
                        ),
                      ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 13,
                  horizontal: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTER CHIPS
  // ============================================================

  Widget _filters(List<_DemoOrder> orders) {
    const names = [
      'All',
      'Created',
      'Accepted By Branch',
      'Released From Hold',
      'Assigned',
      'Ready To Ship',
      'Ready For Pickup',
      'Manifest Uploaded',
      'Shipment Received',
      'Shipment Picked Up',
      'Rider Accepted',
      'On The Way',
      'Reached',
      'Picked Up',
      'Handover To Branch',
      'Delivery Started',
      'Handover To Network',
      'Cancelled',
      'Out For Delivery',
      'At Your Door',
      'Delivered',
    ];

    final visibleNames = names
        .where(
          (name) =>
              name == 'All' || orders.any((o) => _statusMatches(o, name)),
        )
        .toList();

    return SizedBox(
      height: 62,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(10, 13, 10, 9),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: visibleNames.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final name = visibleNames[index];

          final active = filter == name;

          final count = name == 'All'
              ? orders.length
              : orders.where((o) => _statusMatches(o, name)).length;

          final chipColor = _chipColor(name);

          return _statusChip(
            name: name,
            count: count,
            active: active,
            color: chipColor,
          );
        },
      ),
    );
  }

  Widget _statusChip({
    required String name,
    required int count,
    required bool active,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          filter = name;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.fromLTRB(12, 0, 9, 0),
        decoration: BoxDecoration(
          color: active ? color : Colors.white,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(
            color: active ? color : const Color(0xFFE2E3EA),
            width: active ? 1.8 : 1,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.18),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status dot
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: active ? Colors.white : color,
                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(width: 7),

            Text(
              name,
              style: TextStyle(
                color: active ? Colors.white : const Color(0xFF252525),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(width: 6),

            // Count
            Container(
              width: 21,
              height: 21,
              decoration: BoxDecoration(
                color: active ? Colors.white.withValues(alpha: 0.22) : color,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$count',
                style: TextStyle(
                  color: active ? Colors.white : Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _chipColor(String name) {
    switch (name) {
      case 'In Transit':
        return orange;

      case 'Out for Delivery':
        return green;

      case 'Pickup Scheduled':
        return blue;

      case 'Delivered':
        return green;

      default:
        return blue;
    }
  }

  // ============================================================
  // GROUPING
  // ============================================================

  List<Widget> _grouped(List<_DemoOrder> orders) {
    if (filter != 'All') {
      return orders.map(_orderCard).toList();
    }

    final result = <Widget>[];

    const groups = <(String, IconData)>[
      ('Local Bike', Icons.two_wheeler_rounded),
      ('Local Truck', Icons.local_shipping_rounded),
      ('National', Icons.local_shipping_outlined),
      ('International Import', Icons.flight_land_rounded),
      ('International Export', Icons.flight_takeoff_rounded),
    ];

    for (final group in groups) {
      final groupOrders = orders
          .where((order) => _category(order) == group.$1)
          .toList();
      if (groupOrders.isEmpty) continue;

      result.add(_categoryTitle(group.$1, groupOrders.length, group.$2));
      result.addAll(_sortByStatus(groupOrders).map(_orderCard));
    }

    return result;
  }

  List<_DemoOrder> _sortByStatus(List<_DemoOrder> orders) {
    const priority = [
      'Out for Delivery',
      'In Transit',
      'Pickup Scheduled',
      'Delivered',
      'Processing',
    ];

    final result = [...orders];

    result.sort((a, b) {
      final aGroup = _statusGroup(a);
      final bGroup = _statusGroup(b);

      final aIndex = priority.indexOf(aGroup);
      final bIndex = priority.indexOf(bGroup);

      final safeA = aIndex == -1 ? priority.length : aIndex;
      final safeB = bIndex == -1 ? priority.length : bIndex;

      return safeA.compareTo(safeB);
    });

    return result;
  }

  Widget _categoryTitle(String title, int count, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black87),

          const SizedBox(width: 8),

          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: Color(0xFF202020),
              letterSpacing: 0.2,
            ),
          ),

          const Spacer(),

          Text(
            '$count orders',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ORDER CARD
  // ============================================================

  Widget _orderCard(_DemoOrder order) {
    final status = order.status.isEmpty ? 'Processing' : order.status;

    final route = [
      order.pickupCity,
      order.dropCity,
    ].where((v) => v.trim().isNotEmpty).join('  →  ');

    final color = _statusColor(status);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => _screenForOrder(order)),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.fromLTRB(15, 13, 15, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),

          // Status color on top
          border: Border(top: BorderSide(color: color, width: 4)),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --------------------------------------------------
            // ORDER NUMBER + SERVICE BADGE
            // --------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.orderNo.isEmpty ? 'Order' : order.orderNo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: headerBlue,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                _badge(order.serviceName),
              ],
            ),

            const SizedBox(height: 5),

            // --------------------------------------------------
            // STATUS
            // --------------------------------------------------
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 6),

                Flexible(
                  child: Text(
                    status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),

                if (_isOutForDelivery(status)) ...[
                  const SizedBox(width: 8),
                  _liveBadge(),
                ],

                const Spacer(),

                if (filter == 'All')
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFB0B0B0),
                    size: 20,
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // --------------------------------------------------
            // DELIVERY MESSAGE
            // --------------------------------------------------
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _isOutForDelivery(status)
                      ? Icons.location_on_outlined
                      : Icons.access_time_rounded,
                  size: 16,
                  color: const Color(0xFF444444),
                ),

                const SizedBox(width: 6),

                Expanded(
                  child: Text(
                    _deliveryMessage(order),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: greyText,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 9),

            // --------------------------------------------------
            // PROGRESS
            // --------------------------------------------------
            _statusProgressBar(status, color),

            const SizedBox(height: 10),

            Divider(height: 1, thickness: 1, color: const Color(0xFFE8E8EE)),

            const SizedBox(height: 9),

            // --------------------------------------------------
            // ROUTE + ETA
            // --------------------------------------------------
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    route.isEmpty ? order.subServiceName : route,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF252525),
                    ),
                  ),
                ),

                if (_isOutForDelivery(status)) _estimate(order),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _screenForOrder(_DemoOrder order) {
    final trackingNumber = order.trackingNumber.isNotEmpty
        ? order.trackingNumber
        : order.orderNo;
    if (order.serviceId == 7 &&
        (order.subServiceId == 8 || order.subServiceId == 9)) {
      return InternationalExport(
        trackingNumber: trackingNumber,
        subServiceId: order.subServiceId,
        pickupName: order.pickupName,
        pickupAddress: order.pickupAddress,
        pickupCity: order.pickupCity,
        dropName: order.dropName,
        dropAddress: order.dropAddress,
        dropCity: order.dropCity,
        riderName: order.riderName,
        riderMobile: order.riderMobile,
        orderDate: order.orderDate,
        amount: order.amount,
        status: order.status,
        paymentDone: order.paymentDone,
      );
    }

    if (order.serviceId == 4) {
      return NationalOutForDelivery(
        trackingNumber: trackingNumber,
        pickupName: order.pickupName,
        pickupAddress: order.pickupAddress,
        pickupCity: order.pickupCity,
        dropName: order.dropName,
        dropAddress: order.dropAddress,
        dropCity: order.dropCity,
        riderName: order.riderName,
        riderMobile: order.riderMobile,
        orderDate: order.orderDate,
        amount: order.amount,
        status: order.status,
        paymentDone: order.paymentDone,
      );
    }

    if (order.serviceId == 1) {
      if (order.subServiceId == 2) {
        return LocalBikeOutForDelivery(
          trackingNumber: trackingNumber,
          pickupName: order.pickupName,
          pickupCity: order.pickupCity,
          pickupAddress: order.pickupAddress,
          pickupMobile: order.pickupMobile,
          dropName: order.dropName,
          dropCity: order.dropCity,
          dropAddress: order.dropAddress,
          dropMobile: order.dropMobile,
          riderName: order.riderName,
          riderMobile: order.riderMobile,
          orderDate: order.orderDate,
          amount: order.amount,
          status: order.status,
          paymentDone: order.paymentDone,
        );
      }
      if (order.subServiceId == 3) {
        return LocalTruckOutForDelivery(
          trackingNumber: trackingNumber,
          pickupName: order.pickupName,
          pickupAddress: order.pickupAddress,
          pickupCity: order.pickupCity,
          dropName: order.dropName,
          dropAddress: order.dropAddress,
          dropCity: order.dropCity,
          riderName: order.riderName,
          riderMobile: order.riderMobile,
          orderDate: order.orderDate,
          amount: order.amount,
          status: order.status,
          paymentDone: order.paymentDone,
        );
      }
    }

    return TrackScreen(
      trackingNumber: order.orderNo,
      from: order.pickupCity,
      to: order.dropCity,
    );
  }

  // ============================================================
  // SERVICE BADGE
  // ============================================================

  Widget _badge(String service) {
    final value = service.isEmpty ? 'Delivery' : service;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: blueLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_serviceIcon(value), size: 12, color: headerBlue),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: headerBlue,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  IconData _serviceIcon(String service) {
    final value = service.toLowerCase();

    if (value.contains('bike') || value.contains('bicycle')) {
      return Icons.two_wheeler_rounded;
    }

    if (value.contains('truck')) {
      return Icons.local_shipping_rounded;
    }

    if (value.contains('delivery')) {
      return Icons.local_shipping_outlined;
    }

    return Icons.inventory_2_outlined;
  }

  // ============================================================
  // LIVE BADGE
  // ============================================================

  Widget _liveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: greenLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        '• Live',
        style: TextStyle(
          color: green,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ============================================================
  // PROGRESS BAR
  // ============================================================

  Widget _statusProgressBar(String status, Color color) {
    final progress = _progress(status).clamp(0.0, 1.0).toDouble();

    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SizedBox(
        height: 7,
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                const Positioned.fill(
                  child: ColoredBox(color: Color(0xFFDDE1EA)),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: constraints.maxWidth * progress,
                    height: 7,
                    child: ColoredBox(color: color),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // ETA
  // ============================================================

  Widget _estimate(_DemoOrder order) {
    final drop = order.dropCity.toLowerCase();

    final isNearby = drop.contains('kalighat') || drop.contains('kolkata');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'ETA',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 1),

        Text(
          isNearby ? '~15 min' : 'Today 6 PM',
          style: const TextStyle(
            color: green,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  bool _searchMatches(_DemoOrder order) {
    final query = _normalizeSearch(search.text);

    if (query.isEmpty) {
      return true;
    }

    return [
      order.trackingNumber,
      order.orderNo,
      order.pickupCity,
      order.dropCity,
      order.serviceName,
      order.subServiceName,
    ].map(_normalizeSearch).join(' ').contains(query);
  }

  String _normalizeSearch(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  // ============================================================
  // FILTER
  // ============================================================

  bool _filterMatches(_DemoOrder order) {
    return filter == 'All' || _statusMatches(order, filter);
  }

  bool _statusMatches(_DemoOrder order, String value) {
    final requested = _normalizedStatus(value);

    return requested == 'all' || _normalizedStatus(order.status) == requested;
  }

  // ============================================================
  // STATUS GROUP
  // ============================================================

  String _normalizedStatus(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _statusGroup(_DemoOrder order) {
    final value = _normalizedStatus(order.status);

    if (value.contains('out for delivery')) {
      return 'Out for Delivery';
    }

    if (value.contains('deliver')) {
      return 'Delivered';
    }

    if (value.contains('transit') || value.contains('process')) {
      return 'In Transit';
    }

    if (value.contains('pickup') || value.contains('scheduled')) {
      return 'Pickup Scheduled';
    }

    return 'Processing';
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  String _category(_DemoOrder order) {
    if (order.serviceId == 1 && order.subServiceId == 2) {
      return 'Local Bike';
    }
    if (order.serviceId == 1 && order.subServiceId == 3) {
      return 'Local Truck';
    }
    if (order.serviceId == 7 && order.subServiceId == 8) {
      return 'International Import';
    }
    if (order.serviceId == 7 && order.subServiceId == 9) {
      return 'International Export';
    }
    if (order.serviceId == 4) {
      return 'National';
    }

    return 'National';
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _statusColor(String status) {
    final value = _normalizedStatus(status);

    // Out for Delivery
    if (value.contains('out for delivery')) {
      return green;
    }

    // Delivered
    if (value.contains('deliver')) {
      return green;
    }

    // In Transit / Processing
    if (value.contains('transit') || value.contains('process')) {
      return orange;
    }

    // Pickup Scheduled
    if (value.contains('pickup') || value.contains('scheduled')) {
      return blue;
    }

    return blue;
  }

  // ============================================================
  // PROGRESS
  // ============================================================

  double _progress(String status) {
    final value = _normalizedStatus(status);

    if (value.contains('out for delivery')) {
      return 0.80;
    }

    if (value.contains('deliver')) {
      return 1.0;
    }

    if (value.contains('transit') || value.contains('process')) {
      return 0.68;
    }

    if (value.contains('pickup') || value.contains('scheduled')) {
      return 0.25;
    }

    return 0.25;
  }

  // ============================================================
  // OUT FOR DELIVERY
  // ============================================================

  bool _isOutForDelivery(String status) {
    return _normalizedStatus(status).contains('out for delivery');
  }

  // ============================================================
  // DELIVERY MESSAGE
  // ============================================================

  String _deliveryMessage(_DemoOrder order) {
    final status = order.status;

    if (_isOutForDelivery(status)) {
      final pickup = order.pickupCity.toLowerCase();

      final drop = order.dropCity.toLowerCase();

      if (pickup.contains('jodhpur') || drop.contains('kalighat')) {
        return 'Rider is 2.1 km away  ·  Arriving soon';
      }

      if (drop.contains('mumbai')) {
        return 'Mumbai delivery hub  ·  Dispatched 9 AM';
      }

      return 'Rider is on the way  ·  Arriving soon';
    }

    final value = status.toLowerCase();

    if (value.contains('pickup')) {
      return 'Rider arriving between 4:00–4:30 PM';
    }

    if (value.contains('transit') || value.contains('process')) {
      return 'Shipment is being processed';
    }

    if (value.contains('deliver')) {
      return 'Delivery completed';
    }

    return 'Order status updated';
  }
}
