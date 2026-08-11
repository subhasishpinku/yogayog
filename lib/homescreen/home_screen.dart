import 'package:flutter/material.dart';
import 'package:yogayog/bikescreen/blick_local_screem.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/history/history_screen.dart';
import 'package:yogayog/homescreen/home_provider.dart';
import 'package:provider/provider.dart';
import 'package:yogayog/internationalimport/internationalimport.dart';
import 'package:yogayog/profile/profile_screen.dart';
import 'package:yogayog/bikescreen/choose_bike_screen.dart';
import 'package:yogayog/trackscreen/track_screen.dart';
import 'package:yogayog/truckscreen/choose_truck_screen.dart';
import 'package:yogayog/nationaldetails/national_details.dart';
import 'package:yogayog/internationaldetails/international_details.dart';
import 'package:yogayog/truckscreen/truck_local_screen.dart';
import 'package:yogayog/history/provider/history_provider.dart';
import 'package:yogayog/core/services/history_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<HomeProvider>().loadProfile();
      if (mounted) context.read<HistoryProvider>().loadBookings();
    });
  }

  // static const blue = Color(0xFF202A8D);
  // static const yellow = Color(0xFFFFC400);
  static const Color blue = AppColors.primaryMain;
  static const Color yellow = AppColors.primaryButton;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 12),
                children: [
                  _buildCategories(),
                  _buildActiveShipment(),
                  _buildServices(),
                  _buildRecentShipmentsFromApi(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final profile = context.watch<HomeProvider>().profile;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      decoration: const BoxDecoration(
        color: blue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Good morning 👋',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile?.name.isNotEmpty == true
                          ? profile!.name
                          : 'Loading...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (profile?.email.isNotEmpty == true) ...[
                      const SizedBox(height: 3),
                      Text(
                        profile!.email,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (profile?.mobile.isNotEmpty == true) ...[
                      const SizedBox(height: 2),
                      Text(
                        profile!.mobile,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: yellow,
                  child: Text(
                    profile?.initials ?? 'U',
                    style: TextStyle(color: blue, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // TextField(
          //   decoration: InputDecoration(
          //     hintText: 'Book a delivery or track...',
          //     hintStyle: const TextStyle(color: Colors.white54),
          //     prefixIcon: const Icon(Icons.search, color: Colors.white54),
          //     filled: true,
          //     fillColor: Colors.white.withOpacity(.15),
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(10),
          //       borderSide: BorderSide.none,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Category(
            icon: '🏍️',
            title: 'Local Bike',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BikeLocalScreen()),
            ),
          ),
          _Category(
            icon: '🚚',
            title: 'Local Truck',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TruckLocalScreen()),
            ),
          ),
          _Category(
            icon: '🚛',
            title: 'National',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NationalDetails()),
            ),
          ),
          _Category(
            icon: '🌍',
            title: "Int'Export",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InternationalDetails()),
            ),
          ),
          _Category(
            icon: '🌍',
            title: "Int'Import",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InternationalImport()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveShipment() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: blue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Shipment',
                  style: TextStyle(color: Colors.white60, fontSize: 11),
                ),
                SizedBox(height: 3),
                Text(
                  'YCG-2025-00891',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '• In Transit - Kolkata → Delhi',
                  style: TextStyle(color: yellow, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: yellow,
              foregroundColor: blue,
              elevation: 0,
            ),
            child: const Text('Track Live'),
          ),
        ],
      ),
    );
  }

  Widget _buildServices() {
    return Column(
      children: [
        _sectionTitle('Our Services', 'View all'),
        SizedBox(
          height: 145,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            children: const [
              _ServiceCard(
                icon: '🏍️',
                title: 'Local – Bike',
                subtitle: 'Within city',
                price: 'From ₹49',
              ),
              _ServiceCard(
                icon: '🚚',
                title: 'Local – Truck',
                subtitle: 'Within city',
                price: 'From ₹399',
              ),
              _ServiceCard(
                icon: '🚛',
                title: 'National',
                subtitle: 'Pan-India',
                price: 'From ₹89/kg',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentShipmentsFromApi() {
    final history = context.watch<HistoryProvider>();

    return Column(
      children: [
        _sectionTitle(
          'Recent Shipments',
          'See all',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HistoryScreen()),
          ),
        ),
        if (history.isLoading)
          const Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          )
        else if (history.errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              history.errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          )
        else if (history.history == null ||
            history.history!.ordersToDisplay.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'No recent shipments found.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          )
        else
          ...history.history!.ordersToDisplay.take(3).map(_bookingTile),
      ],
    );
  }

  Widget _bookingTile(Booking booking) {
    final route = [
      booking.pickupCity,
      booking.dropCity,
    ].where((city) => city.trim().isNotEmpty).join(' → ');
    final details = [
      booking.orderNo,
      booking.orderDate,
    ].where((value) => value.trim().isNotEmpty).join(' · ');

    return _shipment(
      _bookingIcon(booking.serviceName),
      route.isEmpty ? 'Shipment' : route,
      details.isEmpty ? booking.subServiceName : details,
      booking.status.isEmpty ? 'Processing' : booking.status,
    );
  }

  String _bookingIcon(String serviceName) {
    final service = serviceName.toLowerCase();
    if (service.contains('bike')) return '🏍️';
    if (service.contains('truck')) return '🚚';
    if (service.contains('international') || service.contains('export')) {
      return '✈️';
    }
    return '🚛';
  }

  Widget _buildRecentShipments() {
    return Column(
      children: [
        _sectionTitle('Recent Shipments', 'See all'),
        _shipment('🚚', 'New Delhi', 'YCG-2025-00891 · Jul 28', 'In Transit'),
        _shipment('📦', 'Mumbai, MH', 'YCG-2025-00872 · Jul 26', 'Delivered'),
      ],
    );
  }

  Widget _sectionTitle(String title, String action, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const Spacer(),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              child: Text(
                action,
                style: const TextStyle(
                  color: blue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shipment(String icon, String location, String number, String status) {
    final isDelivered = status.toLowerCase().contains('delivered');
    final isTransit = status.toLowerCase().contains('transit');
    final statusColor = isDelivered
        ? const Color(0xFF08743D)
        : isTransit
        ? const Color(0xFFB36A00)
        : blue;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFE9F3FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 23)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  number,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF7B8493),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Category extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;

  const _Category({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: const Color(0xFFE9EDFF),
              child: Text(icon, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String price;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 105,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
          const Spacer(),
          Text(
            price,
            style: const TextStyle(
              color: Color(0xFF202A8D),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
