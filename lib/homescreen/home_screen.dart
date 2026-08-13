import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yogayog/bikescreen/blick_local_screem.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/history/history_screen.dart';
import 'package:yogayog/homescreen/home_provider.dart';
import 'package:provider/provider.dart';
import 'package:yogayog/internationalimport/internationalimport.dart';
import 'package:yogayog/profile/profile_screen.dart';
import 'package:yogayog/profile/provider/profile_provider.dart';
import 'package:yogayog/mywallet/mywallet.dart';
import 'package:yogayog/OnboardingScreen/onboarding_screen.dart';
import 'package:yogayog/bikescreen/choose_bike_screen.dart';
import 'package:yogayog/truckscreen/choose_truck_screen.dart';
import 'package:yogayog/nationaldetails/national_details.dart';
import 'package:yogayog/internationaldetails/international_details.dart';
import 'package:yogayog/truckscreen/truck_local_screen.dart';
import 'package:yogayog/history/provider/history_provider.dart';
import 'package:yogayog/core/services/history_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentAddress = 'Fetching current location...';
  double? _currentLatitude;
  double? _currentLongitude;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<HomeProvider>().loadProfile();
      if (mounted) context.read<HistoryProvider>().loadBookings();
      _loadCurrentLocation();
    });
  }

  Future<void> _loadCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted)
          setState(() => _currentAddress = 'Location service is off');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted)
          setState(() => _currentAddress = 'Location permission not granted');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      var address = 'Current location';
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts =
            [
                  place.name,
                  place.street,
                  place.subLocality,
                  place.locality,
                  place.subAdministrativeArea,
                  place.administrativeArea,
                  place.postalCode,
                  place.country,
                ]
                .whereType<String>()
                .map((part) => part.trim())
                .where((part) => part.isNotEmpty)
                .toList();
        address = parts.toSet().join(', ');
      }

      if (!mounted) return;
      setState(() {
        _currentAddress = address;
        _currentLatitude = position.latitude;
        _currentLongitude = position.longitude;
      });
    } catch (_) {
      if (mounted) setState(() => _currentAddress = 'Unable to fetch location');
    }
  }

  // static const blue = Color(0xFF202A8D);
  // static const yellow = Color(0xFFFFC400);
  static const Color blue = AppColors.primaryMain;
  static const Color yellow = AppColors.primaryButton;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 12),
                children: [
                  _buildCategories(),
                  _buildActiveShipment(),
                  _buildServices(),
                  _buildRecentShipmentsFromApi(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 👋';
    if (hour < 17) return 'Good afternoon 👋';
    if (hour < 21) return 'Good evening 👋';
    return 'Good night 🌙';
  }

  Widget _buildHeader() {
    final profile = context.watch<HomeProvider>().profile;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: const BoxDecoration(
        color: blue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _timeGreeting(),
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ),
              Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MyWallet()),
                          );
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: yellow,
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: yellow,
                          child: Text(
                            profile?.initials ?? 'U',
                            style: const TextStyle(
                              color: blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 50,
                        child: ElevatedButton.icon(
                          onPressed: _logout,
                          // icon: const Icon(Icons.logout, size: 12),
                          label: const Text(
                            'Logout',
                            style: TextStyle(fontSize: 10),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: yellow,
                            foregroundColor: blue,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 2),
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
            ],
          ),
          const SizedBox(height: 3),

          Transform.translate(
            offset: const Offset(0, -10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            profile?.name.isNotEmpty == true
                                ? profile!.name
                                : 'Loading...',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 5),
                      if (profile?.email.isNotEmpty == true) ...[
                        const SizedBox(height: 3),
                        Text(
                          'Email: ${profile!.email}  Number: ${profile.mobile}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],

                      // if (profile?.mobile.isNotEmpty == true) ...[
                      //   const SizedBox(height: 2),
                      //   Text(
                      //     profile!.mobile,
                      //     style: const TextStyle(
                      //       color: Colors.white70,
                      //       fontSize: 12,
                      //     ),
                      //   ),
                      // ],
                      if (profile?.address?.isNotEmpty == true ||
                          profile?.city?.isNotEmpty == true ||
                          profile?.pin?.isNotEmpty == true ||
                          profile?.state?.isNotEmpty == true) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Profile address: ${[if (profile?.address?.isNotEmpty == true) profile!.address!, if (profile?.city?.isNotEmpty == true) profile!.city!, if (profile?.pin?.isNotEmpty == true) profile!.pin!, if (profile?.state?.isNotEmpty == true) profile!.state!].join(' - ')}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          // const Icon(
                          //   Icons.my_location,
                          //   color: yellow,
                          //   size: 13,
                          // ),
                          // const SizedBox(width: 4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // const Text(
                                //   'Current address:',
                                //   style: TextStyle(
                                //     color: Colors.white54,
                                //     fontSize: 10,
                                //     fontWeight: FontWeight.w600,
                                //   ),
                                // ),
                                Text(
                                  _currentLatitude != null &&
                                          _currentLongitude != null
                                      ? 'Current address: $_currentAddress · '
                                            'Lat: ${_currentLatitude!.toStringAsFixed(6)} · '
                                            'Lng: ${_currentLongitude!.toStringAsFixed(6)}'
                                      : _currentAddress,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // const SizedBox(height: 5),

          // TextField(
          //   decoration: InputDecoration(
          //     hintText: 'Book a delivery or track...',
          //     hintStyle: const TextStyle(color: Colors.white54),
          //     prefixIcon: const Icon(Icons.search, color: Colors.white54),
          //     filled: true,
          //     fillColor: Colors.white.withOpacity(.15),
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(10),
          //       borderSide: BorderSide.none,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Category(
            icon: '🏍️',
            title: 'Local Bike',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BikeLocalScreen()),
            ),
          ),
          _Category(
            icon: '🚚',
            title: 'Local Truck',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TruckLocalScreen()),
            ),
          ),
          _Category(
            icon: '🚛',
            title: 'National',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NationalDetails()),
            ),
          ),
          _Category(
            icon: '🌍',
            title: "Int'Export",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InternationalDetails()),
            ),
          ),
          _Category(
            icon: '🌍',
            title: "Int'Import",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InternationalImport()),
            ),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final provider = context.read<ProfileProvider>();
              final loggedOut = await provider.logout();
              if (!mounted) return;

              if (!loggedOut) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.errorMessage ?? 'Unable to log out'),
                  ),
                );
                return;
              }

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                (_) => false,
              );
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveShipment() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: blue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Shipment',
                  style: TextStyle(color: Colors.white60, fontSize: 11),
                ),
                SizedBox(height: 3),
                Text(
                  'YCG-2025-00891',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '• In Transit - Kolkata → Delhi',
                  style: TextStyle(color: yellow, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _showTrackingDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: yellow,
              foregroundColor: blue,
              elevation: 0,
            ),
            child: const Text('Track Live'),
          ),
        ],
      ),
    );
  }

  Future<void> _showTrackingDialog() async {
    final awbController = TextEditingController();
    final awb = await showDialog<String>(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Track your order',
                  style: TextStyle(
                    color: blue,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enter your AWB or order number to view live status.',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: awbController,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'AWB / Order number',
                    hintText: 'e.g. 1222000020',
                    prefixIcon: const Icon(Icons.local_shipping_outlined),
                    filled: true,
                    fillColor: const Color(0xFFF5F7FB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        FocusScope.of(dialogContext).unfocus();
                        final value = awbController.text.trim();
                        if (value.isNotEmpty)
                          Navigator.pop(dialogContext, value);
                      },
                      icon: const Icon(Icons.search, size: 17),
                      label: const Text('Track order'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    // The dialog route is still finishing its close animation when
    // showDialog returns. Dispose after that animation so TextField does not
    // try to rebuild with an already-disposed controller.
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      awbController.dispose();
    });

    if (!mounted || awb == null || awb.isEmpty) return;
    _showTrackingDetails(awb);
  }

  void _showTrackingDetails(String awb) {
    final profile = context.read<HomeProvider>().profile;
    final date =
        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';

    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
                decoration: const BoxDecoration(
                  color: blue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: yellow),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Order Tracking',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text(
                  'Order Information',
                  style: TextStyle(
                    color: blue,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Color(0xFFE8EBF2)),
                ),
                child: Wrap(
                  runSpacing: 16,
                  children: [
                    _trackingInfo('Order ID', awb),
                    _trackingInfo('Date', date),
                    _trackingInfo('Amount', '₹162.75'),
                    _trackingInfo('Recipient', profile?.name ?? 'Customer'),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  'Tracking History',
                  style: TextStyle(
                    color: blue,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _trackingEvent(
                'PENDING',
                'Status was: PENDING',
                date,
                '11:28 AM',
              ),
              _trackingEvent(
                'ORDER RECEIVED',
                'Status was: ORDER RECEIVED',
                date,
                '11:45 AM',
              ),
              _trackingEvent(
                'ORDER RECEIVED',
                'Order is being processed',
                date,
                '02:31 PM',
                isLast: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _trackingInfo(String label, String value) {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _trackingEvent(
    String title,
    String subtitle,
    String date,
    String time, {
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 18,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: blue,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: Colors.grey.shade300),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 76,
                      child: Text(
                        '$date\n$time',
                        maxLines: 2,
                        overflow: TextOverflow.visible,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServices() {
    return Column(
      children: [
        _sectionTitle('Our Services', 'View all'),
        SizedBox(
          height: 145,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            children: const [
              _ServiceCard(
                icon: '🏍️',
                title: 'Local – Bike',
                subtitle: 'Within city',
                price: 'From ₹49',
              ),
              _ServiceCard(
                icon: '🚚',
                title: 'Local – Truck',
                subtitle: 'Within city',
                price: 'From ₹399',
              ),
              _ServiceCard(
                icon: '🚛',
                title: 'National',
                subtitle: 'Pan-India',
                price: 'From ₹89/kg',
              ),
              _ServiceCard(
                icon: '🌍',
                title: "Int'l Import",
                subtitle: 'Worldwide',
                price: 'From ₹499',
              ),
              _ServiceCard(
                icon: '✈️',
                title: "Int'l Export",
                subtitle: 'Worldwide',
                price: 'From ₹599',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInternationalServices() {
    return SizedBox(
      height: 145,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        children: const [
          _ServiceCard(
            icon: '🌍',
            title: "Int'l Import",
            subtitle: 'Worldwide',
            price: 'From ₹499',
          ),
          _ServiceCard(
            icon: '✈️',
            title: "Int'l Export",
            subtitle: 'Worldwide',
            price: 'From ₹599',
          ),
        ],
      ),
    );
  }

  Widget _buildRecentShipmentsFromApi() {
    final history = context.watch<HistoryProvider>();

    return Column(
      children: [
        _sectionTitle(
          'Recent Shipments',
          'See all',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HistoryScreen()),
          ),
        ),
        if (history.isLoading)
          const Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          )
        else if (history.errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              history.errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          )
        else if (history.history == null ||
            history.history!.ordersToDisplay.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'No recent shipments found.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          )
        else
          ...history.history!.ordersToDisplay.take(3).map(_bookingTile),
      ],
    );
  }

  Widget _bookingTile(Booking booking) {
    final route = [
      booking.pickupCity,
      booking.dropCity,
    ].where((city) => city.trim().isNotEmpty).join(' → ');
    final details = [
      booking.orderNo,
      booking.orderDate,
    ].where((value) => value.trim().isNotEmpty).join(' · ');

    return _shipment(
      _bookingIcon(booking.serviceName),
      route.isEmpty ? 'Shipment' : route,
      details.isEmpty ? booking.subServiceName : details,
      booking.status.isEmpty ? 'Processing' : booking.status,
    );
  }

  String _bookingIcon(String serviceName) {
    final service = serviceName.toLowerCase();
    if (service.contains('bike')) return '🏍️';
    if (service.contains('truck')) return '🚚';
    if (service.contains('international') || service.contains('export')) {
      return '✈️';
    }
    return '🚛';
  }

  Widget _buildRecentShipments() {
    return Column(
      children: [
        _sectionTitle('Recent Shipments', 'See all'),
        _shipment('🚚', 'New Delhi', 'YCG-2025-00891 · Jul 28', 'In Transit'),
        _shipment('📦', 'Mumbai, MH', 'YCG-2025-00872 · Jul 26', 'Delivered'),
      ],
    );
  }

  Widget _sectionTitle(String title, String action, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const Spacer(),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              child: Text(
                action,
                style: const TextStyle(
                  color: blue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shipment(String icon, String location, String number, String status) {
    final isDelivered = status.toLowerCase().contains('delivered');
    final isTransit = status.toLowerCase().contains('transit');
    final statusColor = isDelivered
        ? const Color(0xFF08743D)
        : isTransit
        ? const Color(0xFFB36A00)
        : blue;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFE9F3FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 23)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  number,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF7B8493),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Category extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;

  const _Category({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: const Color(0xFFE9EDFF),
              child: Text(icon, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String price;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 105,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
          const Spacer(),
          Text(
            price,
            style: const TextStyle(
              color: Color(0xFF202A8D),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
