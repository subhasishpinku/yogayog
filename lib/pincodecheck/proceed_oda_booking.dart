import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yogayog/constants/app_colors.dart';

class ProceedOdaBooking extends StatefulWidget {
  const ProceedOdaBooking({super.key});

  @override
  State<ProceedOdaBooking> createState() => _ProceedOdaBookingState();
}

class _ProceedOdaBookingState extends State<ProceedOdaBooking> {
  static const _black = AppColors.primaryMain;
  static const _yellow = Color(0xFFFFC400);
  static const _pageBackground = Color(0xFFF4F4F8);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _pageBackground,
        body: Column(
          children: [
            const _OdaHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(7, 8, 7, 34),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _OdaCard(),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(5, 15, 5, 10),
                      child: Text(
                        'Service Status',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const _StatusCard(),
                    const SizedBox(height: 12),
                    const _SurchargeNotice(),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      height: 57,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'ODA booking flow is ready to start.',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _yellow,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        child: const Text('Proceed with ODA Booking →'),
                      ),
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

class _OdaHeader extends StatelessWidget {
  const _OdaHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Account for the status-bar inset so the title and subtitle remain
      // inside the header on devices with larger text scaling.
      height: 134,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Container(color: _ProceedOdaBookingState._black),
          Positioned(
            right: -17,
            top: -62,
            child: Container(
              width: 134,
              height: 134,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.hintGray, width: 15),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(11, 7, 11, 0),
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
                    'PIN 795001 - Imphal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'Serviceability result',
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

class _OdaCard extends StatelessWidget {
  const _OdaCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 156,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9D2507), Color(0xFFC83A2A)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber, color: Colors.black, size: 53),
          SizedBox(height: 1),
          Text(
            'ODA Zone',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'PIN 795001 · Imphal, Manipur',
            style: TextStyle(color: Color(0xFFFFD6D0), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: const Column(
        children: [
          _StatusRow(
            icon: Icons.local_shipping,
            title: 'National',
            subtitle: '7–10 days',
            badge: 'ODA +₹80',
            badgeColor: Color(0xFFFFF4CC),
            textColor: Color(0xFF6C5400),
          ),
          Divider(height: 1, indent: 52, color: Color(0xFFE8E8ED)),
          _StatusRow(
            icon: Icons.cloud,
            title: "Int'l Export",
            badge: 'Not Available',
            badgeColor: Color(0xFFFFEEEE),
            textColor: Colors.red,
          ),
          Divider(height: 1, indent: 52, color: Color(0xFFE8E8ED)),
          _StatusRow(
            icon: Icons.flight_land,
            title: "Int'l Import",
            badge: 'Not Available',
            badgeColor: Color(0xFFFFEEEE),
            textColor: Colors.red,
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String badge;
  final Color badgeColor;
  final Color textColor;

  const _StatusRow({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 17),
        child: Row(
          children: [
            Icon(icon, size: 23, color: Colors.black),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF7B8493),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: 11,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurchargeNotice extends StatelessWidget {
  const _SurchargeNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        border: Border.all(color: const Color(0xFFFFBABA)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        '⚠ ODA surcharge of ₹80 applies for National\ndelivery. Customer must be informed before booking.',
        style: TextStyle(color: Colors.red, fontSize: 12, height: 1.45),
      ),
    );
  }
}
