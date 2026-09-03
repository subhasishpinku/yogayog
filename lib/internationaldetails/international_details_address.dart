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
  String? _addressError;
  String? _pickupHouseError;
  String? _dropHouseError;
  String? _weightError;
  String? _countryError;
  String? _cityError;
  String? _pickupPinError;
  String? _dropPinError;

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
    final parsedWeight = double.tryParse(weight.text.trim());
    setState(() {
      _addressError = address.text.trim().isEmpty
          ? 'Please enter full address'
          : null;
      _pickupHouseError = pickupHouse.text.trim().isEmpty
          ? 'Please enter pickup house number'
          : null;
      _dropHouseError = dropHouse.text.trim().isEmpty
          ? 'Please enter drop house number'
          : null;
      _weightError = parsedWeight == null || parsedWeight <= 0
          ? 'Please enter a valid weight'
          : null;
      _countryError = country.text.trim().isEmpty
          ? 'Please enter country'
          : null;
      _cityError = city.text.trim().isEmpty ? 'Please enter city' : null;
      _pickupPinError = RegExp(r'^\d{4,10}$').hasMatch(pickupPin.text.trim())
          ? null
          : 'Please enter a valid pickup PIN';
      _dropPinError = RegExp(r'^\d{4,10}$').hasMatch(dropPin.text.trim())
          ? null
          : 'Please enter a valid drop PIN';
    });
    if (_addressError != null ||
        _pickupHouseError != null ||
        _dropHouseError != null ||
        _weightError != null ||
        _countryError != null ||
        _cityError != null ||
        _pickupPinError != null ||
        _dropPinError != null) {
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
            _field(address, 'Full address', errorText: _addressError),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _field(
                    pickupHouse,
                    'Pickup housing no.',
                    errorText: _pickupHouseError,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _field(
                    dropHouse,
                    'Drop housing no.',
                    errorText: _dropHouseError,
                  ),
                ),
              ],
            ),
            _label('APPROX. WEIGHT (KG)'),
            _field(
              weight,
              'e.g. 2.5',
              keyboardType: TextInputType.number,
              errorText: _weightError,
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('DROP COUNTRY'),
                      _field(country, 'Country', errorText: _countryError),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('DROP CITY'),
                      _field(city, 'City', errorText: _cityError),
                    ],
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
                        errorText: _pickupPinError,
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
                        errorText: _dropPinError,
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
              'Save',
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
    String? errorText,
  }) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      hintText: hint,
      errorText: errorText,
      filled: true,
      fillColor: errorText == null ? Colors.white : const Color(0xFFFFEBEE),
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
