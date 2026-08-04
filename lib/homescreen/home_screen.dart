import 'package:flutter/material.dart';
import 'package:yogayog/constants/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                  _buildRecentShipments(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
              const Text(
                'Rajan Kumar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const CircleAvatar(
                radius: 18,
                backgroundColor: yellow,
                child: Text(
                  'RK',
                  style: TextStyle(color: blue, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Book a delivery or track...',
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withOpacity(.15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          _Category(icon: '🏍️', title: 'Local Bike'),
          _Category(icon: '🚚', title: 'Local Truck'),
          _Category(icon: '🚛', title: 'National'),
          _Category(icon: '🌍', title: "Int'l"),
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

  Widget _buildRecentShipments() {
    return Column(
      children: [
        _sectionTitle('Recent Shipments', 'See all'),
        _shipment('🚚', 'New Delhi', 'YCG-2025-00891 · Jul 28', 'In Transit'),
        _shipment('📦', 'Mumbai, MH', 'YCG-2025-00872 · Jul 26', 'Delivered'),
      ],
    );
  }

  Widget _sectionTitle(String title, String action) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const Spacer(),
          Text(
            action,
            style: const TextStyle(
              color: blue,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _shipment(String icon, String location, String number, String status) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: Colors.white, child: Text(icon)),
      title: Text(
        location,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(number),
      trailing: Text(
        status,
        style: TextStyle(
          color: status == 'Delivered' ? Colors.green : Colors.orange,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _Category extends StatelessWidget {
  final String icon;
  final String title;

  const _Category({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
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
