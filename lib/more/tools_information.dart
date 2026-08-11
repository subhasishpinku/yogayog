import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yogayog/CutOffTime/cut_of_time.dart';
import 'package:yogayog/branchaddresses/branchaddresses.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/contactpersons/contactpersons.dart';
import 'package:yogayog/nearesthub/nearesthub.dart';
import 'package:yogayog/paperworkrequired/paperwork_required.dart';
import 'package:yogayog/pincodecheck/check_pin.dart';

class ToolInformation extends StatefulWidget {
  const ToolInformation({super.key});

  @override
  State<ToolInformation> createState() => _ToolInformationState();
}

class _ToolInformationState extends State<ToolInformation> {
  static const black = AppColors.primaryMain;
  static const _pageBackground = Color(0xFFF4F4F8);

  final List<_ToolItem> _tools = const [
    _ToolItem(
      title: 'Cut-Off Time',
      subtitle: "Today's deadline · 3:00 PM",
      icon: Icons.alarm_outlined,
      iconBackground: Color(0xFFFFF6D8),
      iconColor: Color(0xFF151515),
      details: 'Shipments received before 3:00 PM are processed today.',
    ),
    _ToolItem(
      title: 'Nearest Hub',
      subtitle: 'Yogayog Tollounge Hub · 3.2 km',
      icon: Icons.storefront_outlined,
      iconBackground: Color(0xFFE4F3ED),
      iconColor: Color(0xFF08743D),
      details: 'Your nearest Yogayog hub is 3.2 km away.',
    ),
    _ToolItem(
      title: 'Branch Addresses',
      subtitle: '4 Yogayog branches nearby',
      icon: Icons.business_outlined,
      iconBackground: Color(0xFFEEF0FF),
      iconColor: Color(0xFF28358F),
      details: 'View the addresses of the four nearest branches.',
    ),
    _ToolItem(
      title: 'Contact Persons',
      subtitle: 'Operations, Support, Finance',
      icon: Icons.groups_outlined,
      iconBackground: Color(0xFFFFEAF0),
      iconColor: Color(0xFF252525),
      details: 'Find the right contact for operations, support, or finance.',
    ),
    _ToolItem(
      title: 'Paperwork Required',
      subtitle: 'Docs needed per shipment type',
      icon: Icons.assignment_outlined,
      iconBackground: Color(0xFFFFF6D8),
      iconColor: Color(0xFF252525),
      details: 'Check the documents needed for each shipment type.',
    ),
    _ToolItem(
      title: 'PIN Code Check',
      subtitle: 'Check serviceability before booking',
      icon: Icons.location_on_outlined,
      iconBackground: Color(0xFFE4F3ED),
      iconColor: Color(0xFF08743D),
      details: 'Check whether a PIN code is serviceable before booking.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _pageBackground,
        body: Column(
          children: [
            const _Header(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
                itemCount: _tools.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) => _ToolCard(
                  item: _tools[index],
                  onTap: () {
                    if (_tools[index].title == 'PIN Code Check') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CheCkPin()),
                      );
                      return;
                    }

                    if (_tools[index].title == 'Paperwork Required') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PaperworkRequired(),
                        ),
                      );
                      return;
                    }

                    if (_tools[index].title == 'Nearest Hub') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NearestHub()),
                      );
                      return;
                    }

                    if (_tools[index].title == 'Cut-Off Time') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CutOfTime()),
                      );
                      return;
                    }

                    if (_tools[index].title == 'Contact Persons') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ContactPersons(),
                        ),
                      );
                      return;
                    }

                    if (_tools[index].title == 'Branch Addresses') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const BranchAddresses(),
                        ),
                      );
                      return;
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: SizedBox(
        height: 125,
        child: Stack(
          children: [
            Container(color: _ToolInformationState.black),
            Positioned(
              right: -22,
              top: -35,
              child: Container(
                width: 145,
                height: 145,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryMain,
                  border: Border.all(color: AppColors.hintGray, width: 16),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 13, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'More',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tools & information for your outlet',
                      style: TextStyle(color: Color(0xFFB8DDC8), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final _ToolItem item;
  final VoidCallback onTap;

  const _ToolCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1.5,
      shadowColor: Colors.black12,
      child: Semantics(
        button: true,
        label: item.title,
        child: InkWell(
          onTap: onTap,
          mouseCursor: SystemMouseCursors.click,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 80,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: item.iconBackground,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(item.icon, color: item.iconColor, size: 29),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF7B8493),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF75808B),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String details;

  const _ToolItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.details,
  });
}
