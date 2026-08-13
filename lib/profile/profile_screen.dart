import 'package:flutter/material.dart';
import 'package:yogayog/Invoices/invoices_screen.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/helpsupport/help_support.dart';
import 'package:yogayog/history/history_screen.dart';
import 'package:yogayog/history/myshipmentes/my_shipments.dart';
import 'package:yogayog/mybooking/my_booking.dart';
import 'package:yogayog/mywallet/mywallet.dart';
import 'package:yogayog/profile/profile_edit_screen.dart';
import 'package:yogayog/savedaddresses/savedaddresses.dart';
import 'package:yogayog/OnboardingScreen/onboarding_screen.dart';
import 'package:yogayog/profile/provider/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:yogayog/termsprivacy/term_privacy.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4FA),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                children: [
                  _profileCard(),
                  const SizedBox(height: 14),
                  _menuItem(
                    icon: Icons.inventory_2_outlined,
                    iconColor: const Color(0xFFD49A67),
                    title: 'My Shipments',
                    onTap: () => _open(const HistoryScreen()),
                  ),
                  _menuItem(
                    icon: Icons.location_on_outlined,
                    iconColor: const Color(0xFFFF493F),
                    title: 'Saved Addresses',
                    onTap: () => _open(const Savedaddresses()),
                  ),
                  _menuItem(
                    icon: Icons.credit_card,
                    iconColor: const Color(0xFFFFB800),
                    title: 'My Wallet',
                    onTap: () => _open(const MyWallet()),
                  ),
                  _menuItem(
                    icon: Icons.book_online,
                    iconColor: const Color(0xFFFFC400),
                    title: 'Booking History',
                    onTap: () => _open(const MyShipments()),
                  ),
                  _menuItem(
                    icon: Icons.bookmark_border_rounded,
                    iconColor: const Color(0xFFFFC400),
                    title: 'My Bookings',
                    onTap: () => _open(const MyBooking()),
                  ),
                  _menuItem(
                    icon: Icons.description_outlined,
                    iconColor: const Color(0xFFFFC400),
                    title: 'Invoices',
                    onTap: () => _open(const InvoicesScreen()),
                  ),
                  _menuItem(
                    icon: Icons.headphones_outlined,
                    iconColor: Colors.black,
                    title: 'Help & Support',
                    onTap: () => _open(const HelpSupport()),
                  ),
                  _menuItem(
                    icon: Icons.description_outlined,
                    iconColor: Colors.black,
                    title: 'Terms & Privacy',
                    onTap: () => _open(const TermPrivacy()),
                  ),
                  const SizedBox(height: 2),
                  _logoutItem(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      color: AppColors.primaryMain,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      child: const Text(
        'My Profile',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC400),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Text(
              'RK',
              style: TextStyle(
                color: Color(0xFF172786),
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rajan Kumar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  '+91 98765 43210',
                  style: TextStyle(color: Color(0xFF858591), fontSize: 13),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _editProfile,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFEFF0FF),
              foregroundColor: const Color(0xFF172786),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Edit',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 27),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoutItem() {
    return InkWell(
      onTap: _logout,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          // border: Border.all(color: const Color(0xFFFFBABA)),
        ),
        child: const Row(
          children: [
            Icon(Icons.logout, color: Colors.black, size: 26),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.black),
          ],
        ),
      ),
    );
  }

  void _editProfile() {
    _showMessage('Edit profile selected');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
    );
  }

  void _open(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _logout() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: context.watch<ProfileProvider>().isLoading
                ? null
                : () => _confirmLogout(context),
            child: context.watch<ProfileProvider>().isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext dialogContext) async {
    Navigator.pop(dialogContext);
    final provider = context.read<ProfileProvider>();
    final loggedOut = await provider.logout();
    if (!mounted) return;

    if (!loggedOut) {
      _showMessage(provider.errorMessage ?? 'Unable to log out');
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      (_) => false,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _MenuPlaceholder extends StatelessWidget {
  final String title;

  const _MenuPlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title screen')),
    );
  }
}
