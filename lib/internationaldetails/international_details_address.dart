import 'package:flutter/material.dart';

class InternationalDetailsAddress extends StatefulWidget {
  const InternationalDetailsAddress({
    super.key,
    this.address = '',
    this.pickupHouse = '',
    this.dropHouse = '',
    this.weight = '0.5',
    this.country = '',
    this.city = '',
    this.pickupPin = '',
    this.dropPin = '',
  });

  final String address,
      pickupHouse,
      dropHouse,
      weight,
      country,
      city,
      pickupPin,
      dropPin;

  @override
  State<InternationalDetailsAddress> createState() =>
      _InternationalDetailsAddressState();
}

class _InternationalDetailsAddressState
    extends State<InternationalDetailsAddress> {
  late final address = TextEditingController(text: widget.address);
  late final pickupHouse = TextEditingController(text: widget.pickupHouse);
  late final dropHouse = TextEditingController(text: widget.dropHouse);
  late final weight = TextEditingController(text: widget.weight);
  late final country = TextEditingController(text: widget.country);
  late final city = TextEditingController(text: widget.city);
  late final pickupPin = TextEditingController(text: widget.pickupPin);
  late final dropPin = TextEditingController(text: widget.dropPin);

  @override
  void dispose() {
    for (final controller in [
      address,
      pickupHouse,
      dropHouse,
      weight,
      country,
      city,
      pickupPin,
      dropPin,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (pickupHouse.text.trim().isEmpty) {
      _showValidationMessage('Please enter pickup housing no.');
      return;
    }
    if (dropHouse.text.trim().isEmpty) {
      _showValidationMessage('Please enter drop housing no.');
      return;
    }
    Navigator.pop(context, <String, String>{
      'address': address.text.trim(),
      'pickupHouse': pickupHouse.text.trim(),
      'dropHouse': dropHouse.text.trim(),
      'weight': weight.text.trim(),
      'country': country.text.trim(),
      'city': city.text.trim(),
      'pickupPin': pickupPin.text.trim(),
      'dropPin': dropPin.text.trim(),
    });
  }

  void _showValidationMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F2FA),
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'Full Address Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('ADDRESS DETAILS'),
            _field(address, 'Full address'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _field(pickupHouse, 'Pickup housing no.')),
                const SizedBox(width: 10),
                Expanded(child: _field(dropHouse, 'Drop housing no.')),
              ],
            ),
            _label('APPROX. WEIGHT (KG)'),
            _field(weight, 'e.g. 2.5', keyboardType: TextInputType.number),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('DROP COUNTRY'),
                      _field(country, 'Country'),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_label('DROP CITY'), _field(city, 'City')],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('PICKUP PIN'),
                      _field(
                        pickupPin,
                        'Pickup PIN',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('DROP PIN'),
                      _field(
                        dropPin,
                        'Drop PIN',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          height: 57,
          child: ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC400),
              foregroundColor: const Color(0xFF101B8F),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Next',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(left: 20, top: 12, bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFF536078),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: .8,
      ),
    ),
  );

  Widget _field(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
  }) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFE1E1E6)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFE1E1E6)),
      ),
    ),
  );
}
