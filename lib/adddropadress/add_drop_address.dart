import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yogayog/adddropadress/provider/add_drop_address_provider.dart';
import 'package:yogayog/constants/app_colors.dart';

class AddDropAddress extends StatefulWidget {
  const AddDropAddress({super.key, this.serviceId = 1});
  final int serviceId;

  @override
  State<AddDropAddress> createState() => _AddDropAddressState();
}

class _AddDropAddressState extends State<AddDropAddress> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _house = TextEditingController();
  final _street = TextEditingController();
  final _city = TextEditingController();
  final _district = TextEditingController();
  final _state = TextEditingController();
  final _pin = TextEditingController();
  final _country = TextEditingController(text: 'India');
  final _countryCode = TextEditingController(text: 'IN');
  final _lat = TextEditingController();
  final _lon = TextEditingController();

  @override
  void dispose() {
    for (final controller in [
      _name, _mobile, _house, _street, _city, _district, _state, _pin,
      _country, _countryCode, _lat, _lon,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddDropAddressProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4FA),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _field('FULL NAME', 'John Doe', _name),
                      _field('MOBILE NUMBER', '9876543210', _mobile, type: TextInputType.phone),
                      _field('HOUSE NUMBER', '12A', _house),
                      _field('STREET', 'Main Road', _street),
                      Row(children: [
                        Expanded(child: _field('CITY', 'Delhi', _city)),
                        const SizedBox(width: 12),
                        Expanded(child: _field('PIN CODE', '110001', _pin, type: TextInputType.number)),
                      ]),
                      _field('DISTRICT', 'Central Delhi', _district),
                      _field('STATE', 'Delhi', _state),
                      Row(children: [
                        Expanded(child: _field('LATITUDE', '28.6139', _lat, type: const TextInputType.numberWithOptions(decimal: true))),
                        const SizedBox(width: 12),
                        Expanded(child: _field('LONGITUDE', '77.209', _lon, type: const TextInputType.numberWithOptions(decimal: true))),
                      ]),
                      _field('COUNTRY', 'India', _country),
                      _field('COUNTRY CODE', 'IN', _countryCode),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 57,
                        child: ElevatedButton(
                          onPressed: provider.isLoading ? null : _saveAddress,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryButton,
                            foregroundColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: provider.isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Save Address', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                        ),
                      ),
                      if (provider.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() => Container(
        width: double.infinity,
        color: AppColors.primaryMain,
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(backgroundColor: const Color(0xFF4D59A7)),
          ),
          const SizedBox(height: 7),
          const Text('Add Pickup Address', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          const Text('Save for faster bookings', style: TextStyle(color: Color(0xFFD2D5FF), fontSize: 13)),
        ]),
      );

  Widget _field(String label, String hint, TextEditingController controller, {TextInputType? type}) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextFormField(
          controller: controller,
          keyboardType: type,
          validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;
    final payload = {
      'name': _name.text.trim(),
      'mobile': _mobile.text.trim(),
      'service_id': widget.serviceId,
      'house_numb': _house.text.trim(),
      'street': _street.text.trim(),
      'city': _city.text.trim(),
      'district': _district.text.trim(),
      'state': _state.text.trim(),
      'pin': _pin.text.trim(),
      'country': _country.text.trim(),
      'country_cde': _countryCode.text.trim(),
      'lat': double.tryParse(_lat.text.trim()),
      'lon': double.tryParse(_lon.text.trim()),
    };
    final success = await context.read<AddDropAddressProvider>().addPickupAddress(payload: payload);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pickup address saved successfully')));
      Navigator.pop(context, true);
    }
  }
}
