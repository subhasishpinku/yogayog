import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:yogayog/paperworkrequired/provider/paperwork_required_provider.dart';

class ShipmentDocument extends StatefulWidget {
  const ShipmentDocument({
    super.key,
    this.orderId = '',
    this.serviceName = '',
    this.orderDate = '',
    this.status = '',
    this.pickupCity = '',
    this.dropCity = '',
    this.shipmentType = 'Export',
  });

  final String orderId;
  final String serviceName;
  final String orderDate;
  final String status;
  final String pickupCity;
  final String dropCity;
  final String shipmentType;

  @override
  State<ShipmentDocument> createState() => _ShipmentDocumentState();
}

class _ShipmentDocumentState extends State<ShipmentDocument> {
  static const _documents = [
    _ShipmentDocumentItem(
      '📦',
      'Packing List',
      'Item-wise package details',
      false,
      true,
    ),
    _ShipmentDocumentItem(
      '🚢',
      'Shipping Bill',
      'Required for export shipment',
      false,
      true,
    ),
    _ShipmentDocumentItem(
      '🧾',
      'Commercial Invoice',
      'Required for customs clearance',
      false,
      true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _ShipmentHeader(orderId: widget.orderId),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [_shipmentSummaryCard(), ..._documentSections()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shipmentSummaryCard() {
    final serviceDate = [
      widget.serviceName,
      widget.orderDate,
    ].where((value) => value.trim().isNotEmpty).join(' · ');
    final route = [
      widget.pickupCity,
      widget.dropCity,
    ].where((value) => value.trim().isNotEmpty).join('  →  ');
    final status = widget.status.trim().isEmpty
        ? 'Manifest Uploaded'
        : widget.status.trim();
    final displayServiceDate = serviceDate.isEmpty
        ? 'International Courier · 2026-09-15'
        : serviceDate;
    final displayRoute = route.isEmpty ? 'Kolkata  →  Bannockburn' : route;

    return Container(
      margin: const EdgeInsets.fromLTRB(9, 10, 9, 2),
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4E5),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: Colors.black87,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.orderId.trim().isEmpty
                          ? 'Shipment'
                          : widget.orderId.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      displayServiceDate,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8A909A),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2C9),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Color(0xFF927000),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            displayRoute,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ],
      ),
    );
  }

  List<Widget> _documentSections() {
    return [
      ..._documentGroup('Bike Document', const ['Invoice', 'Way Bill']),
      ..._documentGroup('Truck Document', const [
        'Invoice',
        'Way Bill – Part A',
        'Way Bill – Part B',
      ]),
      ..._documentGroup('National Document', const [
        'Sales',
        'Invoice',
        'Way Bill – Part A',
        // 'Indian',
      ]),
      ..._documentGroup('International Export Document', const [
        'Packing List',
        'Shipping Bill',
        'Commercial Invoice',
        'Declaration',
      ]),
      ..._documentGroup('International Import Document', const [
        'Commercial Invoice',
        'Declaration',
      ]),
    ];
  }

  List<Widget> _documentGroup(String heading, List<String> titles) {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(9, 14, 9, 7),
        child: Text(
          heading,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
      ),
      ...titles.map(
        (title) => _documentTile(
          _ShipmentDocumentItem(
            '📄',
            title,
            'Upload $title document',
            false,
            true,
          ),
        ),
      ),
    ];
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _statusBadge(document),
              if (document.canUpload) ...[
                const SizedBox(width: 6),
                ElevatedButton(
                  onPressed: () => _showUploadDialog(document),
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
                ),
              ],
            ],
          ),
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

  Future<void> _showUploadDialog(_ShipmentDocumentItem document) async {
    XFile? image;
    var isSubmitting = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Upload ${document.title}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(image!.path),
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    height: 120,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFD8D8E0)),
                    ),
                    child: Text('No ${document.title} photo selected'),
                  ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    final selected = await ImagePicker().pickImage(
                      source: ImageSource.camera,
                      imageQuality: 85,
                    );
                    if (selected != null) {
                      setDialogState(() => image = selected);
                    }
                  },
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: Text(
                    image == null
                        ? 'Take ${document.title} Photo'
                        : 'Retake ${document.title} Photo',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (image == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please select ${document.title} photo',
                            ),
                          ),
                        );
                        return;
                      }
                      setDialogState(() => isSubmitting = true);
                      final type = document.title
                          .toLowerCase()
                          .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
                          .replaceAll(RegExp(r'^_|_$'), '');
                      final success = await context
                          .read<PaperworkRequiredProvider>()
                          .uploadDocument(documentType: type, image: image!);
                      if (!mounted) return;
                      if (!success) {
                        setDialogState(() => isSubmitting = false);
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text(
                              this.context
                                      .read<PaperworkRequiredProvider>()
                                      .errorMessage ??
                                  'Unable to upload ${document.title}',
                            ),
                          ),
                        );
                        return;
                      }
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${document.title} uploaded successfully',
                          ),
                        ),
                      );
                    },
              child: isSubmitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Verify & Upload'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShipmentHeader extends StatelessWidget {
  const _ShipmentHeader({this.orderId = ''});

  final String orderId;

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
                  if (orderId.trim().isNotEmpty)
                    Text(
                      'Order ID: ${orderId.trim()}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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
