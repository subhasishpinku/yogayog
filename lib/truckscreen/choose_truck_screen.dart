import 'package:flutter/material.dart';
import 'package:yogayog/bikescreen/bike_confirm_screen.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/truckscreen/truck_confirm_screen.dart';
import 'package:yogayog/core/services/truck_local_service.dart';

class ChooseTruckScreen extends StatefulWidget {
  const ChooseTruckScreen({
    super.key,
    this.approximateWeightKg = 0,
    this.volumetricWeightKg = 0,
    required this.rateResponse,
    required this.pickup,
    required this.drop,
    this.pickupAddress = '',
    this.dropAddress = '',
  });

  final double approximateWeightKg;
  final double volumetricWeightKg;
  final TruckRateResponse rateResponse;
  final Map<String, dynamic> pickup;
  final Map<String, dynamic> drop;
  final String pickupAddress;
  final String dropAddress;

  @override
  State<ChooseTruckScreen> createState() => _ChooseTruckScreenState();
}

class _ChooseTruckScreenState extends State<ChooseTruckScreen> {
  static const Color blue = AppColors.primaryMain;
  static const Color yellow = AppColors.primaryButton;

  int selectedVehicle = 0;
  bool scheduleLater = false;

  List<TruckVehicleRate> get vehicles => widget.rateResponse.rates;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            _header(context),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
                children: [
                  _steps(),

                  const SizedBox(height: 14),

                  ...List.generate(
                    vehicles.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _vehicleCard(index),
                    ),
                  ),

                  _scheduleCard(),

                  const SizedBox(height: 28),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TruckConfirmScreen(
                              rate: vehicles[selectedVehicle],
                              distance: widget.rateResponse.distance,
                              pickup: widget.pickup,
                              drop: widget.drop,
                              pickupAddress: widget.pickupAddress,
                              dropAddress: widget.dropAddress,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: yellow,
                        foregroundColor: blue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Continue →',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      height: 100,
      width: double.infinity,
      color: blue,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.18),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              const Text(
                'Choose Vehicle',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 3),

          const Text(
            'Prices include pickup & drop',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _steps() {
    return Row(
      children: [
        _step('✓', 'Address', true),
        _line(),
        _step('2', 'Vehicle', true),
        _line(),
        _step('3', 'Confirm', false),
      ],
    );
  }

  Widget _step(String number, String label, bool active) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: number == '✓'
                ? blue
                : active
                ? yellow
                : Colors.white,
            border: Border.all(color: active ? blue : const Color(0xFFD9DCE5)),
          ),
          child: Text(
            number,
            style: TextStyle(
              color: number == '✓'
                  ? Colors.white
                  : active
                  ? blue
                  : const Color(0xFF8A8F9C),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: active ? blue : const Color(0xFF8A8F9C),
            fontSize: 10,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _line() {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: const Color(0xFFD9DCE5),
      ),
    );
  }

  Widget _vehicleCard(int index) {
    final vehicle = vehicles[index];
    final selected = selectedVehicle == index;

    return GestureDetector(
      onTap: () => setState(() => selectedVehicle = index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? blue : Colors.transparent,
            width: selected ? 2 : 0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF0FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  vehicle.vehicleType.toLowerCase().contains('truck') ? '🚚' : '🚛',
                  style: const TextStyle(fontSize: 27),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.vehicleType.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    'Distance ${widget.rateResponse.distance.toStringAsFixed(2)} km',
                    style: const TextStyle(
                      color: Color(0xFF8A8F9C),
                      fontSize: 11,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text('Base ₹${vehicle.basePrice.toStringAsFixed(2)} + GST', style: const TextStyle(color: blue, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(width: 6),

            Column(
              children: [
                Text(
                  '₹${vehicle.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: blue,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Text(
                  'est. fare',
                  style: TextStyle(color: Color(0xFF8A8F9C), fontSize: 10),
                ),

                const SizedBox(height: 5),

                Container(
                  width: 19,
                  height: 19,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? blue : const Color(0xFFD9DCE5),
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? Center(
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              color: blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _scheduleCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Schedule for later?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 3),
                Text(
                  'Default: pickup now',
                  style: TextStyle(color: Color(0xFF8A8F9C), fontSize: 11),
                ),
              ],
            ),
          ),

          Switch(
            value: scheduleLater,
            activeColor: blue,
            onChanged: (value) {
              setState(() => scheduleLater = value);
            },
          ),
        ],
      ),
    );
  }
}
