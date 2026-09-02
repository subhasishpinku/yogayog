import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yogayog/constants/app_colors.dart';

class ShipmentDetails extends StatefulWidget {
  const ShipmentDetails({
    super.key,
    required this.addressController,
    required this.pickupHouseNumberController,
    required this.dropHouseNumberController,
    required this.cityController,
    required this.pickupPinController,
    required this.dropPinController,
    required this.approximateWeightController,
    required this.onAddressChanged,
    required this.onPickupHouseNumberChanged,
    required this.onDropHouseNumberChanged,
    required this.onCityChanged,
    required this.onPickupPincodeChanged,
    required this.onDropPincodeChanged,
    required this.onNext,
  });

  final TextEditingController addressController;
  final TextEditingController pickupHouseNumberController;
  final TextEditingController dropHouseNumberController;
  final TextEditingController cityController;
  final TextEditingController pickupPinController;
  final TextEditingController dropPinController;
  final TextEditingController approximateWeightController;
  final ValueChanged<String> onAddressChanged;
  final ValueChanged<String> onPickupHouseNumberChanged;
  final ValueChanged<String> onDropHouseNumberChanged;
  final ValueChanged<String> onCityChanged;
  final ValueChanged<String> onPickupPincodeChanged;
  final ValueChanged<String> onDropPincodeChanged;
  final Future<void> Function() onNext;

  @override
  State<ShipmentDetails> createState() => _ShipmentDetailsState();
}

class _ShipmentDetailsState extends State<ShipmentDetails> {
  @override
  Widget build(BuildContext context) {
    const blue = AppColors.primaryMain;
    const yellow = AppColors.primaryButton;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4FA),
      appBar: AppBar(
        backgroundColor: blue,
        foregroundColor: Colors.white,
        title: const Text(
          'Full Address Details',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          const Text(
            'Enter Address Details',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _field(
            'Delivery Address',
            widget.addressController,
            'Full address',
            onChanged: widget.onAddressChanged,
          ),
          _twoFields(
            _field(
              'Pickup House No',
              widget.pickupHouseNumberController,
              'Pickup house no',
              onChanged: widget.onPickupHouseNumberChanged,
            ),
            _field(
              'Drop House No',
              widget.dropHouseNumberController,
              'Drop house no',
              onChanged: widget.onDropHouseNumberChanged,
            ),
          ),
          _twoFields(
            _field(
              'Approx. Weight (KG)',
              widget.approximateWeightController,
              'e.g. 2.5',
              keyboardType: TextInputType.number,
            ),
            _field(
              'City',
              widget.cityController,
              'City',
              onChanged: widget.onCityChanged,
            ),
          ),
          _twoFields(
            _field(
              'Pickup PIN',
              widget.pickupPinController,
              'Pickup PIN',
              digitsOnly: true,
              onChanged: widget.onPickupPincodeChanged,
            ),
            _field(
              'Drop PIN',
              widget.dropPinController,
              'Drop PIN',
              digitsOnly: true,
              onChanged: widget.onDropPincodeChanged,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 57,
            child: ElevatedButton(
              onPressed: widget.onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: yellow,
                foregroundColor: blue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Next →',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _twoFields(Widget first, Widget second) => Padding(
    padding: const EdgeInsets.only(top: 14),
    child: Row(
      children: [
        Expanded(child: first),
        const SizedBox(width: 10),
        Expanded(child: second),
      ],
    ),
  );

  Widget _field(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
    bool digitsOnly = false,
    ValueChanged<String>? onChanged,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF475467),
        ),
      ),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboardType,
        maxLength: digitsOnly ? 6 : null,
        inputFormatters: digitsOnly
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        decoration: InputDecoration(
          hintText: hint,
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ],
  );
}
