import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/pincodecheck/checkpin_service.dart';

class CheCkPin extends StatefulWidget {
  const CheCkPin({super.key});

  @override
  State<CheCkPin> createState() => _CheCkPinState();
}

class _CheCkPinState extends State<CheCkPin> {
  static const black = AppColors.primaryMain;
  static const _yellow = Color(0xFFFFC400);
  static const _pageBackground = Color(0xFFF4F4F8);

  final _pinController = TextEditingController(text: '110002');
  final _pinFocusNode = FocusNode();
  String _selectedService = 'All';
  final List<_RecentCheck> _recentChecks = const [
    _RecentCheck('110001', 'New Delhi', 'National · Serviceable', true),
    _RecentCheck('400001', 'Mumbai', 'National · Serviceable', true),
    _RecentCheck('795001', 'Imphal', 'ODA – Surcharge applicable', false),
  ];

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  void _checkPin() {
    final pin = _pinController.text.trim();
    if (pin.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 6-digit PIN code')),
      );
      _pinFocusNode.requestFocus();
      return;
    }

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => CheCkPinService(pinCode: pin)));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _pageBackground,
        body: Column(
          children: [
            const _Header(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Form(
                      controller: _pinController,
                      focusNode: _pinFocusNode,
                      onCheck: _checkPin,
                      selectedService: _selectedService,
                      onServiceSelected: (service) {
                        setState(() => _selectedService = service);
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(12, 19, 12, 10),
                      child: Text(
                        'Recent Checks',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    ..._recentChecks.map(
                      (check) => _RecentCheckRow(check: check),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Container(color: _CheCkPinState.black),
          Positioned(
            right: -17,
            top: -62,
            child: Container(
              width: 134,
              height: 134,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.hintGray, width: 15),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'PIN Code Check',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'Check if a destination is serviceable',
                    style: TextStyle(color: Color(0xFFB8DDC8), fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Form extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onCheck;
  final String selectedService;
  final ValueChanged<String> onServiceSelected;

  const _Form({
    required this.controller,
    required this.focusNode,
    required this.onCheck,
    required this.selectedService,
    required this.onServiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DESTINATION PIN CODE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF52606D),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: _CheCkPinState.black,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: _CheCkPinState.black,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: _CheCkPinState.black,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 54,
                width: 80,
                child: ElevatedButton(
                  onPressed: onCheck,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _CheCkPinState._yellow,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Check',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'SERVICE TYPE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF52606D),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: ['All', 'Local', 'National', "Int'l"]
                .map(
                  (type) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: type,
                      selected: type == selectedService,
                      onTap: () => onServiceSelected(type),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE7F6EC) : const Color(0xFFF1F1F6),
          border: selected
              ? Border.all(color: _CheCkPinState.black, width: 2)
              : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? _CheCkPinState.black : const Color(0xFF52606D),
          ),
        ),
      ),
    );
  }
}

class _RecentCheckRow extends StatelessWidget {
  final _RecentCheck check;
  const _RecentCheckRow({required this.check});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 61,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE8E8ED))),
      ),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: check.serviceable
                  ? const Color(0xFFE6F7E9)
                  : const Color(0xFFFFEEEE),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              check.serviceable ? Icons.check_box : Icons.close,
              color: check.serviceable ? Colors.green : Colors.red,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${check.pin} – ${check.city}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                check.status,
                style: TextStyle(
                  fontSize: 11,
                  color: check.serviceable
                      ? const Color(0xFF7B8493)
                      : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentCheck {
  final String pin;
  final String city;
  final String status;
  final bool serviceable;
  const _RecentCheck(this.pin, this.city, this.status, this.serviceable);
}
