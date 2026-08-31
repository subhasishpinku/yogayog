import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/core/services/home_service.dart';

class PaperworkRequired extends StatefulWidget {
  const PaperworkRequired({super.key});

  @override
  State<PaperworkRequired> createState() => _PaperworkRequiredState();
}

class _PaperworkRequiredState extends State<PaperworkRequired> {
  static const _green = AppColors.primaryMain;
  String _accountType = 'Individual';

  bool get _isBusiness => _accountType.trim().toLowerCase() == 'business';

  @override
  void initState() {
    super.initState();
    _loadAccountType();
  }

  Future<void> _loadAccountType() async {
    final preferences = await SharedPreferences.getInstance();
    final accountType = preferences.getString(
      HomeService.profileAccountTypeKey,
    );
    if (!mounted || accountType == null || accountType.trim().isEmpty) return;
    setState(() => _accountType = accountType);
  }

  List<_Document> get _accountDocuments => _isBusiness
      ? const [
          _Document('📄', 'PAN', 'Business PAN card', true),
          _Document('🧾', 'GST', 'GST registration certificate', true),
          _Document('🌐', 'IEC Code', 'Import Export Code', true),
          _Document('🏢', 'MSME Certificate', 'Udyam/MSME registration', false),
          _Document(
            '🧾',
            'Commercial Invoice',
            'Signed invoice for the shipment',
            true,
          ),
          _Document('📦', 'Packing List', 'Item-wise package details', true),
          _Document(
            '🏢',
            'Company Proof',
            'Certificate of incorporation or company ID',
            true,
          ),
          _Document(
            '🪪',
            'Personal ID Proof / Personal PAN Card',
            'Authorized person identity proof',
            false,
          ),
        ]
      : const [
          _Document('📄', 'PAN', 'Personal PAN card', true),
          _Document(
            '🧾',
            'GST',
            'GST registration certificate, if available',
            false,
          ),
          _Document(
            '🌐',
            'IEC Code',
            'Import Export Code, if applicable',
            false,
          ),
          _Document(
            '🏢',
            'MSME Certificate',
            'Udyam/MSME registration, if available',
            false,
          ),
          _Document('🪪', 'Aadhaar', 'Personal identity proof', true),
        ];

  static const _shipmentDocuments = [
    _Document('🔖', 'AWB', 'Airway Bill / shipment document', true),
    _Document('📦', 'Packing List', 'Item-wise package details', true),
    _Document('🚢', 'Shipping Bill', 'Required for export shipment', false),
    _Document(
      '🧾',
      'Commercial Invoice',
      'Required for customs clearance',
      true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _green,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            const _PaperHeader(),
            Container(
              margin: const EdgeInsets.fromLTRB(9, 10, 9, 9),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE9ECFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_circle_outlined,
                    color: _green,
                    size: 22,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Account type: $_accountType',
                      style: const TextStyle(
                        color: _green,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _SectionHeading(
                    title: _isBusiness
                        ? 'Business Documents'
                        : 'Individual Documents',
                    subtitle: _isBusiness
                        ? 'Documents required for business shipments'
                        : 'Documents required for individual shipments',
                  ),
                  ..._accountDocuments.map(
                    (document) => _DocumentRow(document: document),
                  ),
                  const _SectionHeading(
                    title: 'Shipment Documents',
                    subtitle: 'Upload documents related to this shipment',
                  ),
                  ..._shipmentDocuments.map(
                    (document) => _DocumentRow(document: document),
                  ),
                  if (!_isBusiness)
                    const _DocumentRow(
                      document: _Document(
                        '📍',
                        'Need Shipment Track Upload',
                        'Upload shipment tracking details',
                        false,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaperHeader extends StatelessWidget {
  const _PaperHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 136,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Container(color: _PaperworkRequiredState._green),
          Positioned(
            right: -18,
            top: -58,
            child: Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.hintGray, width: 15),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 7, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                      const SizedBox(width: 12),
                      const Text(
                        'Paperwork Required',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Documents needed per shipment type',
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

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected
            ? _PaperworkRequiredState._green
            : const Color(0xFFF0F0F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xFF667085),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeading({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(9, 10, 9, 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: Color(0xFF7B8493)),
        ),
      ],
    ),
  );
}

class _DocumentRow extends StatelessWidget {
  final _Document document;
  const _DocumentRow({required this.document});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE8E8ED))),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: document.required
                  ? const Color(0xFFFFF6D8)
                  : const Color(0xFFF0F0F5),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Text(document.icon, style: const TextStyle(fontSize: 19)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  document.subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7B8493),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: document.required
                  ? const Color(0xFFFFEAEA)
                  : const Color(0xFFF0F0F5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              document.required ? 'Must' : 'Optional',
              style: TextStyle(
                color: document.required ? Colors.red : const Color(0xFF667085),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaperSection {
  final String title;
  final String subtitle;
  final List<_Document> documents;
  const _PaperSection({
    required this.title,
    required this.subtitle,
    required this.documents,
  });
}

class _Document {
  final String icon;
  final String title;
  final String subtitle;
  final bool required;
  const _Document(this.icon, this.title, this.subtitle, this.required);
}
