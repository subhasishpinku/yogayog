import 'package:flutter/material.dart';
import 'package:yogayog/addmoney/addmoney.dart';
import 'package:yogayog/bookscreen/book_screen.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/history/history_screen.dart';
import 'package:yogayog/homescreen/home_screen.dart';
import 'package:yogayog/more/tools_information.dart';
import 'package:yogayog/profile/profile_screen.dart';
import 'package:yogayog/trackscreen/track_screen.dart';
import 'package:yogayog/viewledger/viewledger.dart';

class MyWallet extends StatefulWidget {
  const MyWallet({super.key});

  @override
  State<MyWallet> createState() => _MyWalletState();
}

class _MyWalletState extends State<MyWallet> {
  static const _blue = AppColors.primaryMain;
  static const _pageBackground = Color(0xFFF4F4FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                children: [
                  _balanceCard(),
                  const SizedBox(height: 14),
                  _summaryCards(),
                  const SizedBox(height: 16),
                  _sectionHeader(),
                  const SizedBox(height: 10),
                  _transactionCard(),
                ],
              ),
            ),
            // _bottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      color: _blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                // style: IconButton.styleFrom(
                //   backgroundColor: const Color(0xFF4D59A7),
                //   padding: const EdgeInsets.all(8),
                // ),
              ),
              const SizedBox(width: 10),
              const Text(
                'My Wallet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          const Text(
            'Yogayog Credits',
            style: TextStyle(color: Color(0xFFCFD3FF), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _balanceCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        color: _blue,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AVAILABLE BALANCE',
            style: TextStyle(
              color: Color(0xFFAAB1E9),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: .5,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            '₹10,000.00',
            style: TextStyle(
              color: Colors.white,
              fontSize: 37,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Last topped up: 31 Jul 2026, 7:13 AM',
            style: TextStyle(color: Color(0xFFAAB1E9), fontSize: 12),
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _addMoney,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButton,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '+ Add Money',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextButton(
                  onPressed: _viewLedger,
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF5260B1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'View Ledger',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCards() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            amount: '₹10,000',
            label: 'Total Credits',
            color: _blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard(
            amount: '₹0.00',
            label: 'Total Debits',
            color: const Color(0xFFC43F34),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String amount,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _sectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Recent Transactions',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () => _showMessage('All transactions selected'),
          child: const Text(
            'See all',
            style: TextStyle(color: _blue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _transactionCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '127156796817',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4F8E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '↑ Credit',
                  style: TextStyle(
                    color: Color(0xFF27943D),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Text(
                  'Yogayog Credit — Wallet',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    '+₹10,000',
                    style: TextStyle(
                      color: Color(0xFF27943D),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Balance: ₹10,000',
                    style: TextStyle(
                      color: _blue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '31 Jul 2026, 7:13 AM',
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _bottomNavigation() {
    return BottomNavigationBar(
      // My Wallet is opened from Profile, so keep the index valid for the
      // four navigation items shown below.
      currentIndex: 0,
      onTap: _openTab,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 8,
      selectedItemColor: const Color(0xFF1F2A8A),
      unselectedItemColor: Colors.grey,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      items: [
        BottomNavigationBarItem(
          icon: _navIcon('assets/images/home.png'),
          activeIcon: _navIcon('assets/images/home.png'),
          label: 'Home',
        ),
        // BottomNavigationBarItem(
        //   icon: _navIcon('assets/images/book.png'),
        //   activeIcon: _navIcon('assets/images/book.png'),
        //   label: 'Book',
        // ),
        BottomNavigationBarItem(
          icon: _navIcon('assets/images/track.png'),
          activeIcon: _navIcon('assets/images/track.png'),
          label: 'Track',
        ),
        BottomNavigationBarItem(
          icon: _navIcon('assets/images/history.png'),
          activeIcon: _navIcon('assets/images/history.png'),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: _navIcon('assets/images/profile.png'),
          activeIcon: _navIcon('assets/images/profile.png'),
          label: 'Profile',
        ),
      ],
    );
  }

  void _openTab(int index) {
    final pages = <Widget>[
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
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _addMoney() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const Addmoney()),
    );
  }

  void _viewLedger() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const Viewledger()),
    );
  }
}

Widget _navIcon(String path) {
  return Image.asset(path, width: 24, height: 24, fit: BoxFit.contain);
}
