import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yogayog/constants/app_colors.dart';

class PaperworkRequired extends StatefulWidget {
  const PaperworkRequired({super.key});

  @override
  State<PaperworkRequired> createState() => _PaperworkRequiredState();
}

class _PaperworkRequiredState extends State<PaperworkRequired> {
  static const _green = AppColors.primaryMain;
  int _selectedType = 0;

  static const _types = ['🏍 Local', '🚚 National', '☁ Export', '✈ Import'];

  static const _sections = [
    _PaperSection(
      title: 'Local Bike & Truck',
      subtitle: 'Show customer what to bring',
      documents: [
        _Document('📄', 'Consignment Note', 'Filled & signed by sender', true),
        _Document('📦', 'Packed Parcel', 'Properly sealed & labelled', true),
        _Document(
          '□',
          'Sender ID Proof',
          'Aadhaar / PAN / Driving License',
          false,
        ),
      ],
    ),
    _PaperSection(
      title: 'National Delivery',
      subtitle: 'Additional docs for interstate',
      documents: [
        _Document('📄', 'Consignment Note', 'Yogayog printed CN form', true),
        _Document(
          '🧾',
          'Invoice / Packing List',
          'For goods above ₹50,000',
          true,
        ),
        _Document('□', 'GSTIN of Sender', 'If GST invoice required', false),
        _Document('📷', 'Photo of Package', 'For damage liability', false),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final section = _sections[_selectedType == 0 ? 0 : 1];
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
            SizedBox(
              height: 61,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(9, 10, 9, 10),
                scrollDirection: Axis.horizontal,
                itemCount: _types.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) => _TypeChip(
                  label: _types[index],
                  selected: index == _selectedType,
                  onTap: () => setState(() => _selectedType = index),
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _SectionHeading(
                    title: section.title,
                    subtitle: section.subtitle,
                  ),
                  ...section.documents.map(
                    (document) => _DocumentRow(document: document),
                  ),
                  if (_selectedType > 1) ...[
                    const _SectionHeading(
                      title: 'International Documents',
                      subtitle: 'Requirements vary by destination',
                    ),
                    const _DocumentRow(
                      document: _Document(
                        '🛂',
                        'Government ID',
                        'Passport or valid identity proof',
                        true,
                      ),
                    ),
                    const _DocumentRow(
                      document: _Document(
                        '🧾',
                        'Commercial Invoice',
                        'Required for customs clearance',
                        true,
                      ),
                    ),
                    const _DocumentRow(
                      document: _Document(
                        '📦',
                        'Packing List',
                        'Item-wise package details',
                        false,
                      ),
                    ),
                  ],
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
