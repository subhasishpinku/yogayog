import 'package:flutter/material.dart';

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
                  ),
                  _menuItem(
                    icon: Icons.location_on_outlined,
                    iconColor: const Color(0xFFFF493F),
                    title: 'Saved Addresses',
                  ),
                  _menuItem(
                    icon: Icons.credit_card,
                    iconColor: const Color(0xFFFFB800),
                    title: 'Payment Methods',
                  ),
                  _menuItem(
                    icon: Icons.notifications_none,
                    iconColor: const Color(0xFFFFC400),
                    title: 'Notifications',
                  ),
                  _menuItem(
                    icon: Icons.headphones_outlined,
                    iconColor: Colors.black,
                    title: 'Help & Support',
                  ),
                  _menuItem(
                    icon: Icons.description_outlined,
                    iconColor: Colors.black,
                    title: 'Terms & Privacy',
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
      color: const Color(0xFF202B91),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '+91 98765 43210',
                  style: TextStyle(
                    color: Color(0xFF858591),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _editProfile,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFEFF0FF),
              foregroundColor: const Color(0xFF172786),
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 7,
              ),
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => _showMessage(title + ' selected'),
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
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade500,
              ),
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
          border: Border.all(color: const Color(0xFFFFBABA)),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.logout,
              color: Colors.red,
              size: 26,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  void _editProfile() {
    _showMessage('Edit profile selected');
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
            onPressed: () {
              Navigator.pop(context);
              _showMessage('Logged out');
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
