import 'package:flutter/material.dart';
import 'package:yogayog/bookscreen/book_screen.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/history/history_screen.dart';
import 'package:yogayog/homescreen/home_screen.dart';
import 'package:yogayog/more/tools_information.dart';
import 'package:yogayog/profile/profile_screen.dart';
import 'package:yogayog/trackscreen/track_screen.dart';

class MyBooking extends StatefulWidget {
  const MyBooking({super.key});

  @override
  State<MyBooking> createState() => _MyBookingState();
}

class _MyBookingState extends State<MyBooking> {
  int tabIndex = 0;

  final bookings = const [
    (
      '31 Jul 2026, 07:23 PM',
      '1222000010',
      '🚲 Bike',
      'Santanu Roy (8436695357)',
      '15, Chandra Nath Chatterjee St, Bhowanipore, Kolkata, WB 700052',
      'Saheli Das (8975989677)',
      'Kalighat Kali Mandir, Anami Sangha, Kalighat, Kolkata, WB 700026',
      '₹57.75',
    ),
    (
      '31 Jul 2026, 07:21 PM',
      '1222000009',
      '🌐 Int’l',
      'Santanu Roy (8436695357)',
      'Philippines, Bulacan, Santa Maria, GJK Pharma Distributors',
      'Receiver TBD',
      'International — 9078',
      '₹4,200.00',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4FA),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            _tabs(),
            Expanded(child: _bookingList()),
            // _bottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _header() => Container(
    width: double.infinity,
    color: AppColors.primaryBlue,
    padding: const EdgeInsets.fromLTRB(20, 27, 20, 22),
    child: const Text(
      'My Bookings',
      style: TextStyle(
        color: Colors.white,
        fontSize: 23,
        fontWeight: FontWeight.w900,
      ),
    ),
  );

  Widget _tabs() => Container(
    color: AppColors.primaryBlue,
    child: Row(children: [_tab('UPCOMING (6)', 0), _tab('PAST (0)', 1)]),
  );

  Widget _tab(String label, int index) => Expanded(
    child: InkWell(
      onTap: () => setState(() => tabIndex = index),
      child: Container(
        padding: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: tabIndex == index
                  ? AppColors.primaryButton
                  : const Color(0xFF6972C0),
              width: 2,
            ),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: tabIndex == index
                  ? AppColors.primaryButton
                  : const Color(0xFF999FD6),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );

  Widget _bookingList() {
    if (tabIndex == 1)
      return const Center(
        child: Text('No past bookings', style: TextStyle(color: Colors.grey)),
      );
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      itemCount: bookings.length,
      itemBuilder: (_, index) => _bookingCard(bookings[index]),
    );
  }

  Widget _bookingCard(
    (String, String, String, String, String, String, String, String) booking,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
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
              Text(
                '🗓️ ${booking.$1}',
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
              _badge(booking.$3),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Booking ID: ${booking.$2}',
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          _location(Icons.circle, Colors.amber, booking.$4, booking.$5),
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Divider(height: 18),
          ),
          _location(
            Icons.circle,
            AppColors.primaryBlue,
            booking.$6,
            booking.$7,
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.$8,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Estimated Fare',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
              const Text(
                '⌛ Pending',
                style: TextStyle(
                  color: Color(0xFF9A7800),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _action('✕ Cancel', const Color(0xFFFFEEEE), Colors.red),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _action(
                  '▤ Invoice',
                  const Color(0xFFEFF0FF),
                  AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _location(IconData icon, Color color, String title, String address) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
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

  Widget _badge(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F1FF),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.primaryBlue,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _action(String text, Color background, Color foreground) => TextButton(
    onPressed: () => ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$text selected'))),
    style: TextButton.styleFrom(
      backgroundColor: background,
      foregroundColor: foreground,
      padding: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  Widget _bottomNavigation() => BottomNavigationBar(
    currentIndex: 3,
    onTap: (index) {
      final pages = [
        const HomeScreen(),
        // const BookScreen(),
        const TrackScreen(),
        const HistoryScreen(),
        const ToolInformation(),
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
      // _navItem('assets/images/book.png', 'Book'),
      _navItem('assets/images/track.png', 'Track'),
      _navItem('assets/images/history.png', 'History'),
      _navItem('assets/images/more.png', 'More'),
    ],
  );

  BottomNavigationBarItem _navItem(String path, String label) =>
      BottomNavigationBarItem(
        icon: Image.asset(path, width: 24, height: 24),
        activeIcon: Image.asset(path, width: 24, height: 24),
        label: label,
      );
}
