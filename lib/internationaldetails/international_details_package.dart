import 'package:flutter/material.dart';

class InternationalDetailsPackage extends StatefulWidget {
  const InternationalDetailsPackage({
    super.key,
    this.type = 'Document',
    this.size = '0 - 500g',
    this.pieces = '1',
    this.weight = '0.5',
    this.boxes = const [],
    this.onReviewAndConfirm,
  });
  final String type, size, pieces, weight;
  final List<Map<String, dynamic>> boxes;
  final Future<void> Function(Map<String, dynamic>, BuildContext)?
      onReviewAndConfirm;
  @override
  State<InternationalDetailsPackage> createState() =>
      _InternationalDetailsPackageState();
}

class _Box {
  final length = TextEditingController();
  final breadth = TextEditingController();
  final height = TextEditingController();
  double get volume =>
      (double.tryParse(length.text) ?? 0) *
      (double.tryParse(breadth.text) ?? 0) *
      (double.tryParse(height.text) ?? 0) /
      5000;
  void dispose() {
    length.dispose();
    breadth.dispose();
    height.dispose();
  }
}

class _InternationalDetailsPackageState
    extends State<InternationalDetailsPackage> {
  late String type = widget.type, size = widget.size;
  late final pieces = TextEditingController(text: widget.pieces);
  late final weight = TextEditingController(text: widget.weight);
  final boxes = <_Box>[];

  @override
  void initState() {
    super.initState();
    for (final item in widget.boxes) {
      final box = _Box();
      box.length.text = item['length']?.toString() ?? '';
      box.breadth.text = item['breadth']?.toString() ?? '';
      box.height.text = item['height']?.toString() ?? '';
      boxes.add(box);
    }
    if (type == 'Non-document') _sync(int.tryParse(pieces.text) ?? 1);
  }

  @override
  void dispose() {
    pieces.dispose();
    weight.dispose();
    for (final box in boxes) {
      box.dispose();
    }
    super.dispose();
  }

  void _sync(int count) {
    while (boxes.length < count) {
      boxes.add(_Box());
    }
    while (boxes.length > count) {
      boxes.removeLast().dispose();
    }
  }

  void _save() {
    final result = <String, dynamic>{
      'packageType': type,
      'packageSize': size,
      'pieces': pieces.text.trim().isEmpty ? '1' : pieces.text.trim(),
      'weight': weight.text.trim(),
      'boxes': boxes
          .map(
            (box) => {
              'length': box.length.text,
              'breadth': box.breadth.text,
              'height': box.height.text,
            },
          )
          .toList(),
    };
    if (widget.onReviewAndConfirm != null) {
      widget.onReviewAndConfirm!(result, context);
      return;
    }
    Navigator.pop(context, result);
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
          'Select Your Package',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Your Package',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _typeCard('Document', Icons.mail_outline)),
                const SizedBox(width: 18),
                Expanded(
                  child: _typeCard('Non-document', Icons.inventory_2_outlined),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Text(
              'Select Package Size',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _sizeChip('0 - 500g'),
                _sizeChip('500g - 1kg'),
                _sizeChip('Greater than 1kg'),
              ],
            ),
            const SizedBox(height: 22),
            const Text(
              'Enter Package Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _field(
              'Number of Total Pieces :',
              pieces,
              '1',
              onChanged: (value) {
                if (type == 'Non-document')
                  setState(() => _sync(int.tryParse(value) ?? 0));
              },
            ),
            const SizedBox(height: 8),
            _field(
              'Approximate Weight (KG) :',
              weight,
              'e.g., 2.5',
              onChanged: (_) => setState(() {}),
            ),
            if (size != 'Greater than 1kg')
              Padding(
                padding: const EdgeInsets.only(left: 194, top: 4),
                child: Text(
                  '💡 Weight set to ${weight.text}kg for this size',
                  style: const TextStyle(
                    color: Color(0xFF536078),
                    fontSize: 12,
                  ),
                ),
              ),
            if (type == 'Non-document') ...[
              const SizedBox(height: 16),
              _boxesCard(),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 8, 14, 12),
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
              'Review & Confirm',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _typeCard(String title, IconData icon) {
    final selected = type == title;
    return GestureDetector(
      onTap: () => setState(() {
        type = title;
        if (type == 'Non-document')
          _sync(int.tryParse(pieces.text) ?? 1);
        else {
          for (final box in boxes) {
            box.dispose();
          }
          boxes.clear();
        }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 70,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF8FF) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? const Color(0xFF00A6A6) : Colors.transparent,
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? const Color(0xFF008C8C) : Colors.brown,
              size: 25,
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sizeChip(String value) {
    final selected = size == value;
    return GestureDetector(
      onTap: () => setState(() {
        size = value;
        weight.text = value == '0 - 500g'
            ? '0.5'
            : value == '500g - 1kg'
            ? '1'
            : '';
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF2FFFF) : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: selected ? const Color(0xFF009B9B) : const Color(0xFFD0D0D0),
          ),
        ),
        child: Text(
          value,
          style: TextStyle(
            color: selected ? const Color(0xFF008C8C) : Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    String hint, {
    ValueChanged<String>? onChanged,
  }) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 190,
        child: Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      Expanded(
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    ],
  );

  Widget _boxesCard() {
    final total = boxes.fold<double>(0, (sum, box) => sum + box.volume);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE1E1E6)),
      ),
      child: Column(
        children: [
          ...List.generate(boxes.length, _boxCard),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE7F4FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Total Volumetric Weight: ${total.toStringAsFixed(2)} kg',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _boxCard(int index) {
    final box = boxes[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFD9D9D9)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Box ${index + 1}',
                style: const TextStyle(
                  color: Color(0xFF536078),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (boxes.length > 1)
                GestureDetector(
                  onTap: () => setState(() {
                    boxes.removeAt(index).dispose();
                    pieces.text = boxes.length.toString();
                  }),
                  child: const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.redAccent,
                    child: Icon(Icons.close, color: Colors.white, size: 15),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _dimension(box.length, 'Length (cm)')),
              const SizedBox(width: 8),
              Expanded(child: _dimension(box.breadth, 'Breadth (cm)')),
              const SizedBox(width: 8),
              Expanded(child: _dimension(box.height, 'Height (cm)')),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Volumetric Weight: ${box.volume.toStringAsFixed(2)} kg',
              style: const TextStyle(
                color: Color(0xFF536078),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dimension(TextEditingController controller, String hint) => TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    onChanged: (_) => setState(() {}),
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 9, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
      ),
    ),
  );
}
