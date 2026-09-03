import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
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
  static const _placesKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'AIzaSyC6atqg-XZ8SVzSlLrt5W5mhCgkG-8h6Lo',
  );
  String? _pickupPinError;
  String? _dropPinError;
  String? _addressError;
  String? _pickupHouseError;
  String? _dropHouseError;
  String? _weightError;
  String? _cityError;
  int _pickupRequest = 0;
  int _dropRequest = 0;

  Future<bool> _validatePincode(String value, {required bool pickup}) async {
    final pin = value.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      if (mounted) {
        setState(() {
          if (pickup) {
            _pickupPinError = 'Enter a valid 6-digit PIN';
          } else {
            _dropPinError = 'Enter a valid 6-digit PIN';
          }
        });
      }
      return false;
    }
    final request = pickup ? ++_pickupRequest : ++_dropRequest;
    try {
      if (_placesKey.isEmpty)
        throw Exception('Google Maps API key is not configured');
      final response = await Dio().get(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {
          'address': '$pin, India',
          'components': 'postal_code:$pin|country:IN',
          'key': _placesKey,
        },
      );
      final data = response.data;
      final results = data is Map ? data['results'] : null;
      if (data is! Map ||
          data['status'] != 'OK' ||
          results is! List ||
          results.isEmpty) {
        throw Exception('This PIN must be a valid India PIN');
      }
      final result = results.first;
      String country = '';
      String formattedAddress = '';
      String city = '';
      if (result is Map) {
        formattedAddress = result['formatted_address']?.toString() ?? '';
        final components = result['address_components'];
        if (components is List) {
          for (final item in components.whereType<Map>()) {
            final types = item['types'];
            final value = item['long_name']?.toString() ?? '';
            if (types is List && types.contains('country')) {
              country = (item['short_name']?.toString() ?? value).toUpperCase();
            }
            if (types is List &&
                (types.contains('locality') ||
                    types.contains('administrative_area_level_2')) &&
                city.isEmpty) {
              city = value;
            }
          }
        }
      }
      final addressLower = formattedAddress.toLowerCase();
      final isExplicitlyOutsideIndia =
          country.isNotEmpty &&
          country != 'IN' &&
          country != 'INDIA' &&
          !addressLower.contains('india');
      if (isExplicitlyOutsideIndia) {
        throw Exception('PIN must be within India');
      }
      if (!mounted ||
          (pickup ? request != _pickupRequest : request != _dropRequest)) {
        return false;
      }
      setState(() {
        if (pickup) {
          _pickupPinError = null;
        } else {
          _dropPinError = null;
          if (formattedAddress.isNotEmpty) {
            widget.addressController.text = formattedAddress;
            widget.onAddressChanged(formattedAddress);
          }
          if (city.isNotEmpty) {
            widget.cityController.text = city;
            widget.onCityChanged(city);
          }
          widget.onDropPincodeChanged(pin);
        }
      });
      return true;
    } catch (error) {
      if (!mounted ||
          (pickup ? request != _pickupRequest : request != _dropRequest)) {
        return false;
      }
      setState(() {
        if (pickup) {
          _pickupPinError = error.toString().replaceFirst('Exception: ', '');
        } else {
          _dropPinError = error.toString().replaceFirst('Exception: ', '');
        }
      });
      return false;
    }
  }

  Future<void> _handleNext() async {
    final address = widget.addressController.text.trim();
    final pickupHouse = widget.pickupHouseNumberController.text.trim();
    final dropHouse = widget.dropHouseNumberController.text.trim();
    final weight = double.tryParse(
      widget.approximateWeightController.text.trim(),
    );
    final city = widget.cityController.text.trim();
    setState(() {
      _addressError = address.isEmpty ? 'Enter delivery address' : null;
      _pickupHouseError = pickupHouse.isEmpty
          ? 'Enter pickup house number'
          : null;
      _dropHouseError = dropHouse.isEmpty ? 'Enter drop house number' : null;
      _weightError = weight == null || weight <= 0
          ? 'Enter a valid weight'
          : null;
      _cityError = city.isEmpty ? 'Enter city' : null;
    });
    final pickupValid = await _validatePincode(
      widget.pickupPinController.text,
      pickup: true,
    );
    final dropValid = await _validatePincode(
      widget.dropPinController.text,
      pickup: false,
    );
    final basicFieldsValid =
        _addressError == null &&
        _pickupHouseError == null &&
        _dropHouseError == null &&
        _weightError == null &&
        _cityError == null;
    if (basicFieldsValid && pickupValid && dropValid && mounted) {
      await widget.onNext();
    }
  }

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
            errorText: _addressError,
            onChanged: (value) {
              if (_addressError != null && value.trim().isNotEmpty) {
                setState(() => _addressError = null);
              }
              widget.onAddressChanged(value);
            },
          ),
          _twoFields(
            _field(
              'Pickup House No',
              widget.pickupHouseNumberController,
              'Pickup house no',
              errorText: _pickupHouseError,
              onChanged: widget.onPickupHouseNumberChanged,
            ),
            _field(
              'Drop House No',
              widget.dropHouseNumberController,
              'Drop house no',
              errorText: _dropHouseError,
              onChanged: widget.onDropHouseNumberChanged,
            ),
          ),
          _twoFields(
            _field(
              'Approx. Weight (KG)',
              widget.approximateWeightController,
              'e.g. 2.5',
              keyboardType: TextInputType.number,
              errorText: _weightError,
            ),
            _field(
              'City',
              widget.cityController,
              'City',
              onChanged: widget.onCityChanged,
              errorText: _cityError,
            ),
          ),
          _twoFields(
            _field(
              'Pickup PIN',
              widget.pickupPinController,
              'Pickup PIN',
              digitsOnly: true,
              readOnly: true,
              errorText: _pickupPinError,
              onChanged: (value) {
                widget.onPickupPincodeChanged(value);
                if (value.length == 6) _validatePincode(value, pickup: true);
              },
            ),
            _field(
              'Drop PIN',
              widget.dropPinController,
              'Drop PIN',
              digitsOnly: true,
              errorText: _dropPinError,
              onChanged: (value) {
                widget.onDropPincodeChanged(value);
                if (value.length == 6) _validatePincode(value, pickup: false);
              },
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 57,
            child: ElevatedButton(
              onPressed: _handleNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: yellow,
                foregroundColor: blue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Save →',
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
    bool readOnly = false,
    ValueChanged<String>? onChanged,
    String? errorText,
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
        readOnly: readOnly,
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
          errorText: errorText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ],
  );
}
