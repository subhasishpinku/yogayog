import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yogayog/adddropadress/add_drop_address.dart';
import 'package:yogayog/bookscreen/book_screen.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/history/history_screen.dart';
import 'package:yogayog/homescreen/home_screen.dart';
import 'package:yogayog/more/tools_information.dart';
import 'package:yogayog/profile/profile_screen.dart';
import 'package:yogayog/trackscreen/track_screen.dart';
import 'package:yogayog/savedaddresses/provider/savedaddresses_provider.dart';
import 'package:yogayog/savedaddresses/savedaddresses_service.dart';

class Savedaddresses extends StatefulWidget {
  const Savedaddresses({super.key});

  @override
  State<Savedaddresses> createState() => _SavedaddressesState();
}

class _SavedaddressesState extends State<Savedaddresses> {
  String selectedTab = 'Local';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SavedAddressesProvider>().loadAddresses(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SavedAddressesProvider>();
    final addresses = provider.addresses;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4FA),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                children: [
                  _tabs(),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // _message('Add Drop Address');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddDropAddress(
                              serviceId: _serviceIdForTab(selectedTab),
                            ),
                          ),
                        ).then((_) {
                          if (mounted) {
                            context.read<SavedAddressesProvider>().refresh(
                              _serviceIdForTab(selectedTab),
                            );
                          }
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Drop Address'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryButton,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _addressContent(provider, addresses),
                ],
              ),
            ),
            // _bottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _header() => Container(
    width: double.infinity,
    color: AppColors.primaryMain,
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(width: 10),
            const Text(
              'Saved Addresses',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        const Text(
          'Manage your drop locations',
          style: TextStyle(color: Color(0xFFD2D5FF), fontSize: 13),
        ),
      ],
    ),
  );

  Widget _tabs() => Row(
    children: [
      for (final tab in ['Local', 'National', 'International'])
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: tab == 'International' ? 0 : 8),
            child: _tab(tab),
          ),
        ),
    ],
  );

  Widget _tab(String label) {
    final active = selectedTab == label;
    return OutlinedButton(
      onPressed: () {
        setState(() => selectedTab = label);
        context.read<SavedAddressesProvider>().loadAddresses(
          _serviceIdForTab(label),
        );
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: active ? AppColors.yellow : Colors.white,
        foregroundColor: active ? Colors.white : Colors.grey,
        side: BorderSide(
          color: active ? AppColors.primaryBlue : Colors.transparent,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  int _serviceIdForTab(String tab) {
    switch (tab) {
      case 'National':
        return 4;
      case 'International':
        return 7;
      default:
        return 1;
    }
  }

  Widget _errorState(SavedAddressesProvider provider) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        Text(provider.errorMessage!, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () =>
              provider.loadAddresses(_serviceIdForTab(selectedTab)),
          child: const Text('Retry'),
        ),
      ],
    ),
  );

  Widget _addressContent(
    SavedAddressesProvider provider,
    List<SavedAddress> addresses,
  ) {
    if (provider.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (provider.errorMessage != null) return _errorState(provider);
    if (addresses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: Text('No saved addresses found')),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < addresses.length; i++)
          _addressCard(addresses[i], i),
      ],
    );
  }

  Widget _addressCard(SavedAddress address, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [
          BoxShadow(
            color: AppColors.primaryButton,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '📞 ${address.mobile}',
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '${address.address}, ${address.city}, ${address.state} ${address.pin}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          _iconButton(
            Icons.edit_outlined,
            const Color(0xFFF0F1FF),
            () => _message('Edit address ${index + 1}'),
          ),
          const SizedBox(width: 8),
          _iconButton(
            Icons.delete_outline,
            const Color(0xFFFFEEEE),
            () => _message('Delete address ${index + 1}'),
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, Color background, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 20),
        ),
      );

  Widget _bottomNavigation() => BottomNavigationBar(
    // This screen is opened from Profile, so no bottom-nav item is selected.
    // Keep the index valid for the four available items.
    currentIndex: 0,
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

  void _message(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}
