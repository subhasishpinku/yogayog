import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:url_launcher/url_launcher.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/core/services/nearesthub_service.dart';
import 'package:yogayog/nearesthub/provider/nearesthub_provider.dart';
import 'package:provider/provider.dart';

class NearestHub extends StatefulWidget {
  const NearestHub({super.key});

  @override
  State<NearestHub> createState() => _NearestHubState();
}

class _NearestHubState extends State<NearestHub> {
  static const _black = AppColors.primaryMain;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCurrentLocation());
  }

  Future<void> _loadCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final places = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (!mounted || places.isEmpty) return;
      final place = places.first;
      final city = (place.locality ?? place.subAdministrativeArea ?? '').trim();
      const stateCodes = {'West Bengal': '19'};
      final stateCode = stateCodes[place.administrativeArea?.trim()];
      if (city.isNotEmpty && stateCode != null) {
        await context.read<NearestHubProvider>().loadNearbyHubs(
          city: city,
          stateCode: stateCode,
        );
      }
    } catch (_) {}
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _callHub(String phoneNumber) async {
    final phone = phoneNumber.trim();
    if (phone.isEmpty) {
      _showMessage('Contact number unavailable');
      return;
    }

    final launched = await launchUrl(Uri(scheme: 'tel', path: phone));
    if (!launched && mounted) {
      _showMessage('Unable to open phone dialer');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NearestHubProvider>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        // backgroundColor: AppColors.lightGray,
        backgroundColor: const Color(0xFFE3F4EE),
        body: Column(
          children: [
            const _HubHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _GoogleHubMap(),
                    if (provider.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (provider.hubs.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No nearby hubs found.'),
                      )
                    else
                      ...provider.hubs.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                          child: _PrimaryHubCard(
                            hub: entry.value,
                            isPrimary: entry.key == 0,
                            onCall: () => _callHub(entry.value.phoneNumber),
                            onDirections: () =>
                                _showMessage('Directions are ready to open'),
                          ),
                        ),
                      ),
                    const _SectionTitle('Hub Contacts'),
                    _ContactCard(
                      initials: 'RK',
                      name: 'Rajesh Kumar',
                      role: 'Hub Manager · 9831045678',
                      onCall: () => _showMessage('Calling Rajesh Kumar'),
                    ),
                    _ContactCard(
                      initials: 'SP',
                      name: 'Sumit Pal',
                      role: 'Operations · 9831012345',
                      onCall: () => _showMessage('Calling Sumit Pal'),
                    ),
                    const _SectionTitle('Hub Timings'),
                    const _TimingCard(),
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

class _HubHeader extends StatelessWidget {
  const _HubHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Reserve space for the status-bar inset and the two-line header text.
      height: 136,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Container(color: _NearestHubState._black),
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
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).maybePop(),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 36,
                          height: 36,
                          // decoration: BoxDecoration(
                          //   color: Colors.white.withValues(alpha: .15),
                          //   borderRadius: BorderRadius.circular(10),
                          // ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Nearest Hub',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Your mapped Yogayog processing hub',
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

class _GoogleHubMap extends StatelessWidget {
  const _GoogleHubMap();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: gmaps.GoogleMap(
        initialCameraPosition: const gmaps.CameraPosition(
          target: gmaps.LatLng(22.5726, 88.3639),
          zoom: 12.5,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        compassEnabled: false,
      ),
    );
  }
}

class _HubMap extends StatelessWidget {
  const _HubMap();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: CustomPaint(
        painter: _MapGridPainter(),
        child: Stack(
          children: [
            Positioned(
              top: 60,
              left: 79,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: _NearestHubState._black,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 8),
                  ],
                ),
                child: const Row(
                  children: [
                    Text('🏪', style: TextStyle(fontSize: 15)),
                    SizedBox(width: 5),
                    Text(
                      'Yogayog Tollounge Hub',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 91,
              left: 169,
              child: CustomPaint(
                size: const Size(20, 14),
                painter: _MapPointerPainter(),
              ),
            ),
            Positioned(
              top: 140,
              right: 72,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
                child: const Text(
                  'You',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFFE3F4EE), BlendMode.src);
    final paint = Paint()
      ..color = const Color(0x1808743D)
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapPointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = _NearestHubState._black);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PrimaryHubCard extends StatelessWidget {
  final NearbyHub hub;
  final bool isPrimary;
  final VoidCallback onCall;
  final VoidCallback onDirections;

  const _PrimaryHubCard({
    required this.hub,
    required this.isPrimary,
    required this.onCall,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 17),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7F1),
        border: Border.all(color: const Color(0xFFB3D9C7)),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  hub.hubName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (isPrimary) const _Badge('Primary'),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            hub.phoneNumber.isEmpty
                ? '📍 Nearby processing hub'
                : '📞 ${hub.phoneNumber}',
            style: TextStyle(
              color: _NearestHubState._black,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            hub.address.isEmpty ? 'Address unavailable' : hub.address,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Color(0xFF667085),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: onCall,
                  icon: const Text('📞'),
                  label: const Text(
                    'Call Hub',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF4C9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  onPressed: onDirections,
                  icon: const Text('🛫'),
                  label: const Text(
                    'Directions',
                    style: TextStyle(color: Color(0xFF6C5400)),
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

class _Badge extends StatelessWidget {
  final String text;
  const _Badge(this.text);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: _NearestHubState._black,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(10, 15, 10, 8),
    child: Text(
      title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
    ),
  );
}

class _ContactCard extends StatelessWidget {
  final String initials;
  final String name;
  final String role;
  final VoidCallback onCall;

  const _ContactCard({
    required this.initials,
    required this.name,
    required this.role,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      margin: const EdgeInsets.only(left: 7, right: 7, bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFE6F5EE),
              shape: BoxShape.circle,
            ),
            child: Text(
              initials,
              style: const TextStyle(
                color: _NearestHubState._black,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7B8493),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onCall,
            icon: const Text('📞'),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFEAF7F1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimingCard extends StatelessWidget {
  const _TimingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 7),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Column(
        children: [
          _TimingRow('Mon – Sat', '8:00 AM – 8:00 PM'),
          Divider(height: 12),
          _TimingRow('Sunday', 'Closed', valueColor: Colors.red),
          Divider(height: 12),
          _TimingRow(
            'Pickup from outlet',
            '4:00 PM daily',
            valueColor: _NearestHubState._black,
          ),
        ],
      ),
    );
  }
}

class _TimingRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _TimingRow(this.label, this.value, {this.valueColor = Colors.black});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: const TextStyle(color: Color(0xFF667085), fontSize: 13),
        ),
      ),
      Text(
        value,
        style: TextStyle(
          color: valueColor,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}
