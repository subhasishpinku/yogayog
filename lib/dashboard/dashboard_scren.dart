import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yogayog/bookscreen/book_screen.dart';
import 'package:yogayog/history/history_screen.dart';
import 'package:yogayog/homescreen/home_screen.dart';
import 'package:yogayog/more/tools_information.dart';
import 'package:yogayog/profile/profile_screen.dart';
import 'package:yogayog/trackscreen/track_allorder.dart';
import 'package:yogayog/trackscreen/track_screen.dart';
import 'package:yogayog/profile/provider/profile_provider.dart';
import 'package:yogayog/OnboardingScreen/onboarding_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({
    super.key,
    this.initialPageIndex = 0,
    this.initialTrackingNumber,
  });

  final int initialPageIndex;
  final String? initialTrackingNumber;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late int pageIndex;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pageIndex = widget.initialPageIndex.clamp(0, 3).toInt();
    pages = [
      HomeScreen(onMoreTrack: _openTrackTab),
      TrackAllOrder(trackingNumber: widget.initialTrackingNumber),
      const HistoryScreen(),
      const ToolInformation(),
    ];
  }

  void _openTrackTab(String trackingNumber) {
    if (!mounted) return;
    setState(() {
      print('Opening Track Tab with tracking number: $trackingNumber');

      pages[1] = TrackAllOrder(trackingNumber: trackingNumber);
      pageIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _confirmLogout,
      child: Scaffold(
        body: IndexedStack(index: pageIndex, children: pages),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: pageIndex,
          onTap: (index) {
            setState(() {
              pageIndex = index;
            });
          },
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
              icon: _navIcon('assets/images/more.png'),
              activeIcon: _navIcon('assets/images/more.png'),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Do you want to logout from the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !mounted) return false;

    final provider = context.read<ProfileProvider>();
    final loggedOut = await provider.logout();
    if (!mounted) return false;

    if (!loggedOut) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Unable to logout')),
      );
      return false;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      (_) => false,
    );
    return false;
  }
}

Widget _navIcon(String path) {
  return Image.asset(path, width: 24, height: 24, fit: BoxFit.contain);
}

class _EmptyPage extends StatelessWidget {
  final String title;

  const _EmptyPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title Screen')),
    );
  }
}
