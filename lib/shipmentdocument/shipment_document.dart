import 'package:flutter/material.dart';

class ShipmentDocument extends StatefulWidget {
  const ShipmentDocument({super.key});

  @override
  State<ShipmentDocument> createState() => _ShipmentDocumentState();
}

class _ShipmentDocumentState extends State<ShipmentDocument> {
  final List<_ShipmentDocumentItem> _documents = const [
    _ShipmentDocumentItem(
      title: 'AWB',
      subtitle: 'Airway Bill / shipment document',
      icon: Icons.description_outlined,
    ),
    _ShipmentDocumentItem(
      title: 'Packing List',
      subtitle: 'Details of packed items',
      icon: Icons.inventory_2_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shipment Documents',
              style: TextStyle(
                color: Color(0xFF202124),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Upload documents related to this shipment',
              style: TextStyle(
                color: Color(0xFF858A91),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 17),
            ..._documents.asMap().entries.map((entry) {
              final document = entry.value;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _documentTile(document),
                  if (entry.key != _documents.length - 1)
                    const Divider(height: 1, color: Color(0xFFE5E5E5)),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _documentTile(_ShipmentDocumentItem document) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload ${document.title}')));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6D8),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                document.icon,
                color: const Color(0xFFB8860B),
                size: 22,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.title,
                    style: const TextStyle(
                      color: Color(0xFF202124),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    document.subtitle,
                    style: const TextStyle(
                      color: Color(0xFF858A91),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE9E7),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'Must',
                style: TextStyle(
                  color: Color(0xFFE64A42),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShipmentDocumentItem {
  const _ShipmentDocumentItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}
