import 'package:flutter/material.dart';
import 'package:yogayog/bikescreen/choose_bike_screen.dart';
import 'package:yogayog/constants/app_colors.dart';

class TruckLocalScreen extends StatefulWidget {
  const TruckLocalScreen({super.key});

  @override
  State<TruckLocalScreen> createState() => _TruckLocalScreenState();
}

class _TruckLocalScreenState extends State<TruckLocalScreen> {
  final packageController = TextEditingController();
  final weightController = TextEditingController(text: '2');

  static const Color blue = AppColors.primaryMain;
  static const Color yellow = AppColors.primaryButton;
  @override
  @override
  void dispose() {
    packageController.dispose();
    weightController.dispose();
    super.dispose();
  }

  void _chooseVehicle() {
    if (packageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter package description')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChooseBikeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSteps(),

                    const SizedBox(height: 14),

                    _buildLocationCard(),

                    const SizedBox(height: 16),

                    const Text(
                      'PACKAGE DESCRIPTION',
                      style: TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: .6,
                      ),
                    ),

                    const SizedBox(height: 6),

                    TextField(
                      controller: packageController,
                      decoration: _inputDecoration(
                        'e.g. Documents, parcel, spare parts...',
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'APPROX. WEIGHT',
                      style: TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: .6,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: weightController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration('2 kg'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 90,
                          height: 49,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE0E2E8)),
                          ),
                          child: const Text(
                            'kg',
                            style: TextStyle(
                              color: Color(0xFF667085),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChooseBikeScreen(),
                          ),
                        );
                      },
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _chooseVehicle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: yellow,
                            foregroundColor: blue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Choose Vehicle →',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 188,
      width: double.infinity,
      child: Container(
        color: blue,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              'Local Delivery',
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 3),

            const Text(
              'Bike or Truck — picked up in minutes',
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSteps() {
    return Row(
      children: [
        _stepItem('1', 'Address', true),
        _stepLine(),
        _stepItem('2', 'Vehicle', false),
        _stepLine(),
        _stepItem('3', 'Confirm', false),
      ],
    );
  }

  Widget _stepItem(String number, String title, bool active) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? yellow : Colors.white,
            border: Border.all(
              color: active ? const Color(0xFFD6A900) : const Color(0xFFD9DCE5),
              width: 1.5,
            ),
          ),
          child: Text(
            number,
            style: TextStyle(
              color: active ? blue : const Color(0xFF8A8F9C),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(
            color: active ? blue : const Color(0xFF8A8F9C),
            fontSize: 10,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _stepLine() {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: const Color(0xFFD9DCE5),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _locationIndicator(yellow),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PICKUP',
                      style: TextStyle(
                        color: Color(0xFF8A8F9C),
                        fontSize: 11,
                        letterSpacing: .8,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Jodhpur Park, Kolkata',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '700068, West Bengal',
                      style: TextStyle(color: Color(0xFF8A8F9C), fontSize: 13),
                    ),
                  ],
                ),
              ),

              TextButton(
                onPressed: () {},
                child: const Text(
                  'Edit',
                  style: TextStyle(color: blue, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const Divider(height: 22),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _locationIndicator(blue),

              const SizedBox(width: 14),

              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DROP',
                    style: TextStyle(
                      color: Color(0xFF8A8F9C),
                      fontSize: 11,
                      letterSpacing: .8,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Tap to add destination',
                    style: TextStyle(color: Color(0xFF8A8F9C), fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _locationIndicator(Color color) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Container(width: 2, height: 30, color: const Color(0xFFD9DCE5)),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF667085), fontSize: 15),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE0E2E8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE0E2E8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: blue, width: 1.5),
      ),
    );
  }
}
