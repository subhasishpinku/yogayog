import 'package:flutter/material.dart';
import 'package:yogayog/constants/app_colors.dart';

class AddDropAddress extends StatefulWidget {
  const AddDropAddress({super.key});

  @override
  State<AddDropAddress> createState() => _AddDropAddressState();
}

class _AddDropAddressState extends State<AddDropAddress> {
  final _formKey = GlobalKey<FormState>();
  String saveAs = 'Home';

  @override
  Widget build(BuildContext context) {
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
                      _field('FULL NAME', "Receiver's full name"),
                      _field(
                        'MOBILE NUMBER',
                        '+91 XXXXX XXXXX',
                        type: TextInputType.phone,
                      ),
                      _field('ADDRESS LINE 1', 'House / Flat / Building no.'),
                      _field('ADDRESS LINE 2', 'Street, Area, Landmark'),
                      Row(
                        children: [
                          Expanded(child: _field('CITY', 'City')),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _field(
                              'PIN CODE',
                              '000000',
                              type: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      _field('STATE', 'State'),
                      const Text(
                        'SAVE AS',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: .6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _saveOption('🏠', 'Home'),
                          const SizedBox(width: 10),
                          _saveOption('🏢', 'Office'),
                          const SizedBox(width: 10),
                          _saveOption('📍', 'Other'),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 57,
                        child: ElevatedButton(
                          onPressed: _saveAddress,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryButton,
                            foregroundColor: AppColors.primaryBlue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Save Address',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
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
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          style: IconButton.styleFrom(backgroundColor: const Color(0xFF4D59A7)),
        ),
        const SizedBox(height: 7),
        const Text(
          'Add Drop Address',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'Save for faster bookings',
          style: TextStyle(color: Color(0xFFD2D5FF), fontSize: 13),
        ),
      ],
    ),
  );

  Widget _field(String label, String hint, {TextInputType? type}) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: .6,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          keyboardType: type,
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Required' : null,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFD9DCE5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFD9DCE5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.primaryBlue,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _saveOption(String icon, String label) {
    final selected = saveAs == label;
    return Expanded(
      child: OutlinedButton(
        onPressed: () => setState(() => saveAs = label),
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? const Color(0xFFF0F1FF) : Colors.white,
          foregroundColor: AppColors.primaryBlue,
          side: BorderSide(
            color: selected ? AppColors.primaryBlue : const Color(0xFFD9DCE5),
            width: selected ? 2 : 1,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          '$icon $label',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }

  void _saveAddress() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Address saved successfully')));
    Navigator.pop(context);
  }
}
