import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/core/services/history_service.dart';
import 'package:yogayog/history/provider/history_provider.dart';
import 'package:yogayog/trackscreen/track_screen.dart';

class TrackAllOrder extends StatefulWidget {
  const TrackAllOrder({super.key});
  @override
  State<TrackAllOrder> createState() => _TrackAllOrderState();
}

class _TrackAllOrderState extends State<TrackAllOrder> {
  final search = TextEditingController();
  String filter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<HistoryProvider>().loadBookings();
    });
  }

  @override
  void dispose() { search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();
    final orders = history.history?.upcomingOrders ?? const <Booking>[];
    final visible = orders.where(_searchMatches).where(_filterMatches).toList();
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4FA),
      body: SafeArea(child: Column(children: [
        _header(),
        _filters(orders),
        Expanded(child: history.isLoading ? const Center(child: CircularProgressIndicator()) : visible.isEmpty ? const Center(child: Text('No orders found', style: TextStyle(color: Colors.grey))) : ListView(padding: const EdgeInsets.fromLTRB(10, 6, 10, 24), children: _grouped(visible))),
      ])),
    );
  }

  Widget _header() => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
    decoration: const BoxDecoration(color: AppColors.primaryMain, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Track Your Shipments', style: TextStyle(color: Colors.white70, fontSize: 12)), SizedBox(height: 2), Text('Active Orders', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900))])),
        Container(width: 42, height: 42, decoration: const BoxDecoration(color: Color(0xFF303B9D), shape: BoxShape.circle), child: const Icon(Icons.notifications_none, color: Color(0xFFFFC400))),
      ]),
      const SizedBox(height: 14),
      TextField(controller: search, onChanged: (_) => setState(() {}), style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Search AWB, city or receiver...', hintStyle: const TextStyle(color: Colors.white54), prefixIcon: const Icon(Icons.search, color: Colors.white70), suffixIcon: search.text.isEmpty ? null : IconButton(onPressed: () { search.clear(); setState(() {}); }, icon: const Icon(Icons.close, color: Colors.white54)), filled: true, fillColor: Colors.white.withValues(alpha: .14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
    ]),
  );

  Widget _filters(List<Booking> orders) {
    const names = ['All', 'In Transit', 'Pickup Scheduled', 'Delivered'];
    return SizedBox(height: 62, child: ListView.separated(padding: const EdgeInsets.fromLTRB(10, 13, 10, 9), scrollDirection: Axis.horizontal, itemCount: names.length, separatorBuilder: (_, _) => const SizedBox(width: 8), itemBuilder: (_, i) {
      final name = names[i]; final active = filter == name; final count = name == 'All' ? orders.length : orders.where((o) => _statusMatches(o, name)).length;
      return ChoiceChip(selected: active, onSelected: (_) => setState(() => filter = name), label: Text('$name  $count'), labelStyle: TextStyle(color: active ? Colors.white : Colors.black87, fontSize: 12, fontWeight: FontWeight.bold), selectedColor: AppColors.primaryMain, backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)));
    }));
  }

  List<Widget> _grouped(List<Booking> orders) {
    final result = <Widget>[];
    for (final group in ['Local Deliveries', 'National Deliveries', 'International Deliveries']) {
      final items = orders.where((o) => _category(o) == group).toList();
      if (items.isEmpty) continue;
      result.add(_sectionTitle(group, items.length));
      result.addAll(items.map(_orderCard));
    }
    return result;
  }

  Widget _sectionTitle(String title, int count) => Padding(padding: const EdgeInsets.fromLTRB(5, 8, 5, 8), child: Row(children: [Icon(title.startsWith('Local') ? Icons.two_wheeler : title.startsWith('National') ? Icons.local_shipping : Icons.flight, size: 19), const SizedBox(width: 8), Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)), const Spacer(), Text('$count orders', style: const TextStyle(color: Colors.grey, fontSize: 11))]));

  Widget _orderCard(Booking order) {
    final status = order.status.isEmpty ? 'Processing' : order.status;
    final route = [order.pickupCity, order.dropCity].where((v) => v.trim().isNotEmpty).join('  →  ');
    final color = _statusColor(status);
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TrackScreen(
            trackingNumber: order.orderNo,
            from: order.pickupCity,
            to: order.dropCity,
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Keep the status color bar as a separate visible widget.
              Container(width: double.infinity, height: 5, color: color),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            order.orderNo.isEmpty ? 'Order' : order.orderNo,
                            style: const TextStyle(
                              color: AppColors.primaryMain,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        _badge(order.serviceName),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.circle, size: 9, color: color),
                        const SizedBox(width: 6),
                        Text(
                          status,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      route.isEmpty ? order.subServiceName : route,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    LinearProgressIndicator(
                      value: _progress(status),
                      minHeight: 5,
                      borderRadius: BorderRadius.circular(5),
                      color: color,
                      backgroundColor: const Color(0xFFE9EBF1),
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

  Widget _badge(String service) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFEFF0FF), borderRadius: BorderRadius.circular(14)), child: Text(service.isEmpty ? 'Delivery' : service, style: const TextStyle(color: AppColors.primaryMain, fontSize: 10, fontWeight: FontWeight.bold)));
  bool _searchMatches(Booking o) => search.text.trim().isEmpty || [o.orderNo, o.pickupCity, o.dropCity, o.serviceName, o.subServiceName].join(' ').toLowerCase().contains(search.text.trim().toLowerCase());
  bool _filterMatches(Booking o) => filter == 'All' || _statusMatches(o, filter);
  bool _statusMatches(Booking o, String value) { final s = o.status.toLowerCase(); if (value == 'In Transit') return s.contains('transit') || s.contains('process'); if (value == 'Pickup Scheduled') return s.contains('pickup') || s.contains('scheduled'); if (value == 'Delivered') return s.contains('deliver'); return true; }
  String _category(Booking o) { final s = '${o.serviceName} ${o.subServiceName}'.toLowerCase(); if (s.contains('international') || s.contains('import') || s.contains('export')) return 'International Deliveries'; if (s.contains('national')) return 'National Deliveries'; return 'Local Deliveries'; }
  Color _statusColor(String s) { final v = s.toLowerCase(); if (v.contains('deliver')) return const Color(0xFF2DBE5B); if (v.contains('transit') || v.contains('process')) return const Color(0xFFFF9800); return AppColors.primaryMain; }
  double _progress(String s) { final v = s.toLowerCase(); if (v.contains('deliver')) return 1; if (v.contains('transit') || v.contains('process')) return .68; return .25; }
}
