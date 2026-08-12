import 'package:flutter/material.dart';
import 'package:yogayog/bikescreen/blick_local_screem.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/internationaldetails/international_details.dart';
import 'package:yogayog/internationalimport/internationalimport.dart';
import 'package:yogayog/nationaldetails/national_details.dart';
import 'package:yogayog/truckscreen/truck_local_screen.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({super.key});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  String? selectedTitle;

  static const Color blue = AppColors.primaryMain;
  static const Color yellow = AppColors.primaryButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 20),
                children: [
                  const Text(
                    'LOCAL RIDES · INSTANT BOOKING',
                    style: TextStyle(
                      color: Color(0xFF8A8F9C),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 10),

                  _localRideCard(
                    icon: '🏍️',
                    title: 'Bike',
                    description: 'Small parcels, docs, within city',
                    price: '₹49',
                    weight: 'Up to 20 kg',
                    time: 'Pickup in 15 min',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BikeLocalScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  _localRideCard(
                    icon: '🚚',
                    title: 'Truck',
                    description: 'Bulk goods, furniture, within city',
                    price: '₹399',
                    weight: 'Up to 1,500 kg',
                    time: 'Pickup in 45 min',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TruckLocalScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'LONG DISTANCE & FREIGHT',
                    style: TextStyle(
                      color: Color(0xFF8A8F9C),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 10),

                  _freightCard(
                    icon: '🚛',
                    title: 'National Delivery',
                    description: 'Door-to-door across India',
                    buttonText: 'Get Instant Quote →',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NationalDetails(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  _freightCard(
                    icon: '✈️',
                    title: 'International Exports',
                    description: 'Ship out of India — all docs handled',
                    buttonText: 'Start Export Shipment →',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InternationalDetails(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  _freightCard(
                    icon: '✈️',
                    title: 'International Import',
                    description: 'Ship out of India — all docs handled',
                    buttonText: 'Start Export Shipment →',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InternationalImport(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 100,
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            color: blue,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // GestureDetector(
                //   onTap: () => Navigator.pop(context),
                //   child: Container(
                //     width: 34,
                //     height: 34,
                //     decoration: BoxDecoration(
                //       color: Colors.white.withOpacity(0.18),
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //     child: const Icon(
                //       Icons.arrow_back,
                //       color: Colors.white,
                //       size: 20,
                //     ),
                //   ),
                // ),

                // const SizedBox(height: 6),
                const Text(
                  'What are you sending?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    height: 1.1,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 2),

                const Text(
                  'Choose a service to get started',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: -35,
            right: -30,
            child: Container(
              width: 135,
              height: 135,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.10),
                  width: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _localRideCard({
    required String icon,
    required String title,
    required String description,
    required String price,
    required String weight,
    required String time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedTitle = title;
        });

        onTap();
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: selectedTitle == title
              ? Border.all(color: yellow, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF0FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 25)),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    description,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),

                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [_infoChip(weight), _infoChip(time)],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 6),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    color: blue,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                _roundArrowButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _freightCard({
    required String icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 118,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: blue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -35,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.10),
                  width: 12,
                ),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(icon, style: const TextStyle(fontSize: 22)),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 35,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: yellow,
                    foregroundColor: blue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EBFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: blue,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _roundArrowButton() {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(color: yellow, shape: BoxShape.circle),
      child: const Icon(Icons.arrow_forward, color: blue, size: 17),
    );
  }
}
