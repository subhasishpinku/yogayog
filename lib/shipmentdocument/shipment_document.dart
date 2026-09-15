import 'package:flutter/material.dart';

class ShipmentDocument extends StatefulWidget {
  const ShipmentDocument({super.key});

  @override
  State<ShipmentDocument> createState() => _ShipmentDocumentState();
}

class _ShipmentDocumentState extends State<ShipmentDocument> {
  static const _documents = [
    _ShipmentDocumentItem(
      '🔖',
      'AWB',
      'Airway Bill / shipment document',
      true,
      true,
    ),
    _ShipmentDocumentItem(
      '📦',
      'Packing List',
      'Item-wise package details',
      true,
    ),
    _ShipmentDocumentItem(
      '🚢',
      'Shipping Bill',
      'Required for export shipment',
      false,
    ),
    _ShipmentDocumentItem(
      '🧾',
      'Commercial Invoice',
      'Required for customs clearance',
      true,
    ),
    _ShipmentDocumentItem(
      '📍',
      'Need Shipment Track Upload',
      'Upload shipment tracking details',
      false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const _ShipmentHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(9, 14, 9, 7),
                  child: _SectionHeading(
                    title: 'Shipment Documents',
                    subtitle: 'Upload documents related to this shipment',
                  ),
                ),
                ..._documents.map(_documentTile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _documentTile(_ShipmentDocumentItem document) {
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  document.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7B8493),
                  ),
                ),
              ],
            ),
          ),
          if (document.canUpload)
            ElevatedButton(
              onPressed: () => _showUploadMessage(document.title),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC400),
                foregroundColor: Colors.black,
                elevation: 1,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: const Size(0, 34),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('Upload'),
            )
          else
            _statusBadge(document),
        ],
      ),
    );
  }

  Widget _statusBadge(_ShipmentDocumentItem document) {
    return Container(
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
          color: document.required
              ? const Color(0xFFE64A42)
              : const Color(0xFF667085),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _showUploadMessage(String title) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Upload $title')));
  }
}

class _ShipmentHeader extends StatelessWidget {
  const _ShipmentHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 136,
      color: Colors.black,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            right: -18,
            top: -58,
            child: Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF9EA8BE), width: 15),
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
                        child: const SizedBox(
                          width: 36,
                          height: 36,
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Shipment Documents',
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

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
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
  );
}

class _ShipmentDocumentItem {
  const _ShipmentDocumentItem(
    this.icon,
    this.title,
    this.subtitle,
    this.required, [
    this.canUpload = false,
  ]);
  final String icon;
  final String title;
  final String subtitle;
  final bool required;
  final bool canUpload;
}
