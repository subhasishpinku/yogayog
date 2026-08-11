import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/pincodecheck/proceed_oda_booking.dart';

class CheCkPinService extends StatefulWidget {
  final String pinCode;

  const CheCkPinService({super.key, this.pinCode = '110001'});

  @override
  State<CheCkPinService> createState() => _CheCkPinServiceState();
}

class _CheCkPinServiceState extends State<CheCkPinService> {
  static const black = AppColors.primaryMain;
  static const _lightGreen = Color(0xFFE4F6EA);

  @override
  Widget build(BuildContext context) {
    final location = widget.pinCode == '110001' ? 'Delhi' : 'New destination';
    final address = widget.pinCode == '110001' ? 'New Delhi, NCT' : 'India';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _ResultHeader(pinCode: widget.pinCode, location: location),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(6, 8, 6, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ResultCard(pinCode: widget.pinCode, address: address),
                    const SizedBox(height: 17),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 7),
                      child: Text(
                        'Service Availability',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const _ServiceList(),
                    const SizedBox(height: 12),
                    const _CutoffNote(),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      height: 57,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Booking flow is ready to start.'),
                            ),
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProceedOdaBooking(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryButton,
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
                        child: Text('Book Shipment to ${widget.pinCode} →'),
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

class _ResultHeader extends StatelessWidget {
  final String pinCode;
  final String location;

  const _ResultHeader({required this.pinCode, required this.location});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: SizedBox(
        // The header includes the system status-bar inset. Keep a little
        // extra room so the title does not overflow on smaller devices.
        height: 132,
        child: Stack(
          children: [
            Container(color: _CheCkPinServiceState.black),
            Positioned(
              right: -2,
              top: -57,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.hintGray, width: 15),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(13, 6, 13, 0),
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
                          color: Colors.white.withValues(alpha: 0.16),
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
                    Text(
                      'PIN $pinCode – $location',
                      style: const TextStyle(
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
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String pinCode;
  final String address;

  const _ResultCard({required this.pinCode, required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 155,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryButton, Color(0xFF12A65D)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFF11C909),
              border: Border.all(color: Colors.black, width: 4),
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 42),
          ),
          const SizedBox(height: 8),
          const Text(
            'Serviceable!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'PIN $pinCode · $address',
            style: const TextStyle(color: Color(0xFFB8DDC8), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ServiceList extends StatelessWidget {
  const _ServiceList();

  @override
  Widget build(BuildContext context) {
    const services = [
      _ServiceData(
        title: 'Local – Bike',
        subtitle: 'Same city only',
        icon: Icons.two_wheeler,
        available: false,
      ),
      _ServiceData(
        title: 'Local – Truck',
        subtitle: 'Same city only',
        icon: Icons.local_shipping,
        available: false,
      ),
      _ServiceData(
        title: 'National',
        subtitle: '3–4 days · Delhivery',
        icon: Icons.local_shipping,
        iconColor: Color(0xFF32B632),
        available: true,
      ),
      _ServiceData(
        title: "Int'l Export",
        subtitle: 'Via IGI Airport',
        icon: Icons.flight_takeoff,
        available: true,
      ),
      _ServiceData(
        title: "Int'l Import",
        subtitle: 'Customs at Delhi',
        icon: Icons.flight_land,
        available: true,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var index = 0; index < services.length; index++) ...[
            _ServiceRow(data: services[index]),
            if (index < services.length - 1)
              const Divider(height: 1, indent: 51, color: Color(0xFFE8E8ED)),
          ],
        ],
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final _ServiceData data;

  const _ServiceRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 17),
        child: Row(
          children: [
            Icon(data.icon, size: 24, color: data.iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    data.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF98A2B3),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: data.available
                    ? _CheCkPinServiceState._lightGreen
                    : const Color(0xFFF2F3F7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                data.available ? '✓ Available' : 'N/A',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: data.available
                      ? _CheCkPinServiceState.black
                      : const Color(0xFF667085),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CutoffNote extends StatelessWidget {
  const _CutoffNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F6EF),
        border: Border.all(color: const Color(0xFFB5DCC7)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '⏱ Cut-off today:',
              style: TextStyle(
                color: _CheCkPinServiceState.black,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '3:00 PM',
              style: TextStyle(
                color: _CheCkPinServiceState.black,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              'Book before cut-off for same-day pickup by rider.',
              style: TextStyle(
                color: _CheCkPinServiceState.black,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool available;

  const _ServiceData({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconColor = Colors.black,
    required this.available,
  });
}
