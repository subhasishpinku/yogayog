import 'package:flutter/material.dart';
import 'package:yogayog/bookscreen/book_screen.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/history/history_screen.dart';
import 'package:yogayog/homescreen/home_screen.dart';
import 'package:yogayog/profile/profile_screen.dart';
import 'package:yogayog/trackscreen/track_screen.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4FA),
      body: SafeArea(
        child: Column(
          children: [
            _summaryHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                children: [
                  const Text(
                    'All Invoices',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _invoiceCard(
                    id: '#2908763000002978592',
                    order: '1222000010',
                    date: '31 Jul 2026, 7:23 PM',
                    type: '🏍️ Local Delivery',
                    senderAddress:
                        '15, Chandra Nath Chatterjee St, Bhowanipore, Kolkata — 700025',
                    receiver: 'Saheli Das',
                    receiverAddress:
                        'Kalighat Kali Mandir, Anami Sangha, Kalighat, Kolkata — 700026',
                    amount: '₹57.75',
                  ),
                  const SizedBox(height: 12),
                  _invoiceCard(
                    id: '#2908763000002977841',
                    order: '1222000009',
                    date: '31 Jul 2026, 7:21 PM',
                    type: '🌐 International',
                    senderAddress:
                        'Philippines, Bulacan, Santa Maria — GJK Pharma',
                    receiver: null,
                    receiverAddress: null,
                    amount: '₹4,200.00',
                  ),
                ],
              ),
            ),
            _bottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _summaryHeader() => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
    color: AppColors.primaryBlue,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF4D59A7),
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'Invoices',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F1FF),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Column(
            children: [
              Text(
                'Pending',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
              Text(
                '6',
                style: TextStyle(
                  color: Color(0xFF9A7800),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _invoiceCard({
    required String id,
    required String order,
    required String date,
    required String type,
    required String senderAddress,
    required String? receiver,
    required String? receiverAddress,
    required String amount,
  }) => Container(
    padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    id,
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Order: $order • $date',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
            _statusBadge(),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          type,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _person('📤', 'SENDER', 'Santanu Roy', senderAddress),
        if (receiver != null) ...[
          const Divider(height: 22),
          _person('📍', 'RECEIVER', receiver, receiverAddress!),
        ],
        const Divider(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
                Text(
                  amount,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (receiver != null)
                  const Text(
                    'Payment: COD',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
              ],
            ),
            TextButton.icon(
              onPressed: () => _message('PDF download started'),
              icon: const Icon(Icons.download, size: 16),
              label: const Text('PDF'),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF0F1FF),
                foregroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _statusBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF5CC),
      borderRadius: BorderRadius.circular(13),
    ),
    child: const Text(
      'Pending',
      style: TextStyle(
        color: Color(0xFF9A7800),
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _person(String icon, String label, String name, String address) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(icon, style: const TextStyle(fontSize: 15)),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            Text(
              address,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _bottomNavigation() => BottomNavigationBar(
    currentIndex: 3,
    onTap: (index) {
      final pages = [
        const HomeScreen(),
        const BookScreen(),
        const TrackScreen(),
        const HistoryScreen(),
        const ProfileScreen(),
      ];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => pages[index]),
      );
    },
    type: BottomNavigationBarType.fixed,
    backgroundColor: Colors.white,
    selectedItemColor: const Color(0xFF1F2A8A),
    unselectedItemColor: Colors.grey,
    selectedFontSize: 10,
    unselectedFontSize: 10,
    items: [
      _navItem('assets/images/home.png', 'Home'),
      _navItem('assets/images/book.png', 'Book'),
      _navItem('assets/images/track.png', 'Track'),
      _navItem('assets/images/history.png', 'History'),
      _navItem('assets/images/profile.png', 'Profile'),
    ],
  );

  BottomNavigationBarItem _navItem(String path, String label) =>
      BottomNavigationBarItem(
        icon: Image.asset(path, width: 24, height: 24),
        activeIcon: Image.asset(path, width: 24, height: 24),
        label: label,
      );

  void _message(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}
