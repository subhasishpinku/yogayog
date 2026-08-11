import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yogayog/constants/app_colors.dart';

class BranchAddresses extends StatefulWidget {
  const BranchAddresses({super.key});

  @override
  State<BranchAddresses> createState() => _BranchAddressesState();
}

class _BranchAddressesState extends State<BranchAddresses> {
  static const _green = AppColors.primaryMain;

  final _branches = const [
    _Branch(
      name: 'Head Office – Kolkata',
      type: 'Primary Branch · 5.8 km',
      icon: '⭐',
      badge: 'HQ',
      address: '14A, Shakespeare Sarani, Elgin,\nKolkata – 700071, West Bengal',
      hours: 'Mon–Sat: 9 AM – 6 PM',
    ),
    _Branch(
      name: 'Tollygunge Processing Hub',
      type: 'Hub · 3.2 km',
      icon: '🏪',
      address: '12, Deshpran Sasmal Rd,\nTollygunge, Kolkata – 700033',
      hours: 'Mon–Sat: 8 AM – 8 PM',
    ),
    _Branch(
      name: 'Salt Lake Branch',
      type: 'Branch · 8.1 km',
      icon: '🏢',
      address: 'CF-204, Sector 1, Salt Lake City,\nKolkata – 700064',
      hours: 'Mon–Sat: 9 AM – 6 PM',
    ),
    _Branch(
      name: 'Howrah Branch',
      type: 'Branch · 12.4 km',
      icon: '🏢',
      address: '21, GT Road, Howrah,\nKolkata – 711101',
      hours: 'Mon–Sat: 9 AM – 6 PM',
    ),
  ];

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _green,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F8),
        body: Column(
          children: [
            const _BranchHeader(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(7, 8, 7, 24),
                itemCount: _branches.length,
                itemBuilder: (context, index) {
                  final branch = _branches[index];
                  return _BranchCard(
                    branch: branch,
                    onCall: () => _showMessage('Calling ${branch.name}'),
                    onDirections: () =>
                        _showMessage('Directions are ready to open'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BranchHeader extends StatelessWidget {
  const _BranchHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 136,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Container(color: _BranchAddressesState._green),
          Positioned(
            right: -18,
            top: -58,
            child: Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.hintGray, width: 15),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 7, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Branch Addresses',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'Yogayog offices near you',
                    style: TextStyle(color: Color(0xFFB8DDC8), fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  final _Branch branch;
  final VoidCallback onCall;
  final VoidCallback onDirections;

  const _BranchCard({
    required this.branch,
    required this.onCall,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 16),
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
            children: [
              Expanded(
                child: Text(
                  branch.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (branch.badge != null) _SmallBadge(branch.badge!),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${branch.icon} ${branch.type}',
            style: const TextStyle(
              color: _BranchAddressesState._green,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '📍 ${branch.address}',
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '◷ ${branch.hours}',
            style: const TextStyle(color: Color(0xFF667085), fontSize: 13),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: onCall,
                  icon: const Text('📞'),
                  label: const Text(
                    'Call',
                    style: TextStyle(color: Colors.black),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFE8F5EF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton.icon(
                  onPressed: onDirections,
                  icon: const Text('🛫'),
                  label: const Text(
                    'Directions',
                    style: TextStyle(color: Color(0xFF6C5400)),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF4C9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String label;
  const _SmallBadge(this.label);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F5EF),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: _BranchAddressesState._green,
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _Branch {
  final String name;
  final String type;
  final String icon;
  final String? badge;
  final String address;
  final String hours;

  const _Branch({
    required this.name,
    required this.type,
    required this.icon,
    this.badge,
    required this.address,
    required this.hours,
  });
}
