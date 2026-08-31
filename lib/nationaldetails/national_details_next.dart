import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yogayog/constants/app_colors.dart';

class NationalDetailsNext extends StatefulWidget {
  const NationalDetailsNext({
    super.key,
    required this.selectedPackageType,
    required this.selectedPackageSize,
    required this.onPackageTypeChanged,
    required this.onPackageSizeChanged,
    required this.piecesController,
    required this.weightController,
    required this.onPiecesChanged,
    required this.packageBoxesBuilder,
    required this.packageBoxesVersion,
    required this.onReviewAndConfirm,
  });

  final String selectedPackageType;
  final String selectedPackageSize;
  final ValueChanged<String> onPackageTypeChanged;
  final ValueChanged<String> onPackageSizeChanged;
  final TextEditingController piecesController;
  final TextEditingController weightController;
  final ValueChanged<String> onPiecesChanged;
  final Widget Function() packageBoxesBuilder;
  final ValueListenable<int> packageBoxesVersion;
  final VoidCallback onReviewAndConfirm;

  @override
  State<NationalDetailsNext> createState() => _NationalDetailsNextState();
}

class _NationalDetailsNextState extends State<NationalDetailsNext> {
  static const _blue = AppColors.primaryMain;
  static const _yellow = AppColors.primaryButton;
  late String _selectedType;
  late String _selectedSize;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedPackageType;
    _selectedSize = widget.selectedPackageSize;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4FA),
      appBar: AppBar(
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Select Package',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          const Text(
            'Select Your Package',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _packageType('Document', Icons.mail_outline)),
              const SizedBox(width: 14),
              Expanded(
                child: _packageType('Non-document', Icons.inventory_2_outlined),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Select Package Size',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _sizeChip('0 - 500g'),
              _sizeChip('500g - 1kg'),
              _sizeChip('Greater than 1kg'),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Enter Package Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _inputRow(
            'Number of Total Pieces :',
            widget.piecesController,
            '1',
            onChanged: (value) {
              widget.onPiecesChanged(value);
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          _inputRow(
            'Approximate Weight (KG) :',
            widget.weightController,
            'e.g., 2.5',
          ),
          if (_selectedType == 'Non-document') ...[
            const SizedBox(height: 16),
            ValueListenableBuilder<int>(
              valueListenable: widget.packageBoxesVersion,
              builder: (_, __, ___) => widget.packageBoxesBuilder(),
            ),
          ],
          const SizedBox(height: 30),
          SizedBox(
            height: 57,
            child: ElevatedButton(
              onPressed: widget.onReviewAndConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: _yellow,
                foregroundColor: _blue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Review & Confirm →',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _packageType(String title, IconData icon) {
    final selected = _selectedType == title;
    return InkWell(
      onTap: () {
        setState(() => _selectedType = title);
        widget.onPackageTypeChanged(title);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 74,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE9ECFF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _blue : const Color(0xFFE0E2E8),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? _blue : const Color(0xFF667085)),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                color: selected ? _blue : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sizeChip(String size) {
    final selected = _selectedSize == size;
    return InkWell(
      onTap: () {
        setState(() => _selectedSize = size);
        widget.onPackageSizeChanged(size);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE9ECFF) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? _blue : const Color(0xFFE0E2E8)),
        ),
        child: Text(
          size,
          style: TextStyle(
            color: selected ? _blue : Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _inputRow(
    String label,
    TextEditingController controller,
    String hint, {
    ValueChanged<String>? onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 170,
          child: Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
