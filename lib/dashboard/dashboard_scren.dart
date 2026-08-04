import 'package:flutter/material.dart';
import 'package:yogayog/bookscreen/book_screen.dart';
import 'package:yogayog/history/history_screen.dart';
import 'package:yogayog/homescreen/home_screen.dart';
import 'package:yogayog/profile/profile_screen.dart';
import 'package:yogayog/trackscreen/track_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int pageIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    BookScreen(),
    TrackScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          BottomNavigationBarItem(
            icon: _navIcon('assets/images/book.png'),
            activeIcon: _navIcon('assets/images/book.png'),
            label: 'Book',
          ),
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
      ),
    );
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
