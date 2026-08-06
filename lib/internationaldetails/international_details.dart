import 'package:flutter/material.dart';
import 'package:yogayog/choosecourier/choose_courier.dart';

class PackageBox {
  final lengthController = TextEditingController();
  final breadthController = TextEditingController();
  final heightController = TextEditingController();

  double get volumetricWeight {
    final length = double.tryParse(lengthController.text) ?? 0;
    final breadth = double.tryParse(breadthController.text) ?? 0;
    final height = double.tryParse(heightController.text) ?? 0;

    return (length * breadth * height) / 5000;
  }

  void dispose() {
    lengthController.dispose();
    breadthController.dispose();
    heightController.dispose();
  }
}

class InternationalDetails extends StatefulWidget {
  const InternationalDetails({super.key});
  @override
  State<InternationalDetails> createState() => _InternationalDetailsState();
}

class _InternationalDetailsState extends State<InternationalDetails> {
  String selectedPackageType = 'Document';
  String selectedPackageSize = '0 - 500g';
  String selectedService = 'Express';

  final receiverNameController = TextEditingController();
  final mobileController = TextEditingController();
  final addressController = TextEditingController();
  final countryController = TextEditingController();

  final cityController = TextEditingController();
  final pinController = TextEditingController();
  final piecesController = TextEditingController(text: '1');
  final approximateWeightController = TextEditingController(text: '0.5');

  final List<PackageBox> packageBoxes = [];

  @override
  void dispose() {
    receiverNameController.dispose();
    mobileController.dispose();
    addressController.dispose();
    countryController.dispose();
    cityController.dispose();
    pinController.dispose();
    piecesController.dispose();
    approximateWeightController.dispose();

    for (final box in packageBoxes) {
      box.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F4FA),
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'Receiver Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('RECEIVER NAME'),
            _textField(
              controller: receiverNameController,
              hintText: 'Full name',
            ),

            _label('MOBILE'),
            _textField(
              controller: mobileController,
              hintText: '+91 XXXXX XXXXX',
              keyboardType: TextInputType.phone,
            ),

            _label('DELIVERY ADDRESS'),
            _textField(controller: addressController, hintText: 'Full address'),

            _label('Country'),
            _textField(
              controller: countryController,
              hintText: 'Enter Country',
            ),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('CITY'),
                      _textField(controller: cityController, hintText: 'City'),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('PIN'),
                      _textField(
                        controller: pinController,
                        hintText: 'PIN',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              'Select Your Package',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _packageTypeCard(
                    title: 'Document',
                    icon: Icons.mail_outline,
                    packageType: 'Document',
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: _packageTypeCard(
                    title: 'Non-document',
                    icon: Icons.inventory_2_outlined,
                    packageType: 'Non-document',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            const Text(
              'Select Package Size',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              children: [
                _packageSizeChip('0 - 500g'),
                _packageSizeChip('500g - 1kg'),
                _packageSizeChip('Greater than 1kg'),
              ],
            ),

            const SizedBox(height: 18),

            const Text(
              'Enter Package Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const SizedBox(
                  width: 190,
                  child: Text(
                    'Number of Total Pieces :',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: _textField(
                    controller: piecesController,
                    hintText: '1',
                    keyboardType: TextInputType.number,
                    onChanged: _onPiecesChanged,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 190,
                  child: Padding(
                    padding: EdgeInsets.only(top: 14),
                    child: Text(
                      'Approximate Weight (KG) :',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _textField(
                        controller: approximateWeightController,
                        hintText: 'e.g., 2.5',
                        keyboardType: TextInputType.number,
                      ),
                      if (selectedPackageSize != 'Greater than 1kg')
                        Padding(
                          padding: const EdgeInsets.only(left: 4, top: 4),
                          child: Text(
                            '💡 Weight set to '
                            '${approximateWeightController.text}kg '
                            'for this size',
                            style: const TextStyle(
                              color: Color(0xFF536078),
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            if (selectedPackageType == 'Non-document') ...[
              const SizedBox(height: 16),
              _packageBoxesWidget(),
            ],

            // const SizedBox(height: 28),

            // const Text(
            //   'Service Type',
            //   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            // ),

            // const SizedBox(height: 10),

            // _serviceCard(
            //   title: 'Express (2–3 days)',
            //   subtitle: 'Priority air movement',
            //   price: '₹349',
            //   icon: Icons.bolt,
            //   iconColor: Colors.amber,
            //   serviceKey: 'Express',
            // ),

            // const SizedBox(height: 10),

            // _serviceCard(
            //   title: 'Standard (5–7 days)',
            //   subtitle: 'Surface transport',
            //   price: '₹149',
            //   icon: Icons.local_shipping,
            //   iconColor: Colors.green,
            //   serviceKey: 'Standard',
            // ),
            const SizedBox(height: 28),

            InkWell(
              onTap: () {},
              child: SizedBox(
                width: double.infinity,
                height: 57,
                child: ElevatedButton(
                  onPressed: _reviewAndConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC400),
                    foregroundColor: const Color(0xFF101B8F),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 12, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF536078),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(color: Color(0xFF536078), fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF536078), fontSize: 16),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE1E1E6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF17249B), width: 1.5),
        ),
      ),
    );
  }

  Widget _packageTypeCard({
    required String title,
    required IconData icon,
    required String packageType,
  }) {
    final isSelected = selectedPackageType == packageType;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPackageType = packageType;

          if (packageType == 'Non-document') {
            _syncPackageBoxes(int.tryParse(piecesController.text) ?? 1);
          } else {
            for (final box in packageBoxes) {
              box.dispose();
            }
            packageBoxes.clear();
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 68,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF8FF) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xFF00A6A6) : Colors.transparent,
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
              color: isSelected ? const Color(0xFF008C8C) : Colors.brown,
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

  Widget _packageSizeChip(String size) {
    final isSelected = selectedPackageSize == size;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPackageSize = size;

          if (size == '0 - 500g') {
            approximateWeightController.text = '0.5';
          } else if (size == '500g - 1kg') {
            approximateWeightController.text = '1';
          } else {
            approximateWeightController.clear();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF2FFFF) : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF009B9B)
                : const Color(0xFFD0D0D0),
          ),
        ),
        child: Text(
          size,
          style: TextStyle(
            color: isSelected ? const Color(0xFF008C8C) : Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _packageBoxesWidget() {
    final totalWeight = packageBoxes.fold<double>(
      0,
      (total, box) => total + box.volumetricWeight,
    );

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE1E1E6)),
      ),
      child: Column(
        children: [
          ...List.generate(
            packageBoxes.length,
            (index) => _boxCard(box: packageBoxes[index], index: index),
          ),

          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE7F4FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Total Volumetric Weight: '
              '${totalWeight.toStringAsFixed(2)} kg',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _boxCard({required PackageBox box, required int index}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFD9D9D9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Box ${index + 1}',
                style: const TextStyle(
                  color: Color(0xFF536078),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              if (packageBoxes.length > 1)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      box.dispose();
                      packageBoxes.removeAt(index);
                      piecesController.text = packageBoxes.length.toString();
                    });
                  },
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
              Expanded(
                child: _dimensionField(
                  controller: box.lengthController,
                  hintText: 'Length (cm)',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dimensionField(
                  controller: box.breadthController,
                  hintText: 'Breadth (cm)',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dimensionField(
                  controller: box.heightController,
                  hintText: 'Height (cm)',
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            'Volumetric Weight: '
            '${box.volumetricWeight.toStringAsFixed(2)} kg',
            style: const TextStyle(
              color: Color(0xFF536078),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dimensionField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: (_) {
        setState(() {});
      },
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF536078), fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Color(0xFFD6D6D6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Color(0xFF00A6A6)),
        ),
      ),
    );
  }

  Widget _serviceCard({
    required String title,
    required String subtitle,
    required String price,
    required IconData icon,
    required Color iconColor,
    required String serviceKey,
  }) {
    final isSelected = selectedService == serviceKey;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedService = serviceKey;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xFF17249B) : Colors.transparent,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF0FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 25),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF9A9AAA),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              price,
              style: const TextStyle(
                color: Color(0xFF17249B),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(width: 12),

            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected
                  ? const Color(0xFF17249B)
                  : const Color(0xFFE0E1E8),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  void _onPiecesChanged(String value) {
    if (selectedPackageType != 'Non-document') return;

    final count = int.tryParse(value) ?? 0;

    setState(() {
      _syncPackageBoxes(count);
    });
  }

  void _syncPackageBoxes(int count) {
    final safeCount = count < 0 ? 0 : count;

    while (packageBoxes.length < safeCount) {
      packageBoxes.add(PackageBox());
    }

    while (packageBoxes.length > safeCount) {
      packageBoxes.last.dispose();
      packageBoxes.removeLast();
    }
  }

  void _reviewAndConfirm() {
    FocusScope.of(context).unfocus();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Shipment'),
          content: Text(
            'Package: $selectedPackageType\n'
            'Size: $selectedPackageSize\n'
            'Pieces: ${piecesController.text}\n'
            'Service: $selectedService',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final approximateWeight =
                    double.tryParse(approximateWeightController.text) ?? 0;

                final volumetricWeight = packageBoxes.fold<double>(
                  0,
                  (total, box) => total + box.volumetricWeight,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChooseCourier(
                      approximateWeightKg: approximateWeight,
                      volumetricWeightKg: volumetricWeight,
                    ),
                  ),
                );
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
